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
};

#[test]
fn placeholder_snapshot_exposes_hyprland_defaults() {
    let snapshot = ShellSnapshot::placeholder();

    assert_eq!(snapshot.compositor_name(), "Hyprland");
    assert_eq!(snapshot.active_workspace_name(), "1:web");
    assert_eq!(
        snapshot.workspaces(),
        &[
            WorkspaceSummary::with_state(1, "1:web", true, 3),
            WorkspaceSummary::with_state(2, "2:code", false, 5),
            WorkspaceSummary::with_state(3, "3:chat", false, 2),
        ]
    );
}

#[test]
fn active_workspace_falls_back_when_missing() {
    let snapshot = ShellSnapshot::new(
        None,
        vec![],
        None,
        ActiveWindowSummary::new("", ""),
        MediaSummary::new("", "", "", PlaybackStatus::Unknown),
        BatterySummary::new(0, false),
        NetworkSummary::new("", ""),
        NotificationSummary::new(0, "", ""),
        QuickSettingsSummary::new(0, 0),
        ShellCapabilities::detect(),
    );

    assert_eq!(snapshot.compositor_name(), "Unknown compositor");
    assert_eq!(snapshot.active_workspace_name(), "workspace:unknown");
}
