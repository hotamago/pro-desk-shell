use std::env;
use std::process::Command;

use serde::Serialize;
use shell_core::{
    load_or_create_config, persist_config, search_app_entries, ShellConfig, ShellSnapshot,
};

#[derive(Debug, Serialize)]
struct FrontendPayload {
    config: ShellConfig,
    snapshot: ShellSnapshot,
    status_line: String,
}

#[derive(Debug, Serialize)]
struct CommandResponse {
    ok: bool,
    message: String,
}

fn main() {
    if let Err(error) = try_main() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}

fn try_main() -> Result<(), String> {
    let args = env::args().skip(1).collect::<Vec<_>>();
    let Some(command) = args.first().map(String::as_str) else {
        return Err(usage());
    };

    match command {
        "snapshot" => print_json(&snapshot_payload()?),
        "search" => {
            let query = args
                .get(1..)
                .map(|parts| parts.join(" "))
                .unwrap_or_default();
            let config = load_or_create_config()?;
            let snapshot = shell_hyprland::load_snapshot(&config)
                .unwrap_or_else(|_| shell_hyprland::bootstrap_snapshot(&config));
            let results =
                search_app_entries(snapshot.app_catalog(), &query, config.launcher.max_results);
            print_json(&results);
        }
        "launch-app" => {
            let app_id = required_argument(&args, 1, "app id")?;
            shell_hyprland::launch_app(app_id)?;
            print_json(&CommandResponse {
                ok: true,
                message: format!("Launch request sent for '{app_id}'."),
            });
        }
        "activate-workspace" => {
            let target = required_argument(&args, 1, "workspace target")?;
            shell_hyprland::activate_workspace(target)?;
            print_json(&CommandResponse {
                ok: true,
                message: format!("Workspace activation sent for '{target}'."),
            });
        }
        "focus-window" => {
            let window_id = required_argument(&args, 1, "window id")?;
            shell_hyprland::focus_window(window_id)?;
            print_json(&CommandResponse {
                ok: true,
                message: format!("Focus request sent for '{window_id}'."),
            });
        }
        "toggle-dock-pin" => {
            let app_id = required_argument(&args, 1, "app id")?;
            let mut config = load_or_create_config()?;
            toggle_dock_pin(&mut config, app_id);
            persist_config(&config)?;
            print_json(&config);
        }
        "set-volume" => {
            let value = parse_i32(
                required_argument(&args, 1, "volume percent")?,
                "volume percent",
            )?;
            shell_hyprland::set_volume_percent(value)?;
            print_json(&CommandResponse {
                ok: true,
                message: format!("Volume target set to {}%.", value.clamp(0, 150)),
            });
        }
        "set-brightness" => {
            let value = parse_i32(
                required_argument(&args, 1, "brightness percent")?,
                "brightness percent",
            )?;
            shell_hyprland::set_brightness_percent(value)?;
            print_json(&CommandResponse {
                ok: true,
                message: format!("Brightness target set to {}%.", value.clamp(1, 100)),
            });
        }
        "set-menu-bar-compact-mode" => {
            let value = parse_bool(required_argument(&args, 1, "compact mode")?)?;
            let mut config = load_or_create_config()?;
            config.menu_bar.compact_mode = value;
            persist_config(&config)?;
            print_json(&config);
        }
        "set-dock-auto-hide" => {
            let value = parse_bool(required_argument(&args, 1, "auto hide")?)?;
            let mut config = load_or_create_config()?;
            config.dock.auto_hide = value;
            persist_config(&config)?;
            print_json(&config);
        }
        "set-dock-show-running-indicators" => {
            let value = parse_bool(required_argument(&args, 1, "show running indicators")?)?;
            let mut config = load_or_create_config()?;
            config.dock.show_running_indicators = value;
            persist_config(&config)?;
            print_json(&config);
        }
        "set-dock-magnification" => {
            let value = parse_i32(
                required_argument(&args, 1, "dock magnification")?,
                "dock magnification",
            )?;
            let mut config = load_or_create_config()?;
            config.dock.magnification = value.clamp(0, 40);
            persist_config(&config)?;
            print_json(&config);
        }
        "set-launcher-max-results" => {
            let value = parse_i32(
                required_argument(&args, 1, "launcher max results")?,
                "launcher max results",
            )?;
            let mut config = load_or_create_config()?;
            config.launcher.max_results = value.clamp(4, 16) as usize;
            persist_config(&config)?;
            print_json(&config);
        }
        "set-terminal-command" => {
            let value = args
                .get(1..)
                .map(|parts| parts.join(" "))
                .ok_or_else(|| String::from("Missing terminal command."))?;
            let mut config = load_or_create_config()?;
            config.integrations.terminal = value.trim().to_owned();
            persist_config(&config)?;
            print_json(&config);
        }
        "set-wallpaper-path" => {
            let value = args
                .get(1..)
                .map(|parts| parts.join(" "))
                .ok_or_else(|| String::from("Missing wallpaper path."))?;
            let mut config = load_or_create_config()?;
            config.background.wallpaper_path = value.trim().to_owned();
            persist_config(&config)?;
            print_json(&config);
        }
        "request-lock" => {
            request_lock()?;
            print_json(&CommandResponse {
                ok: true,
                message: String::from("Session lock request sent."),
            });
        }
        _ => return Err(usage()),
    }

    Ok(())
}

