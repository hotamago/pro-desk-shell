use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::io::{Read, Write};
use std::net::Shutdown;
use std::os::unix::net::UnixStream;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::OnceLock;

use serde::Deserialize;
use shell_core::{
    build_notification_summary, derive_dock_items, desktop_applications_dirs,
    group_windows_by_workspace, icon_search_dirs, match_window_class_to_app_id,
    parse_brightnessctl_machine_output, parse_desktop_entry, parse_nmcli_active_wifi,
    parse_playerctl_metadata_output, parse_upower_output, parse_wpctl_volume_output,
    ActiveWindowSummary, AppEntrySummary, BatterySummary, MediaSummary, NetworkSummary,
    NotificationItemSummary, PlaybackStatus, QuickSettingsSummary, ShellCapabilities, ShellConfig,
    ShellSnapshot, WindowSummary, WorkspaceSummary,
};

static APP_CATALOG_CACHE: OnceLock<Vec<AppEntrySummary>> = OnceLock::new();

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HyprlandSockets {
    command_socket: PathBuf,
    event_socket: PathBuf,
}

impl HyprlandSockets {
    pub fn command_socket(&self) -> &PathBuf {
        &self.command_socket
    }

    pub fn event_socket(&self) -> &PathBuf {
        &self.event_socket
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum HyprlandEvent {
    WorkspaceChanged { id: i32, name: String },
    ActiveWindowChanged { class_name: String, title: String },
    FullscreenChanged(bool),
    Unknown(String),
}

pub fn detect_sockets() -> Option<HyprlandSockets> {
    let runtime_dir = env::var_os("XDG_RUNTIME_DIR")?;
    let signature = env::var("HYPRLAND_INSTANCE_SIGNATURE").ok()?;
    let base_path = PathBuf::from(runtime_dir).join("hypr").join(signature);

    Some(HyprlandSockets {
        command_socket: base_path.join(".socket.sock"),
        event_socket: base_path.join(".socket2.sock"),
    })
}

pub fn bootstrap_snapshot(config: &ShellConfig) -> ShellSnapshot {
    load_snapshot(config).unwrap_or_else(|_| ShellSnapshot::placeholder())
}

pub fn load_snapshot(config: &ShellConfig) -> Result<ShellSnapshot, String> {
    let capabilities = ShellCapabilities::detect();
    let app_catalog = load_app_catalog();
    let system_state = system_state_snapshot(&capabilities);
    let Some(sockets) = detect_sockets() else {
        return Ok(fallback_snapshot(
            config,
            capabilities,
            system_state,
            app_catalog,
        ));
    };

    let client = HyprlandClient::new(sockets);
    let raw_workspaces = client.command("j/workspaces")?;
    let raw_monitors = client.command("j/monitors")?;
    let raw_active_window = client.command("j/activewindow")?;
    let raw_clients = client.command("j/clients")?;

    let workspaces = serde_json::from_str::<Vec<HyprWorkspace>>(&raw_workspaces)
        .map_err(|error| format!("Could not parse Hyprland workspaces JSON: {error}"))?;
    let monitors = serde_json::from_str::<Vec<HyprMonitor>>(&raw_monitors)
        .map_err(|error| format!("Could not parse Hyprland monitors JSON: {error}"))?;
    let active_window = serde_json::from_str::<HyprActiveWindow>(&raw_active_window)
        .map_err(|error| format!("Could not parse Hyprland active window JSON: {error}"))?;
    let clients = serde_json::from_str::<Vec<HyprClient>>(&raw_clients)
        .map_err(|error| format!("Could not parse Hyprland clients JSON: {error}"))?;

    let active_workspace = monitors
        .iter()
        .find(|monitor| monitor.focused)
        .map(|monitor| monitor.active_workspace.name.clone())
        .or_else(|| {
            monitors
                .first()
                .map(|monitor| monitor.active_workspace.name.clone())
        });

    let window_summaries = build_window_summaries(&clients, &active_window, &app_catalog);
    let workspace_summaries = workspaces
        .into_iter()
        .map(|workspace| {
            let computed_window_count = window_summaries
                .iter()
                .filter(|window| window.workspace_id() == workspace.id)
                .count();
            WorkspaceSummary::with_state(
                workspace.id,
                workspace.name.clone(),
                active_workspace
                    .as_deref()
                    .map(|active| active == workspace.name)
                    .unwrap_or(false),
                computed_window_count.max(workspace.windows.max(0) as usize),
            )
        })
        .collect::<Vec<_>>();

    let active_app_id = match_window_class_to_app_id(&active_window.class_name, &app_catalog);
    let dock_items = derive_dock_items(&config.dock.pinned_apps, &app_catalog, &window_summaries);
    let notification_history = system_state.notification_history.clone();

    Ok(ShellSnapshot::new(
        Some(String::from("Hyprland")),
        workspace_summaries.clone(),
        active_workspace,
        ActiveWindowSummary::with_state(
            empty_fallback(&active_window.title, "Desktop"),
            empty_fallback(&active_window.class_name, "unknown"),
            active_window.floating,
            active_window.fullscreen != 0,
        ),
        active_app_id,
        app_catalog.clone(),
        dock_items,
        window_summaries.clone(),
        group_windows_by_workspace(&workspace_summaries, &window_summaries),
        system_state.media,
        system_state.battery,
        system_state.network,
        build_notification_summary(&notification_history),
        notification_history,
        system_state.quick_settings,
        capabilities,
    ))
}

pub fn launch_app(app_id: &str) -> Result<(), String> {
    let app_catalog = load_app_catalog();
    let app = app_catalog
        .iter()
        .find(|candidate| candidate.app_id() == app_id)
        .ok_or_else(|| format!("Could not find app '{app_id}' in the catalog."))?;

    Command::new("sh")
        .arg("-lc")
        .arg(app.exec_command())
        .spawn()
        .map(|_| ())
        .map_err(|error| format!("Could not launch '{}': {error}", app.display_name()))
}

pub fn activate_workspace(target: &str) -> Result<(), String> {
    if target.trim().is_empty() {
        return Err(String::from("Workspace target cannot be empty."));
    }

    if target.parse::<i32>().is_ok() {
        dispatch(&format!("workspace {target}"))
    } else {
        dispatch(&format!("workspace name:{target}"))
    }
}

pub fn focus_window(window_id: &str) -> Result<(), String> {
    if window_id.trim().is_empty() {
        return Err(String::from("Window target cannot be empty."));
    }

    dispatch(&format!("focuswindow address:{window_id}"))
}

pub fn set_volume_percent(value: i32) -> Result<(), String> {
    let clamped = value.clamp(0, 150);
    Command::new("wpctl")
        .args(["set-volume", "@DEFAULT_AUDIO_SINK@", &format!("{clamped}%")])
        .status()
        .map_err(|error| format!("Could not invoke wpctl: {error}"))
        .and_then(|status| {
            if status.success() {
                Ok(())
            } else {
                Err(format!("wpctl exited with status {:?}.", status.code()))
            }
        })
}

pub fn set_brightness_percent(value: i32) -> Result<(), String> {
    let clamped = value.clamp(1, 100);
    Command::new("brightnessctl")
        .args(["set", &format!("{clamped}%")])
        .status()
        .map_err(|error| format!("Could not invoke brightnessctl: {error}"))
        .and_then(|status| {
            if status.success() {
                Ok(())
            } else {
                Err(format!(
                    "brightnessctl exited with status {:?}.",
                    status.code()
                ))
            }
        })
}

pub fn parse_event_line(line: &str) -> HyprlandEvent {
    let trimmed = line.trim();
    let Some((event_name, payload)) = trimmed.split_once(">>") else {
        return HyprlandEvent::Unknown(trimmed.to_owned());
    };

    match event_name {
        "workspacev2" => {
            let mut parts = payload.splitn(2, ',');
            let id = parts
                .next()
                .and_then(|value| value.parse::<i32>().ok())
                .unwrap_or_default();
            let name = parts.next().unwrap_or("workspace").to_owned();
            HyprlandEvent::WorkspaceChanged { id, name }
        }
        "activewindowv2" | "activewindow" => {
            let parts = payload.split(',').collect::<Vec<_>>();
            let title = parts.last().copied().unwrap_or_default().to_owned();
            let class_name = parts
                .get(parts.len().saturating_sub(2))
                .copied()
                .unwrap_or("unknown")
                .to_owned();
            HyprlandEvent::ActiveWindowChanged { class_name, title }
        }
        "fullscreen" => HyprlandEvent::FullscreenChanged(payload.trim() == "1"),
        _ => HyprlandEvent::Unknown(trimmed.to_owned()),
    }
}

#[derive(Debug)]
struct HyprlandClient {
    sockets: HyprlandSockets,
}

impl HyprlandClient {
    fn new(sockets: HyprlandSockets) -> Self {
        Self { sockets }
    }

    fn command(&self, command: &str) -> Result<String, String> {
        let mut stream = UnixStream::connect(self.sockets.command_socket()).map_err(|error| {
            format!(
                "Could not connect to Hyprland command socket '{}': {error}",
                self.sockets.command_socket().display()
            )
        })?;

        stream.write_all(command.as_bytes()).map_err(|error| {
            format!("Could not write Hyprland IPC command '{command}': {error}")
        })?;
        stream.shutdown(Shutdown::Write).map_err(|error| {
            format!("Could not finalize Hyprland IPC command '{command}': {error}")
        })?;

        let mut response = String::new();
        stream.read_to_string(&mut response).map_err(|error| {
            format!("Could not read Hyprland IPC response for '{command}': {error}")
        })?;

        Ok(response)
    }
}

#[derive(Debug, Clone)]
struct SystemStateSnapshot {
    media: MediaSummary,
    battery: BatterySummary,
    network: NetworkSummary,
    notification_history: Vec<NotificationItemSummary>,
    quick_settings: QuickSettingsSummary,
}

fn fallback_snapshot(
    config: &ShellConfig,
    capabilities: ShellCapabilities,
    system_state: SystemStateSnapshot,
    app_catalog: Vec<AppEntrySummary>,
) -> ShellSnapshot {
    let workspaces = vec![
        WorkspaceSummary::with_state(1, "Desktop", true, 2),
        WorkspaceSummary::with_state(2, "Studio", false, 2),
        WorkspaceSummary::with_state(3, "Comms", false, 1),
    ];
    let windows = vec![
        WindowSummary::new(
            "preview-firefox",
            "Shell preview",
            "firefox",
            "firefox",
            1,
            "Desktop",
            true,
            false,
            false,
        ),
        WindowSummary::new(
            "preview-kitty",
            "dev shell",
            "kitty",
            "kitty",
            2,
            "Studio",
            false,
            false,
            false,
        ),
    ];
    let dock_items = derive_dock_items(&config.dock.pinned_apps, &app_catalog, &windows);
    let notification_history = system_state.notification_history.clone();

    ShellSnapshot::new(
        Some(String::from("Hyprland")),
        workspaces.clone(),
        Some(String::from("Desktop")),
        ActiveWindowSummary::with_state("Shell preview", "pro-desk-shell", false, false),
        Some(String::from("firefox")),
        app_catalog,
        dock_items,
        windows.clone(),
        group_windows_by_workspace(&workspaces, &windows),
        system_state.media,
        system_state.battery,
        system_state.network,
        build_notification_summary(&notification_history),
        notification_history,
        system_state.quick_settings,
        capabilities,
    )
}

fn system_state_snapshot(capabilities: &ShellCapabilities) -> SystemStateSnapshot {
    let media = if capabilities.has_playerctl {
        command_output(
            "playerctl",
            &[
                "metadata",
                "--format",
                "{{status}}\n{{xesam:title}}\n{{xesam:artist}}",
            ],
        )
        .as_deref()
        .and_then(parse_playerctl_metadata_output)
        .unwrap_or_else(|| {
            MediaSummary::new(
                "playerctl",
                "Nothing playing",
                "Idle",
                PlaybackStatus::Stopped,
            )
        })
    } else {
        MediaSummary::new(
            "media",
            "Playerctl unavailable",
            "Install playerctl for live data",
            PlaybackStatus::Unknown,
        )
    };

    let volume_percent = if capabilities.has_wpctl {
        command_output("wpctl", &["get-volume", "@DEFAULT_AUDIO_SINK@"])
            .as_deref()
            .and_then(parse_wpctl_volume_output)
            .unwrap_or(55)
    } else {
        55
    };

    let brightness_percent = if capabilities.has_brightnessctl {
        command_output("brightnessctl", &["-m"])
            .as_deref()
            .and_then(parse_brightnessctl_machine_output)
            .unwrap_or(70)
    } else {
        70
    };

    let network_name = if capabilities.has_nmcli {
        command_output("nmcli", &["-t", "-f", "active,ssid", "dev", "wifi"])
            .as_deref()
            .and_then(parse_nmcli_active_wifi)
            .unwrap_or_else(|| String::from("Offline"))
    } else {
        String::from("Network tools unavailable")
    };

    let battery = if capabilities.has_upower {
        primary_battery_path()
            .and_then(|battery_path| command_output("upower", &["-i", &battery_path]))
            .as_deref()
            .and_then(parse_upower_output)
            .unwrap_or_else(|| BatterySummary::new(100, false))
    } else {
        BatterySummary::new(100, false)
    };

    let notification_history = vec![
        NotificationItemSummary::new(
            "runtime-status",
            "Shell",
            if capabilities.has_hyprland {
                "Hyprland link live"
            } else {
                "Hyprland not detected"
            },
            if capabilities.has_hyprland {
                "Menu bar, dock, Spotlight, and Mission Control are reading compositor state."
            } else {
                "Run inside Hyprland to replace preview windows with live workspace state."
            },
            "Now",
            "normal",
            false,
        ),
        NotificationItemSummary::new(
            "runtime-system",
            "System",
            "Control Center ready",
            format!(
                "Audio {}, brightness {}, network {}.",
                volume_percent, brightness_percent, network_name
            ),
            "Just now",
            "low",
            false,
        ),
    ];

    let network_state = if network_name == "Offline" {
        "Disconnected"
    } else {
        "Connected"
    };

    SystemStateSnapshot {
        media,
        battery,
        network: NetworkSummary::new(network_name, network_state),
        notification_history,
        quick_settings: QuickSettingsSummary::new(volume_percent, brightness_percent),
    }
}

fn build_window_summaries(
    clients: &[HyprClient],
    active_window: &HyprActiveWindow,
    app_catalog: &[AppEntrySummary],
) -> Vec<WindowSummary> {
    clients
        .iter()
        .filter(|client| client.mapped)
        .map(|client| {
            let app_id = match_window_class_to_app_id(&client.class_name, app_catalog)
                .unwrap_or_else(|| empty_fallback(&client.class_name, "unknown"));
            let focused = (!active_window.address.is_empty()
                && client.address == active_window.address)
                || (client.class_name == active_window.class_name
                    && client.title == active_window.title
                    && !client.title.is_empty());

            WindowSummary::new(
                client.address.clone(),
                empty_fallback(&client.title, "Window"),
                empty_fallback(&client.class_name, "unknown"),
                app_id,
                client.workspace.id,
                empty_fallback(&client.workspace.name, "Workspace"),
                focused,
                client.floating,
                client.fullscreen != 0,
            )
        })
        .collect()
}

fn load_app_catalog() -> Vec<AppEntrySummary> {
    APP_CATALOG_CACHE
        .get_or_init(load_app_catalog_uncached)
        .clone()
}

fn load_app_catalog_uncached() -> Vec<AppEntrySummary> {
    let mut catalog = BTreeMap::<String, AppEntrySummary>::new();

    for directory in desktop_applications_dirs() {
        let Ok(entries) = fs::read_dir(&directory) else {
            continue;
        };

        for entry in entries.flatten() {
            let path = entry.path();
            let is_desktop_entry = path
                .extension()
                .and_then(|extension| extension.to_str())
                .map(|extension| extension == "desktop")
                .unwrap_or(false);
            if !is_desktop_entry {
                continue;
            }

            let Some(stem) = path.file_stem().and_then(|stem| stem.to_str()) else {
                continue;
            };
            let Ok(content) = fs::read_to_string(&path) else {
                continue;
            };

            if let Some(app) = parse_desktop_entry(stem, &content) {
                let app = if let Some(icon_path) = resolve_icon_path(app.icon_name()) {
                    app.with_icon_path(icon_path)
                } else {
                    app
                };
                catalog.entry(app.app_id().to_owned()).or_insert(app);
            }
        }
    }

    if catalog.is_empty() {
        return ShellSnapshot::placeholder().app_catalog().to_vec();
    }

    catalog.into_values().collect()
}

fn resolve_icon_path(icon_name: &str) -> Option<String> {
    let trimmed = icon_name.trim();
    if trimmed.is_empty() {
        return None;
    }

    let direct_path = PathBuf::from(trimmed);
    if direct_path.is_file() {
        return Some(direct_path.to_string_lossy().into_owned());
    }

    let exact_candidates = if Path::new(trimmed).extension().is_some() {
        vec![trimmed.to_owned()]
    } else {
        ["png", "svg", "xpm", "jpg", "jpeg", "webp"]
            .into_iter()
            .map(|extension| format!("{trimmed}.{extension}"))
            .collect::<Vec<_>>()
    };

    for directory in icon_search_dirs() {
        if let Some(path) = find_icon_in_dir(&directory, trimmed, &exact_candidates) {
            return Some(path.to_string_lossy().into_owned());
        }
    }

    None
}

fn find_icon_in_dir(
    directory: &Path,
    icon_name: &str,
    exact_candidates: &[String],
) -> Option<PathBuf> {
    if !directory.exists() {
        return None;
    }

    for candidate in exact_candidates {
        let candidate_path = directory.join(candidate);
        if candidate_path.is_file() {
            return Some(candidate_path);
        }
    }

    let mut pending = vec![(directory.to_path_buf(), 0usize)];
    while let Some((current, depth)) = pending.pop() {
        let Ok(entries) = fs::read_dir(&current) else {
            continue;
        };

        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if icon_matches(&path, icon_name, exact_candidates) {
                    return Some(path);
                }
                continue;
            }

            if depth < 5 {
                pending.push((path, depth + 1));
            }
        }
    }

