mod desktop;
mod config;
mod paths;
mod state;
mod system;

pub use config::{
    AppearanceConfig,
    BackgroundConfig,
    BarConfig,
    DockConfig,
    IntegrationCommands,
    LauncherConfig,
    MenuBarConfig,
    ShellConfig,
    ShellConfigSection,
    load_or_create_config,
    persist_config,
};
pub use paths::{
    action_mailbox_path,
    config_dir,
    config_file_path,
    desktop_applications_dirs,
    state_dir,
    xdg_config_home,
    xdg_data_dirs,
    xdg_data_home,
    xdg_state_home,
};
pub use desktop::{
    match_window_class_to_app_id,
    parse_desktop_entry,
    sanitize_exec_command,
    search_app_entries,
};
pub use state::{
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
    ShellAction,
    ShellCapabilities,
    ShellSnapshot,
    ShellUiState,
    WindowSummary,
    WorkspaceSummary,
    build_notification_summary,
    derive_dock_items,
    group_windows_by_workspace,
    reduce_ui_state,
    take_action_request,
    write_action_request,
};
pub use system::{
    parse_brightnessctl_machine_output,
    parse_nmcli_active_wifi,
    parse_playerctl_metadata_output,
    parse_upower_output,
    parse_wpctl_volume_output,
};
