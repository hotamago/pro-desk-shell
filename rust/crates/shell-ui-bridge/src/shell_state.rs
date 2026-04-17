use std::process::Command;

#[allow(unused_imports)]
use core::pin::Pin;
use cxx_qt::CxxQtType;
use cxx_qt_lib::{QList, QString, QStringList};
use shell_core::{
    config_file_path, load_or_create_config, persist_config, reduce_ui_state, search_app_entries,
    state_dir, take_action_request, NotificationItemSummary, ShellAction, ShellConfig,
    ShellSnapshot, ShellUiState,
};

#[cxx_qt::bridge]
mod ffi {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
        include!("cxx-qt-lib/qstringlist.h");
        type QStringList = cxx_qt_lib::QStringList;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QStringList, workspace_labels)]
        #[qproperty(String, compositor_name)]
        #[qproperty(String, active_workspace)]
        #[qproperty(String, active_window_title)]
        #[qproperty(String, active_window_class)]
        #[qproperty(String, active_app_id)]
        #[qproperty(String, media_title)]
        #[qproperty(String, media_artist)]
        #[qproperty(bool, media_playing)]
        #[qproperty(String, network_name)]
        #[qproperty(String, network_state)]
        #[qproperty(i32, battery_percent)]
        #[qproperty(bool, battery_charging)]
        #[qproperty(i32, notification_count)]
        #[qproperty(i32, volume_percent)]
        #[qproperty(i32, brightness_percent)]
        #[qproperty(bool, has_hyprland)]
        #[qproperty(bool, has_playerctl)]
        #[qproperty(bool, has_wpctl)]
        #[qproperty(bool, has_brightnessctl)]
        #[qproperty(bool, has_nmcli)]
        #[qproperty(bool, has_upower)]
        #[qproperty(bool, launcher_open)]
        #[qproperty(bool, overview_open)]
        #[qproperty(bool, notifications_open)]
        #[qproperty(bool, quick_settings_open)]
        #[qproperty(String, accent_color)]
        #[qproperty(String, style_preset)]
        #[qproperty(bool, menu_bar_compact_mode)]
        #[qproperty(String, wallpaper_path)]
        #[qproperty(String, terminal_command)]
        #[qproperty(String, config_path)]
        #[qproperty(String, state_path)]
        #[qproperty(String, status_line)]
        #[qproperty(String, app_catalog_json)]
        #[qproperty(String, dock_items_json)]
        #[qproperty(String, window_items_json)]
        #[qproperty(String, mission_control_json)]
        #[qproperty(String, notification_items_json)]
        #[qproperty(String, search_results_json)]
        #[qproperty(String, launcher_query)]
        #[qproperty(bool, dock_auto_hide)]
        #[qproperty(bool, dock_show_running_indicators)]
        #[qproperty(i32, dock_magnification)]
        #[qproperty(i32, launcher_max_results)]
        type ShellState = super::ShellStateRust;

        #[qinvokable]
        fn refresh_shell(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn poll_action_mailbox(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_launcher(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_overview(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_notifications(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_quick_settings(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn request_lock(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn restart_shell(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn close_transient_surfaces(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn update_launcher_query(self: Pin<&mut ShellState>, value: String);

        #[qinvokable]
        fn activate_dock_item(self: Pin<&mut ShellState>, app_id: String);

        #[qinvokable]
        fn launch_app(self: Pin<&mut ShellState>, app_id: String);

        #[qinvokable]
        fn toggle_dock_pin(self: Pin<&mut ShellState>, app_id: String);

        #[qinvokable]
        fn activate_workspace(self: Pin<&mut ShellState>, target: String);

        #[qinvokable]
        fn focus_window(self: Pin<&mut ShellState>, window_id: String);

        #[qinvokable]
        fn dismiss_notification(self: Pin<&mut ShellState>, notification_id: String);

        #[qinvokable]
        fn request_volume_percent(self: Pin<&mut ShellState>, value: i32);

        #[qinvokable]
        fn request_brightness_percent(self: Pin<&mut ShellState>, value: i32);

        #[qinvokable]
        fn update_menu_bar_compact_mode(self: Pin<&mut ShellState>, value: bool);

        #[qinvokable]
        fn update_dock_auto_hide(self: Pin<&mut ShellState>, value: bool);

        #[qinvokable]
        fn update_dock_show_running_indicators(self: Pin<&mut ShellState>, value: bool);

        #[qinvokable]
        fn update_dock_magnification_value(self: Pin<&mut ShellState>, value: i32);

        #[qinvokable]
        fn update_launcher_max_results_value(self: Pin<&mut ShellState>, value: i32);

        #[qinvokable]
        fn update_terminal_command_value(self: Pin<&mut ShellState>, value: String);

        #[qinvokable]
        fn update_wallpaper_path_value(self: Pin<&mut ShellState>, value: String);
    }
}

pub struct ShellStateRust {
    workspace_labels: QStringList,
    compositor_name: String,
    active_workspace: String,
    active_window_title: String,
    active_window_class: String,
    active_app_id: String,
    media_title: String,
    media_artist: String,
    media_playing: bool,
    network_name: String,
    network_state: String,
    battery_percent: i32,
    battery_charging: bool,
    notification_count: i32,
    volume_percent: i32,
    brightness_percent: i32,
    has_hyprland: bool,
    has_playerctl: bool,
    has_wpctl: bool,
    has_brightnessctl: bool,
    has_nmcli: bool,
    has_upower: bool,
    launcher_open: bool,
    overview_open: bool,
    notifications_open: bool,
    quick_settings_open: bool,
    accent_color: String,
    style_preset: String,
    menu_bar_compact_mode: bool,
    wallpaper_path: String,
    terminal_command: String,
    config_path: String,
    state_path: String,
    status_line: String,
    app_catalog_json: String,
    dock_items_json: String,
    window_items_json: String,
    mission_control_json: String,
    notification_items_json: String,
    search_results_json: String,
    launcher_query: String,
    dock_auto_hide: bool,
    dock_show_running_indicators: bool,
    dock_magnification: i32,
    launcher_max_results: i32,
    config: ShellConfig,
    ui_state: ShellUiState,
    runtime_snapshot: ShellSnapshot,
}

impl Default for ShellStateRust {
    fn default() -> Self {
        let config = load_or_create_config().unwrap_or_else(|_| ShellConfig::default());
        let snapshot = shell_hyprland::bootstrap_snapshot(&config);
        Self::from_runtime(config, snapshot)
    }
}

impl ShellStateRust {
    fn from_runtime(config: ShellConfig, snapshot: ShellSnapshot) -> Self {
        let workspace_labels = to_qstring_list(snapshot.workspace_labels());
        let app_catalog_json = to_json(snapshot.app_catalog());
        let dock_items_json = to_json(snapshot.dock_items());
        let window_items_json = to_json(snapshot.windows());
        let mission_control_json = to_json(snapshot.mission_control_workspaces());
        let notification_items_json = to_json(snapshot.notification_history());
        let launcher_query = String::new();
        let search_results_json = to_json(&search_app_entries(
            snapshot.app_catalog(),
            &launcher_query,
            config.launcher.max_results,
        ));

        Self {
            workspace_labels,
            compositor_name: snapshot.compositor_name().to_owned(),
            active_workspace: snapshot.active_workspace_name().to_owned(),
            active_window_title: snapshot.active_window().title().to_owned(),
            active_window_class: snapshot.active_window().class_name().to_owned(),
            active_app_id: snapshot.active_app_id().unwrap_or_default().to_owned(),
            media_title: snapshot.media().title().to_owned(),
            media_artist: snapshot.media().artist().to_owned(),
            media_playing: snapshot.media().status() == shell_core::PlaybackStatus::Playing,
            network_name: snapshot.network().name().to_owned(),
            network_state: snapshot.network().state_label().to_owned(),
            battery_percent: snapshot.battery().percent(),
            battery_charging: snapshot.battery().is_charging(),
            notification_count: snapshot.notifications().unread_count(),
            volume_percent: snapshot.quick_settings().volume_percent(),
            brightness_percent: snapshot.quick_settings().brightness_percent(),
            has_hyprland: snapshot.capabilities().has_hyprland,
            has_playerctl: snapshot.capabilities().has_playerctl,
            has_wpctl: snapshot.capabilities().has_wpctl,
            has_brightnessctl: snapshot.capabilities().has_brightnessctl,
            has_nmcli: snapshot.capabilities().has_nmcli,
            has_upower: snapshot.capabilities().has_upower,
            launcher_open: false,
            overview_open: false,
            notifications_open: false,
            quick_settings_open: false,
            accent_color: config.appearance.accent_color.clone(),
            style_preset: config.appearance.style_preset.clone(),
            menu_bar_compact_mode: config.menu_bar.compact_mode,
            wallpaper_path: config.background.wallpaper_path.clone(),
            terminal_command: config.integrations.terminal.clone(),
            config_path: config_file_path().display().to_string(),
            state_path: state_dir().display().to_string(),
            status_line: build_status_line(&snapshot),
            app_catalog_json,
            dock_items_json,
            window_items_json,
            mission_control_json,
            notification_items_json,
            search_results_json,
            launcher_query,
            dock_auto_hide: config.dock.auto_hide,
            dock_show_running_indicators: config.dock.show_running_indicators,
            dock_magnification: config.dock.magnification,
            launcher_max_results: config.launcher.max_results as i32,
            config,
            ui_state: ShellUiState::default(),
            runtime_snapshot: snapshot,
        }
    }
}

impl ffi::ShellState {
    fn refresh_shell(mut self: core::pin::Pin<&mut Self>) {
        let config = self.as_ref().rust().config.clone();
        match shell_hyprland::load_snapshot(&config) {
            Ok(snapshot) => self.as_mut().apply_snapshot(&snapshot),
            Err(error) => {
                self.as_mut()
                    .set_status_line(format!("Shell snapshot fallback active: {error}"));
                let snapshot = ShellSnapshot::placeholder();
                self.as_mut().apply_snapshot(&snapshot);
            }
        }
    }

    fn poll_action_mailbox(mut self: core::pin::Pin<&mut Self>) {
        match take_action_request() {
            Ok(Some(action)) => self.as_mut().apply_action(action),
            Ok(None) => {}
            Err(error) => self
                .as_mut()
                .set_status_line(format!("Mailbox poll failed: {error}")),
        }
    }

    fn toggle_launcher(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::LauncherToggle);
    }

    fn toggle_overview(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::OverviewToggle);
    }

    fn toggle_notifications(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::NotificationsToggle);
    }

    fn toggle_quick_settings(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::QuickSettingsToggle);
    }

    fn request_lock(mut self: core::pin::Pin<&mut Self>) {
        let status = Command::new("loginctl").arg("lock-session").status();
        match status {
            Ok(exit_status) if exit_status.success() => {
                self.as_mut()
                    .set_status_line(String::from("Session lock request sent."));
            }
            Ok(exit_status) => {
                self.as_mut().set_status_line(format!(
                    "loginctl lock-session exited with status {:?}.",
                    exit_status.code()
                ));
            }
            Err(error) => self
                .as_mut()
                .set_status_line(format!("Could not invoke loginctl: {error}")),
        }
    }

    fn restart_shell(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().close_transient_surfaces();
        self.as_mut().refresh_shell();
    }

    fn close_transient_surfaces(mut self: core::pin::Pin<&mut Self>) {
        {
            let rust = self.as_mut().rust_mut().get_mut();
            rust.ui_state = ShellUiState::default();
            rust.launcher_query.clear();
        }
        self.as_mut().sync_ui_state();
        self.as_mut().set_launcher_query(String::new());
        self.as_mut().refresh_search_results();
    }

    fn update_launcher_query(mut self: core::pin::Pin<&mut Self>, value: String) {
        self.as_mut().rust_mut().get_mut().launcher_query = value.clone();
        self.as_mut().set_launcher_query(value);
        self.as_mut().refresh_search_results();
    }

    fn activate_dock_item(mut self: core::pin::Pin<&mut Self>, app_id: String) {
        let target_window = self
            .as_ref()
            .rust()
            .runtime_snapshot
            .windows()
            .iter()
            .find(|window| window.app_id() == app_id)
            .map(|window| window.window_id().to_owned());

        match target_window {
            Some(window_id) => self.as_mut().focus_window(window_id),
            None => self.as_mut().launch_app(app_id),
        }
    }

    fn launch_app(mut self: core::pin::Pin<&mut Self>, app_id: String) {
        match shell_hyprland::launch_app(&app_id) {
            Ok(()) => {
                self.as_mut()
                    .set_status_line(format!("Launch request sent for '{app_id}'."));
                self.as_mut().close_transient_surfaces();
            }
            Err(error) => self.as_mut().set_status_line(error),
        }
    }

    fn toggle_dock_pin(mut self: core::pin::Pin<&mut Self>, app_id: String) {
        {
            let rust = self.as_mut().rust_mut().get_mut();
            let pins = &mut rust.config.dock.pinned_apps;
            if let Some(index) = pins.iter().position(|candidate| candidate == &app_id) {
                pins.remove(index);
            } else {
                pins.push(app_id.clone());
            }
        }

        self.as_mut().persist_current_config();
        self.as_mut().refresh_shell();
        self.as_mut()
            .set_status_line(format!("Dock pin state updated for '{app_id}'."));
    }

    fn activate_workspace(mut self: core::pin::Pin<&mut Self>, target: String) {
        match shell_hyprland::activate_workspace(&target) {
            Ok(()) => {
                self.as_mut()
                    .set_status_line(format!("Workspace activation sent for '{target}'."));
                self.as_mut().close_transient_surfaces();
            }
            Err(error) => self.as_mut().set_status_line(error),
        }
    }

    fn focus_window(mut self: core::pin::Pin<&mut Self>, window_id: String) {
        match shell_hyprland::focus_window(&window_id) {
            Ok(()) => {
                self.as_mut()
                    .set_status_line(format!("Focus request sent for '{window_id}'."));
                self.as_mut().close_transient_surfaces();
            }
            Err(error) => self.as_mut().set_status_line(error),
        }
    }

    fn dismiss_notification(mut self: core::pin::Pin<&mut Self>, notification_id: String) {
        {
            let rust = self.as_mut().rust_mut().get_mut();
            for item in rust.runtime_snapshot.notification_history_mut().iter_mut() {
                if item.notification_id() == notification_id {
                    *item = NotificationItemSummary::new(
                        item.notification_id().to_owned(),
                        item.app_name().to_owned(),
                        item.title().to_owned(),
                        item.body().to_owned(),
                        item.timestamp().to_owned(),
                        item.urgency().to_owned(),
                        true,
                    );
                }
            }
            rust.runtime_snapshot.refresh_notification_summary();
        }

        self.as_mut().refresh_serialized_models();
        let unread_count = self
            .as_ref()
            .rust()
            .runtime_snapshot
            .notifications()
            .unread_count();
        self.as_mut().set_notification_count(unread_count);
    }

    fn request_volume_percent(mut self: core::pin::Pin<&mut Self>, value: i32) {
        match shell_hyprland::set_volume_percent(value) {
            Ok(()) => {
                self.as_mut().set_volume_percent(value.clamp(0, 150));
                self.as_mut()
                    .set_status_line(format!("Volume target set to {}%.", value.clamp(0, 150)));
            }
            Err(error) => self.as_mut().set_status_line(error),
        }
    }

    fn request_brightness_percent(mut self: core::pin::Pin<&mut Self>, value: i32) {
        match shell_hyprland::set_brightness_percent(value) {
            Ok(()) => {
                self.as_mut().set_brightness_percent(value.clamp(1, 100));
                self.as_mut().set_status_line(format!(
                    "Brightness target set to {}%.",
                    value.clamp(1, 100)
                ));
            }
            Err(error) => self.as_mut().set_status_line(error),
        }
    }

    fn update_menu_bar_compact_mode(mut self: core::pin::Pin<&mut Self>, value: bool) {
        self.as_mut()
            .rust_mut()
            .get_mut()
            .config
            .menu_bar
            .compact_mode = value;
        self.as_mut().set_menu_bar_compact_mode(value);
        self.as_mut().persist_current_config();
    }

    fn update_dock_auto_hide(mut self: core::pin::Pin<&mut Self>, value: bool) {
        self.as_mut().rust_mut().get_mut().config.dock.auto_hide = value;
        self.as_mut().set_dock_auto_hide(value);
        self.as_mut().persist_current_config();
    }

    fn update_dock_show_running_indicators(mut self: core::pin::Pin<&mut Self>, value: bool) {
        self.as_mut()
            .rust_mut()
            .get_mut()
            .config
            .dock
            .show_running_indicators = value;
        self.as_mut().set_dock_show_running_indicators(value);
        self.as_mut().persist_current_config();
    }

    fn update_dock_magnification_value(mut self: core::pin::Pin<&mut Self>, value: i32) {
        let clamped = value.clamp(0, 40);
        self.as_mut().rust_mut().get_mut().config.dock.magnification = clamped;
        self.as_mut().set_dock_magnification(clamped);
        self.as_mut().persist_current_config();
    }

    fn update_launcher_max_results_value(mut self: core::pin::Pin<&mut Self>, value: i32) {
        let clamped = value.clamp(4, 16);
        self.as_mut()
            .rust_mut()
            .get_mut()
            .config
            .launcher
            .max_results = clamped as usize;
        self.as_mut().set_launcher_max_results(clamped);
        self.as_mut().persist_current_config();
        self.as_mut().refresh_search_results();
    }

    fn update_terminal_command_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let trimmed = value.trim().to_owned();
        self.as_mut()
            .rust_mut()
            .get_mut()
            .config
            .integrations
            .terminal = trimmed.clone();
        self.as_mut().set_terminal_command(trimmed);
        self.as_mut().persist_current_config();
    }

    fn update_wallpaper_path_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let trimmed = value.trim().to_owned();
        self.as_mut()
            .rust_mut()
            .get_mut()
            .config
            .background
            .wallpaper_path = trimmed.clone();
        self.as_mut().set_wallpaper_path(trimmed);
        self.as_mut().persist_current_config();
    }
}

impl ffi::ShellState {
    fn apply_snapshot(mut self: core::pin::Pin<&mut Self>, snapshot: &ShellSnapshot) {
        {
            let rust = self.as_mut().rust_mut().get_mut();
            rust.runtime_snapshot = snapshot.clone();
        }

        self.as_mut()
            .set_workspace_labels(to_qstring_list(snapshot.workspace_labels()));
        self.as_mut()
            .set_compositor_name(snapshot.compositor_name().to_owned());
        self.as_mut()
            .set_active_workspace(snapshot.active_workspace_name().to_owned());
        self.as_mut()
            .set_active_window_title(snapshot.active_window().title().to_owned());
        self.as_mut()
            .set_active_window_class(snapshot.active_window().class_name().to_owned());
        self.as_mut()
            .set_active_app_id(snapshot.active_app_id().unwrap_or_default().to_owned());
        self.as_mut()
            .set_media_title(snapshot.media().title().to_owned());
        self.as_mut()
            .set_media_artist(snapshot.media().artist().to_owned());
        self.as_mut()
            .set_media_playing(snapshot.media().status() == shell_core::PlaybackStatus::Playing);
        self.as_mut()
            .set_network_name(snapshot.network().name().to_owned());
        self.as_mut()
            .set_network_state(snapshot.network().state_label().to_owned());
        self.as_mut()
            .set_battery_percent(snapshot.battery().percent());
        self.as_mut()
            .set_battery_charging(snapshot.battery().is_charging());
        self.as_mut()
            .set_notification_count(snapshot.notifications().unread_count());
        self.as_mut()
            .set_volume_percent(snapshot.quick_settings().volume_percent());
        self.as_mut()
            .set_brightness_percent(snapshot.quick_settings().brightness_percent());
        self.as_mut()
            .set_has_hyprland(snapshot.capabilities().has_hyprland);
        self.as_mut()
            .set_has_playerctl(snapshot.capabilities().has_playerctl);
        self.as_mut()
            .set_has_wpctl(snapshot.capabilities().has_wpctl);
        self.as_mut()
            .set_has_brightnessctl(snapshot.capabilities().has_brightnessctl);
        self.as_mut()
            .set_has_nmcli(snapshot.capabilities().has_nmcli);
        self.as_mut()
            .set_has_upower(snapshot.capabilities().has_upower);
        self.as_mut().set_status_line(build_status_line(snapshot));
        self.as_mut().refresh_serialized_models();
    }

    fn apply_action(mut self: core::pin::Pin<&mut Self>, action: ShellAction) {
        match action {
            ShellAction::Lock => {
                self.as_mut().request_lock();
                return;
            }
            ShellAction::RestartShell => {
                self.as_mut().restart_shell();
                return;
            }
            _ => {
                let rust = self.as_mut().rust_mut().get_mut();
                reduce_ui_state(&mut rust.ui_state, action);
            }
        }

        self.as_mut().sync_ui_state();
    }

    fn sync_ui_state(mut self: core::pin::Pin<&mut Self>) {
        let state = self.as_ref();
        let (launcher_open, overview_open, notifications_open, quick_settings_open) = {
            let rust = state.rust();
            (
                rust.ui_state.launcher_open,
                rust.ui_state.overview_open,
                rust.ui_state.notifications_open,
                rust.ui_state.quick_settings_open,
            )
        };

        self.as_mut().set_launcher_open(launcher_open);
        self.as_mut().set_overview_open(overview_open);
        self.as_mut().set_notifications_open(notifications_open);
        self.as_mut().set_quick_settings_open(quick_settings_open);
    }

    fn persist_current_config(mut self: core::pin::Pin<&mut Self>) {
        let config = self.as_ref().rust().config.clone();
        if let Err(error) = persist_config(&config) {
            self.as_mut()
                .set_status_line(format!("Config save failed: {error}"));
        }
    }

    fn refresh_serialized_models(mut self: core::pin::Pin<&mut Self>) {
        let (
            app_catalog_json,
            dock_items_json,
            window_items_json,
            mission_control_json,
            notification_items_json,
        ) = {
            let snapshot = self.as_ref().rust().runtime_snapshot.clone();
            (
                to_json(snapshot.app_catalog()),
                to_json(snapshot.dock_items()),
                to_json(snapshot.windows()),
                to_json(snapshot.mission_control_workspaces()),
                to_json(snapshot.notification_history()),
            )
        };

        self.as_mut().set_app_catalog_json(app_catalog_json);
        self.as_mut().set_dock_items_json(dock_items_json);
        self.as_mut().set_window_items_json(window_items_json);
        self.as_mut().set_mission_control_json(mission_control_json);
        self.as_mut()
            .set_notification_items_json(notification_items_json);
        self.as_mut().refresh_search_results();
    }

    fn refresh_search_results(mut self: core::pin::Pin<&mut Self>) {
        let search_results_json = {
            let query = self.as_ref().rust().launcher_query.clone();
            let max_results = self.as_ref().rust().config.launcher.max_results;
            let apps = self.as_ref().rust().runtime_snapshot.app_catalog().to_vec();
            let results = search_app_entries(&apps, &query, max_results);
            to_json(&results)
        };

        self.as_mut().set_search_results_json(search_results_json);
    }
}

impl cxx_qt::Initialize for ffi::ShellState {
    fn initialize(self: core::pin::Pin<&mut Self>) {
        self.sync_ui_state();
    }
}

fn to_qstring_list(strings: Vec<String>) -> QStringList {
    let items = strings
        .into_iter()
        .map(QString::from)
        .collect::<Vec<QString>>();
    let list: QList<QString> = items.into();
    QStringList::from(&list)
}

fn to_json<T: serde::Serialize + ?Sized>(value: &T) -> String {
    serde_json::to_string(value).unwrap_or_else(|_| String::from("[]"))
}

fn build_status_line(snapshot: &ShellSnapshot) -> String {
    if snapshot.capabilities().has_hyprland {
        format!(
            "Linked to {} with {} workspaces, {} windows, and {} apps indexed.",
            snapshot.compositor_name(),
            snapshot.workspaces().len(),
            snapshot.windows().len(),
            snapshot.app_catalog().len()
        )
    } else {
        format!(
            "Running in preview mode with {} apps indexed for the new shell UI.",
            snapshot.app_catalog().len()
        )
    }
}