fn snapshot_payload() -> Result<FrontendPayload, String> {
    let config = load_or_create_config()?;
    let snapshot = shell_hyprland::load_snapshot(&config)
        .unwrap_or_else(|_| shell_hyprland::bootstrap_snapshot(&config));

    Ok(FrontendPayload {
        status_line: build_status_line(&snapshot),
        config,
        snapshot,
    })
}

fn print_json<T: Serialize>(value: &T) {
    println!(
        "{}",
        serde_json::to_string(value).unwrap_or_else(|_| String::from("{}"))
    );
}

fn required_argument<'a>(args: &'a [String], index: usize, label: &str) -> Result<&'a str, String> {
    args.get(index)
        .map(String::as_str)
        .filter(|value| !value.trim().is_empty())
        .ok_or_else(|| format!("Missing {label}."))
}

fn parse_bool(value: &str) -> Result<bool, String> {
    match value.trim().to_ascii_lowercase().as_str() {
        "1" | "true" | "yes" | "on" => Ok(true),
        "0" | "false" | "no" | "off" => Ok(false),
        _ => Err(format!("Could not parse boolean value '{value}'.")),
    }
}

fn parse_i32(value: &str, label: &str) -> Result<i32, String> {
    value
        .trim()
        .parse::<i32>()
        .map_err(|error| format!("Could not parse {label}: {error}"))
}

fn toggle_dock_pin(config: &mut ShellConfig, app_id: &str) {
    if let Some(index) = config
        .dock
        .pinned_apps
        .iter()
        .position(|candidate| candidate == app_id)
    {
        config.dock.pinned_apps.remove(index);
    } else {
        config.dock.pinned_apps.push(app_id.to_owned());
    }
}

fn request_lock() -> Result<(), String> {
    Command::new("loginctl")
        .arg("lock-session")
        .status()
        .map_err(|error| format!("Could not invoke loginctl: {error}"))
        .and_then(|status| {
            if status.success() {
                Ok(())
            } else {
                Err(format!(
                    "loginctl lock-session exited with status {:?}.",
                    status.code()
                ))
            }
        })
}

fn build_status_line(snapshot: &ShellSnapshot) -> String {
    if snapshot.capabilities().has_hyprland {
        format!(
            "Linked to {} with {} workspaces, {} windows, and {} apps indexed.",
            snapshot.compositor_name(),
            snapshot.workspaces().len(),
            snapshot.windows().len(),
            snapshot.app_catalog().len()
        )
    } else {
        format!(
            "Running in preview mode with {} apps indexed for the AGS shell.",
            snapshot.app_catalog().len()
        )
    }
}

fn usage() -> String {
    String::from(
        "Usage: shell_cli <snapshot|search|launch-app|activate-workspace|focus-window|toggle-dock-pin|set-volume|set-brightness|set-menu-bar-compact-mode|set-dock-auto-hide|set-dock-show-running-indicators|set-dock-magnification|set-launcher-max-results|set-terminal-command|set-wallpaper-path|request-lock> [...]",
    )
}