    None
}

fn icon_matches(path: &Path, icon_name: &str, exact_candidates: &[String]) -> bool {
    let file_name = path
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or_default();
    let file_stem = path
        .file_stem()
        .and_then(|value| value.to_str())
        .unwrap_or_default();
    let normalized_name = icon_name.to_ascii_lowercase();
    let normalized_file_name = file_name.to_ascii_lowercase();
    let normalized_file_stem = file_stem.to_ascii_lowercase();

    exact_candidates
        .iter()
        .any(|candidate| normalized_file_name == candidate.to_ascii_lowercase())
        || normalized_file_stem == normalized_name
}

fn primary_battery_path() -> Option<String> {
    let output = command_output("upower", &["-e"])?;
    output
        .lines()
        .map(str::trim)
        .find(|line| line.contains("battery"))
        .map(ToOwned::to_owned)
}

fn dispatch(command: &str) -> Result<(), String> {
    let sockets =
        detect_sockets().ok_or_else(|| String::from("Hyprland sockets are unavailable."))?;
    let client = HyprlandClient::new(sockets);
    client.command(&format!("dispatch {command}")).map(|_| ())
}

fn command_output(command: &str, arguments: &[&str]) -> Option<String> {
    let output = Command::new(command).args(arguments).output().ok()?;
    if !output.status.success() {
        return None;
    }

    let text = String::from_utf8(output.stdout).ok()?;
    let trimmed = text.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_owned())
    }
}

