use shell_core::{ShellSnapshot, WorkspaceSummary};

#[test]
fn placeholder_snapshot_exposes_hyprland_defaults() {
    let snapshot = ShellSnapshot::placeholder();

    assert_eq!(snapshot.compositor_name(), "Hyprland");
    assert_eq!(snapshot.active_workspace_name(), "1:web");
    assert_eq!(
        snapshot.workspaces(),
        &[WorkspaceSummary::new(1, "1:web"), WorkspaceSummary::new(2, "2:code")]
    );
}

#[test]
fn active_workspace_falls_back_when_missing() {
    let snapshot = ShellSnapshot::new(None, vec![], None);

    assert_eq!(snapshot.compositor_name(), "Unknown compositor");
    assert_eq!(snapshot.active_workspace_name(), "workspace:unknown");
}
