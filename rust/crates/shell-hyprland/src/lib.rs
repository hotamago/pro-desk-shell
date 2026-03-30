use std::env;
use std::path::PathBuf;

use shell_core::ShellSnapshot;

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
    ShellSnapshot::placeholder()
}
