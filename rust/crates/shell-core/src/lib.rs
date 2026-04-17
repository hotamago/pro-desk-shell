mod config;
mod desktop;
mod paths;
mod state;
mod system;

pub use config::{
    load_or_create_config, persist_config, AppearanceConfig, BackgroundConfig, BarConfig,
    DockConfig, IntegrationCommands, LauncherConfig, MenuBarConfig, ShellConfig,
    ShellConfigSection,
};
pub use desktop::{
    match_window_class_to_app_id, parse_desktop_entry, sanitize_exec_command, search_app_entries,
};
pub use paths::{
    action_mailbox_path, config_dir, config_file_path, desktop_applications_dirs, icon_search_dirs,
    state_dir, xdg_config_home, xdg_data_dirs, xdg_data_home, xdg_state_home,
};
pub use state::{
    build_notification_summary, derive_dock_items, group_windows_by_workspace, reduce_ui_state,
    take_action_request, write_action_request, ActiveWindowSummary, AppEntrySummary,
    BatterySummary, DockItemSummary, MediaSummary, MissionControlWorkspaceSummary, NetworkSummary,
    NotificationItemSummary, NotificationSummary, PlaybackStatus, QuickSettingsSummary,
    ShellAction, ShellCapabilities, ShellSnapshot, ShellUiState, WindowSummary, WorkspaceSummary,
};
pub use system::{
    parse_brightnessctl_machine_output, parse_nmcli_active_wifi, parse_playerctl_metadata_output,
    parse_upower_output, parse_wpctl_volume_output,
};
