mod config;
mod paths;
mod state;
mod system;

pub use config::{
    AppearanceConfig,
    BackgroundConfig,
    BarConfig,
    IntegrationCommands,
    ShellConfig,
    ShellConfigSection,
    load_or_create_config,
    persist_config,
};
pub use paths::{
    action_mailbox_path,
    config_dir,
    config_file_path,
    state_dir,
    xdg_config_home,
    xdg_state_home,
};
pub use state::{
    ActiveWindowSummary,
    BatterySummary,
    MediaSummary,
    NetworkSummary,
    NotificationSummary,
    PlaybackStatus,
    QuickSettingsSummary,
    ShellAction,
    ShellCapabilities,
    ShellSnapshot,
    ShellUiState,
    WorkspaceSummary,
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
