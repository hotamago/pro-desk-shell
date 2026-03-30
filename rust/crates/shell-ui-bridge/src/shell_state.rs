#[cxx_qt::bridge]
mod ffi {
    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(String, compositor_name)]
        #[qproperty(String, active_workspace)]
        type ShellState = super::ShellStateRust;
    }
}

pub struct ShellStateRust {
    compositor_name: String,
    active_workspace: String,
}

impl Default for ShellStateRust {
    fn default() -> Self {
        let snapshot = shell_core::ShellSnapshot::placeholder();

        Self {
            compositor_name: snapshot.compositor_name().to_owned(),
            active_workspace: snapshot.active_workspace_name().to_owned(),
        }
    }
}

impl cxx_qt::Initialize for ffi::ShellState {
    fn initialize(self: core::pin::Pin<&mut Self>) {}
}