fn empty_fallback(value: &str, fallback: &str) -> String {
    if value.trim().is_empty() {
        fallback.to_owned()
    } else {
        value.to_owned()
    }
}

#[derive(Debug, Deserialize)]
struct HyprWorkspace {
    id: i32,
    name: String,
    windows: i32,
}

#[derive(Debug, Deserialize)]
struct HyprActiveWorkspace {
    name: String,
}

#[derive(Debug, Deserialize)]
struct HyprMonitor {
    focused: bool,
    #[serde(rename = "activeWorkspace")]
    active_workspace: HyprActiveWorkspace,
}

#[derive(Debug, Deserialize)]
struct HyprActiveWindow {
    #[serde(default)]
    address: String,
    #[serde(default, rename = "class")]
    class_name: String,
    #[serde(default)]
    title: String,
    #[serde(default)]
    floating: bool,
    #[serde(default)]
    fullscreen: i32,
}

#[derive(Debug, Default, Deserialize)]
struct HyprClientWorkspace {
    #[serde(default)]
    id: i32,
    #[serde(default)]
    name: String,
}

#[derive(Debug, Deserialize)]
struct HyprClient {
    #[serde(default)]
    address: String,
    #[serde(default, rename = "class")]
    class_name: String,
    #[serde(default)]
    title: String,
    #[serde(default)]
    floating: bool,
    #[serde(default)]
    fullscreen: i32,
    #[serde(default)]
    mapped: bool,
    #[serde(default)]
    workspace: HyprClientWorkspace,
}

#[cfg(test)]
mod tests {
    use super::{parse_event_line, HyprlandEvent};

    #[test]
    fn parses_workspace_event() {
        assert_eq!(
            parse_event_line("workspacev2>>4,4:ops"),
            HyprlandEvent::WorkspaceChanged {
                id: 4,
                name: String::from("4:ops"),
            }
        );
    }

    #[test]
    fn parses_active_window_event() {
        assert_eq!(
            parse_event_line("activewindowv2>>0x1234,kitty,notes.md"),
            HyprlandEvent::ActiveWindowChanged {
                class_name: String::from("kitty"),
                title: String::from("notes.md"),
            }
        );
    }

    #[test]
    fn keeps_unknown_events_round_trippable() {
        match parse_event_line("mystery>>payload") {
            HyprlandEvent::Unknown(line) => assert_eq!(line, "mystery>>payload"),
            other => panic!("expected unknown event, got {other:?}"),
        }
    }
}
