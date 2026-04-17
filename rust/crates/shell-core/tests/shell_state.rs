use shell_core::{
    ActiveWindowSummary,
    AppEntrySummary,
    BatterySummary,
    DockItemSummary,
    MediaSummary,
    MissionControlWorkspaceSummary,
    NetworkSummary,
    NotificationItemSummary,
    NotificationSummary,
    PlaybackStatus,
    QuickSettingsSummary,
    ShellCapabilities,
    ShellSnapshot,
    WindowSummary,
    WorkspaceSummary,
};

#[test]
fn placeholder_snapshot_exposes_hyprland_defaults() {
    let snapshot = ShellSnapshot::placeholder();

    assert_eq!(snapshot.compositor_name(), "Hyprland");
    assert_eq!(snapshot.active_workspace_name(), "Desktop");
    assert_eq!(
        snapshot.workspaces(),
        &[
            WorkspaceSummary::with_state(1, "Desktop", true, 2),
            WorkspaceSummary::with_state(2, "Studio", false, 2),
            WorkspaceSummary::with_state(3, "Comms", false, 1),
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
        None,
        Vec::<AppEntrySummary>::new(),
        Vec::<DockItemSummary>::new(),
        Vec::<WindowSummary>::new(),
        Vec::<MissionControlWorkspaceSummary>::new(),
        MediaSummary::new("", "", "", PlaybackStatus::Unknown),
        BatterySummary::new(0, false),
        NetworkSummary::new("", ""),
        NotificationSummary::new(0, "", ""),
        Vec::<NotificationItemSummary>::new(),
        QuickSettingsSummary::new(0, 0),
        ShellCapabilities::detect(),
    );

    assert_eq!(snapshot.compositor_name(), "Unknown compositor");
    assert_eq!(snapshot.active_workspace_name(), "workspace:unknown");
}
