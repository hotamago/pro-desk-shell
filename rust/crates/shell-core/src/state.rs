use std::fmt;
use std::fs;
use std::str::FromStr;

use serde::{Deserialize, Serialize};

use crate::paths::{action_mailbox_path, state_dir};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkspaceSummary {
    id: i32,
    name: String,
    is_active: bool,
    window_count: usize,
}

impl WorkspaceSummary {
    pub fn new(id: i32, name: impl Into<String>) -> Self {
        Self {
            id,
            name: name.into(),
            is_active: false,
            window_count: 0,
        }
    }

    pub fn with_state(id: i32, name: impl Into<String>, is_active: bool, window_count: usize) -> Self {
        Self {
            id,
            name: name.into(),
            is_active,
            window_count,
        }
    }

    pub fn id(&self) -> i32 {
        self.id
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn is_active(&self) -> bool {
        self.is_active
    }

    pub fn window_count(&self) -> usize {
        self.window_count
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ActiveWindowSummary {
    title: String,
    class_name: String,
    is_floating: bool,
    is_fullscreen: bool,
}

impl ActiveWindowSummary {
    pub fn new(title: impl Into<String>, class_name: impl Into<String>) -> Self {
        Self {
            title: title.into(),
            class_name: class_name.into(),
            is_floating: false,
            is_fullscreen: false,
        }
    }

    pub fn with_state(
        title: impl Into<String>,
        class_name: impl Into<String>,
        is_floating: bool,
        is_fullscreen: bool,
    ) -> Self {
        Self {
            title: title.into(),
            class_name: class_name.into(),
            is_floating,
            is_fullscreen,
        }
    }

    pub fn title(&self) -> &str {
        &self.title
    }

    pub fn class_name(&self) -> &str {
        &self.class_name
    }

    pub fn is_floating(&self) -> bool {
        self.is_floating
    }

    pub fn is_fullscreen(&self) -> bool {
        self.is_fullscreen
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum PlaybackStatus {
    Playing,
    Paused,
    Stopped,
    Unknown,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct MediaSummary {
    player_name: String,
    title: String,
    artist: String,
    status: PlaybackStatus,
}

impl MediaSummary {
    pub fn new(
        player_name: impl Into<String>,
        title: impl Into<String>,
        artist: impl Into<String>,
        status: PlaybackStatus,
    ) -> Self {
        Self {
            player_name: player_name.into(),
            title: title.into(),
            artist: artist.into(),
            status,
        }
    }

    pub fn player_name(&self) -> &str {
        &self.player_name
    }

    pub fn title(&self) -> &str {
        &self.title
    }

    pub fn artist(&self) -> &str {
        &self.artist
    }

    pub fn status(&self) -> PlaybackStatus {
        self.status
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct BatterySummary {
    percent: i32,
    is_charging: bool,
}

impl BatterySummary {
    pub fn new(percent: i32, is_charging: bool) -> Self {
        Self {
            percent,
            is_charging,
        }
    }

    pub fn percent(&self) -> i32 {
        self.percent
    }

    pub fn is_charging(&self) -> bool {
        self.is_charging
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct NetworkSummary {
    name: String,
    state_label: String,
}

impl NetworkSummary {
    pub fn new(name: impl Into<String>, state_label: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            state_label: state_label.into(),
        }
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn state_label(&self) -> &str {
        &self.state_label
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct NotificationSummary {
    unread_count: i32,
    latest_title: String,
    latest_body: String,
}

impl NotificationSummary {
    pub fn new(unread_count: i32, latest_title: impl Into<String>, latest_body: impl Into<String>) -> Self {
        Self {
            unread_count,
            latest_title: latest_title.into(),
            latest_body: latest_body.into(),
        }
    }

    pub fn unread_count(&self) -> i32 {
        self.unread_count
    }

    pub fn latest_title(&self) -> &str {
        &self.latest_title
    }

    pub fn latest_body(&self) -> &str {
        &self.latest_body
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct QuickSettingsSummary {
    volume_percent: i32,
    brightness_percent: i32,
}

impl QuickSettingsSummary {
    pub fn new(volume_percent: i32, brightness_percent: i32) -> Self {
        Self {
            volume_percent,
            brightness_percent,
        }
    }

    pub fn volume_percent(&self) -> i32 {
        self.volume_percent
    }

    pub fn brightness_percent(&self) -> i32 {
        self.brightness_percent
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ShellCapabilities {
    pub has_hyprland: bool,
    pub has_playerctl: bool,
    pub has_wpctl: bool,
    pub has_brightnessctl: bool,
    pub has_nmcli: bool,
    pub has_upower: bool,
}

impl ShellCapabilities {
    pub fn detect() -> Self {
        Self {
            has_hyprland: std::env::var_os("HYPRLAND_INSTANCE_SIGNATURE").is_some(),
            has_playerctl: command_exists("playerctl"),
            has_wpctl: command_exists("wpctl"),
            has_brightnessctl: command_exists("brightnessctl"),
            has_nmcli: command_exists("nmcli"),
            has_upower: command_exists("upower"),
        }
    }
}

fn command_exists(command: &str) -> bool {
    std::env::var_os("PATH")
        .map(|paths| std::env::split_paths(&paths).any(|path| path.join(command).exists()))
        .unwrap_or(false)
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ShellSnapshot {
    compositor_name: Option<String>,
    workspaces: Vec<WorkspaceSummary>,
    active_workspace: Option<String>,
    active_window: ActiveWindowSummary,
    media: MediaSummary,
    battery: BatterySummary,
    network: NetworkSummary,
    notifications: NotificationSummary,
    quick_settings: QuickSettingsSummary,
    capabilities: ShellCapabilities,
}

impl ShellSnapshot {
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        compositor_name: Option<String>,
        workspaces: Vec<WorkspaceSummary>,
        active_workspace: Option<String>,
        active_window: ActiveWindowSummary,
        media: MediaSummary,
        battery: BatterySummary,
        network: NetworkSummary,
        notifications: NotificationSummary,
        quick_settings: QuickSettingsSummary,
        capabilities: ShellCapabilities,
    ) -> Self {
        Self {
            compositor_name,
            workspaces,
            active_workspace,
            active_window,
            media,
            battery,
            network,
            notifications,
            quick_settings,
            capabilities,
        }
    }

    pub fn placeholder() -> Self {
        let capabilities = ShellCapabilities::detect();

        Self::new(
            Some(String::from("Hyprland")),
            vec![
                WorkspaceSummary::with_state(1, "1:web", true, 3),
                WorkspaceSummary::with_state(2, "2:code", false, 5),
                WorkspaceSummary::with_state(3, "3:chat", false, 2),
            ],
            Some(String::from("1:web")),
            ActiveWindowSummary::with_state("Pro Desk Shell Rebuild Board", "org.gnome.TextEditor", false, false),
            MediaSummary::new(
                "playerctl",
                "Night Drive",
                "Shell Signals",
                PlaybackStatus::Playing,
            ),
            BatterySummary::new(84, true),
            NetworkSummary::new("Studio Mesh", "Connected"),
            NotificationSummary::new(
                3,
                "Shell ready",
                "Core shell surfaces are connected to the Rust bridge.",
            ),
            QuickSettingsSummary::new(58, 72),
            capabilities,
        )
    }

    pub fn compositor_name(&self) -> &str {
        self.compositor_name
            .as_deref()
            .unwrap_or("Unknown compositor")
    }

    pub fn active_workspace_name(&self) -> &str {
        self.active_workspace
            .as_deref()
            .unwrap_or("workspace:unknown")
    }

    pub fn workspaces(&self) -> &[WorkspaceSummary] {
        &self.workspaces
    }

    pub fn active_window(&self) -> &ActiveWindowSummary {
        &self.active_window
    }

    pub fn media(&self) -> &MediaSummary {
        &self.media
    }

    pub fn battery(&self) -> &BatterySummary {
        &self.battery
    }

    pub fn network(&self) -> &NetworkSummary {
        &self.network
    }

    pub fn notifications(&self) -> &NotificationSummary {
        &self.notifications
    }

    pub fn quick_settings(&self) -> &QuickSettingsSummary {
        &self.quick_settings
    }

    pub fn capabilities(&self) -> &ShellCapabilities {
        &self.capabilities
    }

    pub fn workspace_labels(&self) -> Vec<String> {
        self.workspaces
            .iter()
            .map(|workspace| workspace.name().to_owned())
            .collect()
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ShellAction {
    LauncherToggle,
    OverviewToggle,
    NotificationsToggle,
    QuickSettingsToggle,
    WallpaperToggle,
    SessionToggle,
    Lock,
    RestartShell,
}

impl ShellAction {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::LauncherToggle => "launcher.toggle",
            Self::OverviewToggle => "overview.toggle",
            Self::NotificationsToggle => "notifications.toggle",
            Self::QuickSettingsToggle => "quick-settings.toggle",
            Self::WallpaperToggle => "wallpaper.toggle",
            Self::SessionToggle => "session.toggle",
            Self::Lock => "lock",
            Self::RestartShell => "restart-shell",
        }
    }
}

impl fmt::Display for ShellAction {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(self.as_str())
    }
}

impl FromStr for ShellAction {
    type Err = String;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value.trim() {
            "launcher.toggle" => Ok(Self::LauncherToggle),
            "overview.toggle" => Ok(Self::OverviewToggle),
            "notifications.toggle" => Ok(Self::NotificationsToggle),
            "quick-settings.toggle" => Ok(Self::QuickSettingsToggle),
            "wallpaper.toggle" => Ok(Self::WallpaperToggle),
            "session.toggle" => Ok(Self::SessionToggle),
            "lock" => Ok(Self::Lock),
            "restart-shell" => Ok(Self::RestartShell),
            other => Err(format!("Unknown shell action '{other}'.")),
        }
    }
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct ShellUiState {
    pub launcher_open: bool,
    pub overview_open: bool,
    pub notifications_open: bool,
    pub quick_settings_open: bool,
    pub wallpaper_selector_open: bool,
    pub session_open: bool,
}

pub fn reduce_ui_state(ui_state: &mut ShellUiState, action: ShellAction) {
    match action {
        ShellAction::LauncherToggle => {
            ui_state.launcher_open = !ui_state.launcher_open;
            ui_state.overview_open = false;
        }
        ShellAction::OverviewToggle => {
            ui_state.overview_open = !ui_state.overview_open;
            ui_state.launcher_open = false;
        }
        ShellAction::NotificationsToggle => {
            ui_state.notifications_open = !ui_state.notifications_open;
        }
        ShellAction::QuickSettingsToggle => {
            ui_state.quick_settings_open = !ui_state.quick_settings_open;
        }
        ShellAction::WallpaperToggle => {
            ui_state.wallpaper_selector_open = !ui_state.wallpaper_selector_open;
        }
        ShellAction::SessionToggle => {
            ui_state.session_open = !ui_state.session_open;
        }
        ShellAction::Lock | ShellAction::RestartShell => {}
    }
}

pub fn write_action_request(action: ShellAction) -> Result<(), String> {
    let directory = state_dir();
    fs::create_dir_all(&directory)
        .map_err(|error| format!("Could not create '{}': {error}", directory.display()))?;
    let mailbox = action_mailbox_path();
    fs::write(&mailbox, format!("{}\n", action.as_str()))
        .map_err(|error| format!("Could not write '{}': {error}", mailbox.display()))
}

pub fn take_action_request() -> Result<Option<ShellAction>, String> {
    let mailbox = action_mailbox_path();
    if !mailbox.exists() {
        return Ok(None);
    }

    let content = fs::read_to_string(&mailbox)
        .map_err(|error| format!("Could not read '{}': {error}", mailbox.display()))?;
    let trimmed = content.trim();
    let action = if trimmed.is_empty() {
        None
    } else {
        Some(ShellAction::from_str(trimmed)?)
    };

    fs::remove_file(&mailbox)
        .map_err(|error| format!("Could not clear '{}': {error}", mailbox.display()))?;
    Ok(action)
}
