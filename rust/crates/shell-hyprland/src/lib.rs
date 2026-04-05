use std::env;
use std::io::{Read, Write};
use std::net::Shutdown;
use std::os::unix::net::UnixStream;
use std::path::PathBuf;
use std::process::Command;

use serde::Deserialize;
use shell_core::{
    ActiveWindowSummary,
    BatterySummary,
    MediaSummary,
    NetworkSummary,
    NotificationSummary,
    PlaybackStatus,
    QuickSettingsSummary,
    ShellCapabilities,
    ShellSnapshot,
    WorkspaceSummary,
    parse_brightnessctl_machine_output,
    parse_nmcli_active_wifi,
    parse_playerctl_metadata_output,
    parse_upower_output,
    parse_wpctl_volume_output,
};

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

pub fn bootstrap_snapshot() -> ShellSnapshot {
    load_snapshot().unwrap_or_else(|_| ShellSnapshot::placeholder())
}

pub fn load_snapshot() -> Result<ShellSnapshot, String> {
    let capabilities = ShellCapabilities::detect();
    let system_state = system_state_snapshot(&capabilities);
    let Some(sockets) = detect_sockets() else {
        return Ok(fallback_snapshot(capabilities, system_state));
    };

    let client = HyprlandClient::new(sockets);
    let raw_workspaces = client.command("j/workspaces")?;
    let raw_monitors = client.command("j/monitors")?;
    let raw_active_window = client.command("j/activewindow")?;

    let workspaces = serde_json::from_str::<Vec<HyprWorkspace>>(&raw_workspaces)
        .map_err(|error| format!("Could not parse Hyprland workspaces JSON: {error}"))?;
    let monitors = serde_json::from_str::<Vec<HyprMonitor>>(&raw_monitors)
        .map_err(|error| format!("Could not parse Hyprland monitors JSON: {error}"))?;
    let active_window = serde_json::from_str::<HyprActiveWindow>(&raw_active_window)
        .map_err(|error| format!("Could not parse Hyprland active window JSON: {error}"))?;

    let active_workspace = monitors
        .iter()
        .find(|monitor| monitor.focused)
        .map(|monitor| monitor.active_workspace.name.clone())
        .or_else(|| monitors.first().map(|monitor| monitor.active_workspace.name.clone()));

    let workspace_summaries = workspaces
        .into_iter()
        .map(|workspace| {
            WorkspaceSummary::with_state(
                workspace.id,
                workspace.name.clone(),
                active_workspace
                    .as_deref()
                    .map(|active| active == workspace.name)
                    .unwrap_or(false),
                workspace.windows.max(0) as usize,
            )
        })
        .collect();

    Ok(ShellSnapshot::new(
        Some(String::from("Hyprland")),
        workspace_summaries,
        active_workspace,
        ActiveWindowSummary::with_state(
            empty_fallback(&active_window.title, "Desktop"),
            empty_fallback(&active_window.class_name, "unknown"),
            active_window.floating,
            active_window.fullscreen != 0,
        ),
        system_state.media,
        system_state.battery,
        system_state.network,
        system_state.notifications,
        system_state.quick_settings,
        capabilities,
    ))
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

        stream
            .write_all(command.as_bytes())
            .map_err(|error| format!("Could not write Hyprland IPC command '{command}': {error}"))?;
        stream
            .shutdown(Shutdown::Write)
            .map_err(|error| format!("Could not finalize Hyprland IPC command '{command}': {error}"))?;

        let mut response = String::new();
        stream
            .read_to_string(&mut response)
            .map_err(|error| format!("Could not read Hyprland IPC response for '{command}': {error}"))?;

        Ok(response)
    }
}

#[derive(Debug)]
struct SystemStateSnapshot {
    media: MediaSummary,
    battery: BatterySummary,
    network: NetworkSummary,
    notifications: NotificationSummary,
    quick_settings: QuickSettingsSummary,
}

fn fallback_snapshot(capabilities: ShellCapabilities, system_state: SystemStateSnapshot) -> ShellSnapshot {
    ShellSnapshot::new(
        Some(String::from("Hyprland")),
        vec![
            WorkspaceSummary::with_state(1, "1:web", true, 2),
            WorkspaceSummary::with_state(2, "2:code", false, 4),
            WorkspaceSummary::with_state(3, "3:chat", false, 1),
        ],
        Some(String::from("1:web")),
        ActiveWindowSummary::with_state("Shell preview", "pro-desk-shell", false, false),
        system_state.media,
        system_state.battery,
        system_state.network,
        system_state.notifications,
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
        .unwrap_or_else(|| MediaSummary::new("playerctl", "Nothing playing", "Idle", PlaybackStatus::Stopped))
    } else {
        MediaSummary::new("media", "Playerctl unavailable", "Install playerctl for live data", PlaybackStatus::Unknown)
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

    let notification_title = if capabilities.has_hyprland {
        "Hyprland link live"
    } else {
        "Hyprland not detected"
    };
    let notification_body = if capabilities.has_hyprland {
        "Top bar and overlays are reading compositor state from the Rust adapter."
    } else {
        "Run inside Hyprland to replace scaffold data with live workspace state."
    };

    let network_state = if network_name == "Offline" {
        "Disconnected"
    } else {
        "Connected"
    };

    SystemStateSnapshot {
        media,
        battery,
        network: NetworkSummary::new(network_name, network_state),
        notifications: NotificationSummary::new(1, notification_title, notification_body),
        quick_settings: QuickSettingsSummary::new(volume_percent, brightness_percent),
    }
}

fn primary_battery_path() -> Option<String> {
    let output = command_output("upower", &["-e"])?;
    output
        .lines()
        .map(str::trim)
        .find(|line| line.contains("battery"))
        .map(ToOwned::to_owned)
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
    #[serde(default, rename = "class")]
    class_name: String,
    #[serde(default)]
    title: String,
    #[serde(default)]
    floating: bool,
    #[serde(default)]
    fullscreen: i32,
}

#[cfg(test)]
mod tests {
    use super::{HyprlandEvent, parse_event_line};

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
