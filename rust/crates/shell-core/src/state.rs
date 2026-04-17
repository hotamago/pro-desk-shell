use std::collections::{BTreeMap, BTreeSet};
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

    pub fn with_state(
        id: i32,
        name: impl Into<String>,
        is_active: bool,
        window_count: usize,
    ) -> Self {
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

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct AppEntrySummary {
    app_id: String,
    display_name: String,
    icon_name: String,
    icon_path: String,
    exec_command: String,
    keywords: Vec<String>,
    startup_wm_class: String,
}

impl AppEntrySummary {
    pub fn new(
        app_id: impl Into<String>,
        display_name: impl Into<String>,
        icon_name: impl Into<String>,
        exec_command: impl Into<String>,
        keywords: Vec<String>,
        startup_wm_class: impl Into<String>,
    ) -> Self {
        Self {
            app_id: app_id.into(),
            display_name: display_name.into(),
            icon_name: icon_name.into(),
            icon_path: String::new(),
            exec_command: exec_command.into(),
            keywords,
            startup_wm_class: startup_wm_class.into(),
        }
    }

    pub fn app_id(&self) -> &str {
        &self.app_id
    }

    pub fn display_name(&self) -> &str {
        &self.display_name
    }

    pub fn icon_name(&self) -> &str {
        &self.icon_name
    }

    pub fn icon_path(&self) -> &str {
        &self.icon_path
    }

    pub fn exec_command(&self) -> &str {
        &self.exec_command
    }

    pub fn keywords(&self) -> &[String] {
        &self.keywords
    }

    pub fn startup_wm_class(&self) -> &str {
        &self.startup_wm_class
    }

    pub fn with_icon_path(mut self, icon_path: impl Into<String>) -> Self {
        self.icon_path = icon_path.into();
        self
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct DockItemSummary {
    app_id: String,
    display_name: String,
    icon_name: String,
    icon_path: String,
    pinned: bool,
    running: bool,
    active: bool,
    window_count: usize,
}

impl DockItemSummary {
    pub fn new(
        app_id: impl Into<String>,
        display_name: impl Into<String>,
        icon_name: impl Into<String>,
        pinned: bool,
        running: bool,
        active: bool,
        window_count: usize,
    ) -> Self {
        Self {
            app_id: app_id.into(),
            display_name: display_name.into(),
            icon_name: icon_name.into(),
            icon_path: String::new(),
            pinned,
            running,
            active,
            window_count,
        }
    }

    pub fn app_id(&self) -> &str {
        &self.app_id
    }

    pub fn display_name(&self) -> &str {
        &self.display_name
    }

    pub fn icon_name(&self) -> &str {
        &self.icon_name
    }

    pub fn icon_path(&self) -> &str {
        &self.icon_path
    }

    pub fn is_pinned(&self) -> bool {
        self.pinned
    }

    pub fn is_running(&self) -> bool {
        self.running
    }

    pub fn is_active(&self) -> bool {
        self.active
    }

    pub fn window_count(&self) -> usize {
        self.window_count
    }

    pub fn with_icon_path(mut self, icon_path: impl Into<String>) -> Self {
        self.icon_path = icon_path.into();
        self
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct WindowSummary {
    window_id: String,
    title: String,
    class_name: String,
    app_id: String,
    workspace_id: i32,
    workspace_name: String,
    focused: bool,
    floating: bool,
    fullscreen: bool,
}

impl WindowSummary {
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        window_id: impl Into<String>,
        title: impl Into<String>,
        class_name: impl Into<String>,
        app_id: impl Into<String>,
        workspace_id: i32,
        workspace_name: impl Into<String>,
        focused: bool,
        floating: bool,
        fullscreen: bool,
    ) -> Self {
        Self {
            window_id: window_id.into(),
            title: title.into(),
            class_name: class_name.into(),
            app_id: app_id.into(),
            workspace_id,
            workspace_name: workspace_name.into(),
            focused,
            floating,
            fullscreen,
        }
    }

    pub fn window_id(&self) -> &str {
        &self.window_id
    }

    pub fn title(&self) -> &str {
        &self.title
    }

    pub fn class_name(&self) -> &str {
        &self.class_name
    }

    pub fn app_id(&self) -> &str {
        &self.app_id
    }

    pub fn workspace_id(&self) -> i32 {
        self.workspace_id
    }

    pub fn workspace_name(&self) -> &str {
        &self.workspace_name
    }

    pub fn is_focused(&self) -> bool {
        self.focused
    }

    pub fn is_floating(&self) -> bool {
        self.floating
    }

    pub fn is_fullscreen(&self) -> bool {
        self.fullscreen
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct MissionControlWorkspaceSummary {
    workspace_id: i32,
    workspace_name: String,
    is_active: bool,
    windows: Vec<WindowSummary>,
}

impl MissionControlWorkspaceSummary {
    pub fn new(
        workspace_id: i32,
        workspace_name: impl Into<String>,
        is_active: bool,
        windows: Vec<WindowSummary>,
    ) -> Self {
        Self {
            workspace_id,
            workspace_name: workspace_name.into(),
            is_active,
            windows,
        }
    }

    pub fn workspace_id(&self) -> i32 {
        self.workspace_id
    }

    pub fn workspace_name(&self) -> &str {
        &self.workspace_name
    }

    pub fn is_active(&self) -> bool {
        self.is_active
    }

    pub fn windows(&self) -> &[WindowSummary] {
        &self.windows
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
pub struct NotificationItemSummary {
    notification_id: String,
    app_name: String,
    title: String,
    body: String,
    timestamp: String,
    urgency: String,
    dismissed: bool,
}

impl NotificationItemSummary {
    pub fn new(
        notification_id: impl Into<String>,
        app_name: impl Into<String>,
        title: impl Into<String>,
        body: impl Into<String>,
        timestamp: impl Into<String>,
        urgency: impl Into<String>,
        dismissed: bool,
    ) -> Self {
        Self {
            notification_id: notification_id.into(),
            app_name: app_name.into(),
            title: title.into(),
            body: body.into(),
            timestamp: timestamp.into(),
            urgency: urgency.into(),
            dismissed,
        }
    }

    pub fn notification_id(&self) -> &str {
        &self.notification_id
    }

    pub fn app_name(&self) -> &str {
        &self.app_name
    }

    pub fn title(&self) -> &str {
        &self.title
    }

    pub fn body(&self) -> &str {
        &self.body
    }

    pub fn timestamp(&self) -> &str {
        &self.timestamp
    }

    pub fn urgency(&self) -> &str {
        &self.urgency
    }

    pub fn is_dismissed(&self) -> bool {
        self.dismissed
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct NotificationSummary {
    unread_count: i32,
    latest_title: String,
    latest_body: String,
}

impl NotificationSummary {
    pub fn new(
        unread_count: i32,
        latest_title: impl Into<String>,
        latest_body: impl Into<String>,
    ) -> Self {
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
    active_app_id: Option<String>,
    app_catalog: Vec<AppEntrySummary>,
    dock_items: Vec<DockItemSummary>,
    windows: Vec<WindowSummary>,
    mission_control_workspaces: Vec<MissionControlWorkspaceSummary>,
    media: MediaSummary,
    battery: BatterySummary,
    network: NetworkSummary,
    notifications: NotificationSummary,
    notification_history: Vec<NotificationItemSummary>,
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
        active_app_id: Option<String>,
        app_catalog: Vec<AppEntrySummary>,
        dock_items: Vec<DockItemSummary>,
        windows: Vec<WindowSummary>,
        mission_control_workspaces: Vec<MissionControlWorkspaceSummary>,
        media: MediaSummary,
        battery: BatterySummary,
        network: NetworkSummary,
        notifications: NotificationSummary,
        notification_history: Vec<NotificationItemSummary>,
        quick_settings: QuickSettingsSummary,
        capabilities: ShellCapabilities,
    ) -> Self {
        Self {
            compositor_name,
            workspaces,
            active_workspace,
            active_window,
            active_app_id,
            app_catalog,
            dock_items,
            windows,
            mission_control_workspaces,
            media,
            battery,
            network,
            notifications,
            notification_history,
            quick_settings,
            capabilities,
        }
    }

    pub fn placeholder() -> Self {
        let capabilities = ShellCapabilities::detect();
        let workspaces = vec![
            WorkspaceSummary::with_state(1, "Desktop", true, 2),
            WorkspaceSummary::with_state(2, "Studio", false, 2),
            WorkspaceSummary::with_state(3, "Comms", false, 1),
        ];
        let app_catalog = vec![
            AppEntrySummary::new(
                "org.gnome.Nautilus",
                "Files",
                "folder",
                "nautilus --new-window",
                vec![String::from("files"), String::from("finder")],
                "org.gnome.Nautilus",
            ),
            AppEntrySummary::new(
                "firefox",
                "Firefox",
                "firefox",
                "firefox",
                vec![String::from("browser"), String::from("web")],
                String::from("firefox"),
            ),
            AppEntrySummary::new(
                "kitty",
                "Terminal",
                "terminal",
                "kitty -1",
                vec![String::from("terminal"), String::from("shell")],
                String::from("kitty"),
            ),
            AppEntrySummary::new(
                "code",
                "Code",
                "code",
                "code",
                vec![String::from("editor"), String::from("dev")],
                String::from("code"),
            ),
        ];
        let windows = vec![
            WindowSummary::new(
                "preview-firefox",
                "Product board",
                "firefox",
                "firefox",
                1,
                "Desktop",
                true,
                false,
                false,
            ),
            WindowSummary::new(
                "preview-kitty",
                "shell-dev",
                "kitty",
                "kitty",
                2,
                "Studio",
                false,
                false,
                false,
            ),
            WindowSummary::new(
                "preview-code",
                "pro-desk-shell",
                "code",
                "code",
                2,
                "Studio",
                false,
                false,
                false,
            ),
        ];
        let dock_items = derive_dock_items(
            &[
                String::from("org.gnome.Nautilus"),
                String::from("firefox"),
                String::from("kitty"),
                String::from("code"),
            ],
            &app_catalog,
            &windows,
        );
        let notification_history = vec![
            NotificationItemSummary::new(
                "preview-1",
                "Shell",
                "Shell ready",
                "The rewritten shell bridge is feeding the new desktop surfaces.",
                "Now",
                "normal",
                false,
            ),
            NotificationItemSummary::new(
                "preview-2",
                "Hyprland",
                "Preview mode",
                "Run inside Hyprland to turn placeholder windows into live compositor state.",
                "2m ago",
                "low",
                false,
            ),
        ];

        Self::new(
            Some(String::from("Hyprland")),
            workspaces.clone(),
            Some(String::from("Desktop")),
            ActiveWindowSummary::with_state("Product board", "firefox", false, false),
            Some(String::from("firefox")),
            app_catalog.clone(),
            dock_items,
            windows.clone(),
            group_windows_by_workspace(&workspaces, &windows),
            MediaSummary::new(
                "playerctl",
                "Night Drive",
                "Shell Signals",
                PlaybackStatus::Playing,
            ),
            BatterySummary::new(84, true),
            NetworkSummary::new("Studio Mesh", "Connected"),
            build_notification_summary(&notification_history),
            notification_history,
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

    pub fn active_app_id(&self) -> Option<&str> {
        self.active_app_id.as_deref()
    }

    pub fn workspaces(&self) -> &[WorkspaceSummary] {
        &self.workspaces
    }

    pub fn active_window(&self) -> &ActiveWindowSummary {
        &self.active_window
    }

    pub fn app_catalog(&self) -> &[AppEntrySummary] {
        &self.app_catalog
    }

    pub fn dock_items(&self) -> &[DockItemSummary] {
        &self.dock_items
    }

    pub fn windows(&self) -> &[WindowSummary] {
        &self.windows
    }

    pub fn mission_control_workspaces(&self) -> &[MissionControlWorkspaceSummary] {
        &self.mission_control_workspaces
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

    pub fn notification_history(&self) -> &[NotificationItemSummary] {
        &self.notification_history
    }

    pub fn notification_history_mut(&mut self) -> &mut Vec<NotificationItemSummary> {
        &mut self.notification_history
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

    pub fn refresh_notification_summary(&mut self) {
        self.notifications = build_notification_summary(&self.notification_history);
    }
}

pub fn derive_dock_items(
    pinned_app_ids: &[String],
    app_catalog: &[AppEntrySummary],
    windows: &[WindowSummary],
) -> Vec<DockItemSummary> {
    let app_catalog_map = app_catalog
        .iter()
        .map(|app| (app.app_id().to_owned(), app))
        .collect::<BTreeMap<_, _>>();
    let mut ordered_app_ids = Vec::new();
    let mut seen_app_ids = BTreeSet::new();

    for pinned_app_id in pinned_app_ids {
        if seen_app_ids.insert(pinned_app_id.clone()) {
            ordered_app_ids.push(pinned_app_id.clone());
        }
    }

    let mut running_counts = BTreeMap::<String, usize>::new();
    let mut active_app_ids = BTreeSet::<String>::new();
    for window in windows {
        let app_id = if window.app_id().trim().is_empty() {
            window.class_name().to_owned()
        } else {
            window.app_id().to_owned()
        };
        *running_counts.entry(app_id.clone()).or_insert(0) += 1;
        if window.is_focused() {
            active_app_ids.insert(app_id.clone());
        }
        if seen_app_ids.insert(app_id.clone()) {
            ordered_app_ids.push(app_id);
        }
    }

    ordered_app_ids
        .into_iter()
        .map(|app_id| {
            let app = app_catalog_map.get(&app_id);
            let display_name = app
                .map(|entry| entry.display_name().to_owned())
                .unwrap_or_else(|| app_id.clone());
            let icon_name = app
                .map(|entry| entry.icon_name().to_owned())
                .unwrap_or_default();
            let icon_path = app
                .map(|entry| entry.icon_path().to_owned())
                .unwrap_or_default();
            let window_count = running_counts.get(&app_id).copied().unwrap_or_default();
            DockItemSummary::new(
                app_id.clone(),
                display_name,
                icon_name,
                pinned_app_ids.iter().any(|candidate| candidate == &app_id),
                window_count > 0,
                active_app_ids.contains(&app_id),
                window_count,
            )
            .with_icon_path(icon_path)
        })
        .collect()
}

pub fn group_windows_by_workspace(
    workspaces: &[WorkspaceSummary],
    windows: &[WindowSummary],
) -> Vec<MissionControlWorkspaceSummary> {
    let mut grouped = workspaces
        .iter()
        .map(|workspace| {
            let windows = windows
                .iter()
                .filter(|window| window.workspace_id() == workspace.id())
                .cloned()
                .collect::<Vec<_>>();
            MissionControlWorkspaceSummary::new(
                workspace.id(),
                workspace.name().to_owned(),
                workspace.is_active(),
                windows,
            )
        })
        .collect::<Vec<_>>();

    for window in windows {
        let exists = grouped
            .iter()
            .any(|workspace| workspace.workspace_id() == window.workspace_id());
        if !exists {
            grouped.push(MissionControlWorkspaceSummary::new(
                window.workspace_id(),
                window.workspace_name().to_owned(),
                false,
                vec![window.clone()],
            ));
        }
    }

    grouped.sort_by_key(MissionControlWorkspaceSummary::workspace_id);
    grouped
}

pub fn build_notification_summary(history: &[NotificationItemSummary]) -> NotificationSummary {
    let unread_count = history.iter().filter(|item| !item.is_dismissed()).count() as i32;
    let latest = history
        .iter()
        .find(|item| !item.is_dismissed())
        .or_else(|| history.first());

    match latest {
        Some(item) => NotificationSummary::new(unread_count, item.title(), item.body()),
        None => NotificationSummary::new(0, "No notifications", "The shell is quiet right now."),
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
            ui_state.notifications_open = false;
            ui_state.quick_settings_open = false;
        }
        ShellAction::OverviewToggle => {
            ui_state.overview_open = !ui_state.overview_open;
            ui_state.launcher_open = false;
            ui_state.notifications_open = false;
            ui_state.quick_settings_open = false;
        }
        ShellAction::NotificationsToggle => {
            ui_state.notifications_open = !ui_state.notifications_open;
            ui_state.quick_settings_open = false;
            ui_state.launcher_open = false;
        }
        ShellAction::QuickSettingsToggle => {
            ui_state.quick_settings_open = !ui_state.quick_settings_open;
            ui_state.notifications_open = false;
            ui_state.launcher_open = false;
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

#[cfg(test)]
mod tests {
    use super::{
        build_notification_summary, derive_dock_items, group_windows_by_workspace, AppEntrySummary,
        NotificationItemSummary, WindowSummary, WorkspaceSummary,
    };

    #[test]
    fn derives_dock_state_from_pins_and_windows() {
        let apps = vec![
            AppEntrySummary::new(
                "firefox",
                "Firefox",
                "firefox",
                "firefox",
                Vec::new(),
                "firefox",
            )
            .with_icon_path("/tmp/firefox.png"),
            AppEntrySummary::new(
                "kitty",
                "Terminal",
                "terminal",
                "kitty",
                Vec::new(),
                "kitty",
            ),
        ];
        let windows = vec![WindowSummary::new(
            "1", "project", "firefox", "firefox", 1, "Desktop", true, false, false,
        )];

        let dock = derive_dock_items(&[String::from("kitty")], &apps, &windows);
        assert_eq!(dock.len(), 2);
        assert!(dock
            .iter()
            .any(|item| item.app_id() == "kitty" && item.is_pinned()));
        assert!(dock
            .iter()
            .any(|item| item.app_id() == "firefox" && item.is_running()));
        assert_eq!(
            dock.iter()
                .find(|item| item.app_id() == "firefox")
                .map(|item| item.icon_path()),
            Some("/tmp/firefox.png")
        );
    }

    #[test]
    fn groups_windows_for_mission_control() {
        let workspaces = vec![WorkspaceSummary::with_state(1, "Desktop", true, 1)];
        let windows = vec![WindowSummary::new(
            "1", "project", "kitty", "kitty", 1, "Desktop", true, false, false,
        )];

        let groups = group_windows_by_workspace(&workspaces, &windows);
        assert_eq!(groups.len(), 1);
        assert_eq!(groups[0].windows().len(), 1);
    }

    #[test]
    fn builds_notification_summary_from_history() {
        let history = vec![NotificationItemSummary::new(
            "1",
            "Shell",
            "Ready",
            "Everything is up.",
            "Now",
            "normal",
            false,
        )];

        let summary = build_notification_summary(&history);
        assert_eq!(summary.unread_count(), 1);
        assert_eq!(summary.latest_title(), "Ready");
    }
}
