use std::process::Command;

use cxx_qt::CxxQtType;
use cxx_qt_lib::{QList, QString, QStringList};
#[allow(unused_imports)]
use core::pin::Pin;
use shell_core::{
    ShellAction,
    ShellConfig,
    ShellSnapshot,
    ShellUiState,
    config_file_path,
    load_or_create_config,
    persist_config,
    reduce_ui_state,
    state_dir,
    take_action_request,
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
        #[qproperty(String, media_title)]
        #[qproperty(String, media_artist)]
        #[qproperty(bool, media_playing)]
        #[qproperty(String, network_name)]
        #[qproperty(String, network_state)]
        #[qproperty(i32, battery_percent)]
        #[qproperty(bool, battery_charging)]
        #[qproperty(i32, notification_count)]
        #[qproperty(String, latest_notification_title)]
        #[qproperty(String, latest_notification_body)]
        #[qproperty(i32, volume_percent)]
        #[qproperty(i32, brightness_percent)]
        #[qproperty(bool, has_hyprland)]
        #[qproperty(bool, has_playerctl)]
        #[qproperty(bool, has_brightnessctl)]
        #[qproperty(bool, has_nmcli)]
        #[qproperty(bool, has_upower)]
        #[qproperty(bool, launcher_open)]
        #[qproperty(bool, overview_open)]
        #[qproperty(bool, notifications_open)]
        #[qproperty(bool, quick_settings_open)]
        #[qproperty(bool, wallpaper_selector_open)]
        #[qproperty(bool, session_open)]
        #[qproperty(bool, settings_open)]
        #[qproperty(bool, transparency_enabled)]
        #[qproperty(bool, bar_dense)]
        #[qproperty(String, accent_color)]
        #[qproperty(String, accent_color_secondary)]
        #[qproperty(String, accent_color_tertiary)]
        #[qproperty(String, theme_name)]
        #[qproperty(String, wallpaper_path)]
        #[qproperty(String, terminal_command)]
        #[qproperty(String, config_path)]
        #[qproperty(String, state_path)]
        #[qproperty(i32, panel_height)]
        #[qproperty(String, status_line)]
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
        fn toggle_wallpaper_selector(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_session(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn toggle_settings(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn request_lock(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn restart_shell(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn close_transient_surfaces(self: Pin<&mut ShellState>);

        #[qinvokable]
        fn set_transparency_preference(self: Pin<&mut ShellState>, enabled: bool);

        #[qinvokable]
        fn set_bar_dense_preference(self: Pin<&mut ShellState>, enabled: bool);

        #[qinvokable]
        fn set_terminal_command_value(self: Pin<&mut ShellState>, value: String);

        #[qinvokable]
        fn set_wallpaper_path_value(self: Pin<&mut ShellState>, value: String);

        #[qinvokable]
        fn set_accent_color_value(self: Pin<&mut ShellState>, value: String);

        #[qinvokable]
        fn set_theme_name_value(self: Pin<&mut ShellState>, value: String);
    }
}

pub struct ShellStateRust {
    workspace_labels: QStringList,
    compositor_name: String,
    active_workspace: String,
    active_window_title: String,
    active_window_class: String,
    media_title: String,
    media_artist: String,
    media_playing: bool,
    network_name: String,
    network_state: String,
    battery_percent: i32,
    battery_charging: bool,
    notification_count: i32,
    latest_notification_title: String,
    latest_notification_body: String,
    volume_percent: i32,
    brightness_percent: i32,
    has_hyprland: bool,
    has_playerctl: bool,
    has_brightnessctl: bool,
    has_nmcli: bool,
    has_upower: bool,
    launcher_open: bool,
    overview_open: bool,
    notifications_open: bool,
    quick_settings_open: bool,
    wallpaper_selector_open: bool,
    session_open: bool,
    settings_open: bool,
    transparency_enabled: bool,
    bar_dense: bool,
    accent_color: String,
    accent_color_secondary: String,
    accent_color_tertiary: String,
    theme_name: String,
    wallpaper_path: String,
    terminal_command: String,
    config_path: String,
    state_path: String,
    panel_height: i32,
    status_line: String,
    config: ShellConfig,
    ui_state: ShellUiState,
}

impl Default for ShellStateRust {
    fn default() -> Self {
        let config = load_or_create_config().unwrap_or_else(|_| ShellConfig::default());
        let snapshot = shell_hyprland::bootstrap_snapshot();
        Self::from_runtime(config, snapshot)
    }
}

impl ShellStateRust {
    fn from_runtime(config: ShellConfig, snapshot: ShellSnapshot) -> Self {
        let workspace_labels = to_qstring_list(snapshot.workspace_labels());

        Self {
            workspace_labels,
            compositor_name: snapshot.compositor_name().to_owned(),
            active_workspace: snapshot.active_workspace_name().to_owned(),
            active_window_title: snapshot.active_window().title().to_owned(),
            active_window_class: snapshot.active_window().class_name().to_owned(),
            media_title: snapshot.media().title().to_owned(),
            media_artist: snapshot.media().artist().to_owned(),
            media_playing: snapshot.media().status() == shell_core::PlaybackStatus::Playing,
            network_name: snapshot.network().name().to_owned(),
            network_state: snapshot.network().state_label().to_owned(),
            battery_percent: snapshot.battery().percent(),
            battery_charging: snapshot.battery().is_charging(),
            notification_count: snapshot.notifications().unread_count(),
            latest_notification_title: snapshot.notifications().latest_title().to_owned(),
            latest_notification_body: snapshot.notifications().latest_body().to_owned(),
            volume_percent: snapshot.quick_settings().volume_percent(),
            brightness_percent: snapshot.quick_settings().brightness_percent(),
            has_hyprland: snapshot.capabilities().has_hyprland,
            has_playerctl: snapshot.capabilities().has_playerctl,
            has_brightnessctl: snapshot.capabilities().has_brightnessctl,
            has_nmcli: snapshot.capabilities().has_nmcli,
            has_upower: snapshot.capabilities().has_upower,
            launcher_open: false,
            overview_open: false,
            notifications_open: false,
            quick_settings_open: false,
            wallpaper_selector_open: false,
            session_open: false,
            settings_open: false,
            transparency_enabled: config.appearance.enable_transparency,
            bar_dense: config.bar.dense,
            accent_color: config.appearance.accent_color.clone(),
            accent_color_secondary: config.appearance.accent_color_secondary.clone(),
            accent_color_tertiary: config.appearance.accent_color_tertiary.clone(),
            theme_name: config.appearance.theme_name.clone(),
            wallpaper_path: config.background.wallpaper_path.clone(),
            terminal_command: config.integrations.terminal.clone(),
            config_path: config_file_path().display().to_string(),
            state_path: state_dir().display().to_string(),
            panel_height: config.bar.panel_height,
            status_line: build_status_line(&snapshot),
            config,
            ui_state: ShellUiState::default(),
        }
    }
}

impl ffi::ShellState {
    fn refresh_shell(mut self: core::pin::Pin<&mut Self>) {
        match shell_hyprland::load_snapshot() {
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

    fn toggle_wallpaper_selector(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::WallpaperToggle);
    }

    fn toggle_session(mut self: core::pin::Pin<&mut Self>) {
        self.as_mut().apply_action(ShellAction::SessionToggle);
    }

    fn toggle_settings(mut self: core::pin::Pin<&mut Self>) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.settings_open = !rust.settings_open;
        let settings_open = rust.settings_open;
        self.as_mut().set_settings_open(settings_open);
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
            rust.settings_open = false;
        }
        self.as_mut().sync_ui_state();
        self.as_mut().set_settings_open(false);
    }

    fn set_transparency_preference(mut self: core::pin::Pin<&mut Self>, enabled: bool) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.appearance.enable_transparency = enabled;
        self.as_mut().set_transparency_enabled(enabled);
        self.as_mut().persist_current_config();
    }

    fn set_bar_dense_preference(mut self: core::pin::Pin<&mut Self>, enabled: bool) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.bar.dense = enabled;
        self.as_mut().set_bar_dense(enabled);
        self.as_mut().persist_current_config();
    }

    fn set_terminal_command_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.integrations.terminal = value.clone();
        self.as_mut().set_terminal_command(value);
        self.as_mut().persist_current_config();
    }

    fn set_wallpaper_path_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.background.wallpaper_path = value.clone();
        self.as_mut().set_wallpaper_path(value);
        self.as_mut().persist_current_config();
    }

    fn set_accent_color_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.appearance.accent_color = value.clone();
        self.as_mut().set_accent_color(value);
        self.as_mut().persist_current_config();
    }

    fn set_theme_name_value(mut self: core::pin::Pin<&mut Self>, value: String) {
        let rust = self.as_mut().rust_mut().get_mut();
        rust.config.appearance.theme_name = value.clone();
        self.as_mut().set_theme_name(value);
        self.as_mut().persist_current_config();
    }
}

impl ffi::ShellState {
    fn apply_snapshot(mut self: core::pin::Pin<&mut Self>, snapshot: &ShellSnapshot) {
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
        self.as_mut().set_media_title(snapshot.media().title().to_owned());
        self.as_mut()
            .set_media_artist(snapshot.media().artist().to_owned());
        self.as_mut().set_media_playing(
            snapshot.media().status() == shell_core::PlaybackStatus::Playing,
        );
        self.as_mut()
            .set_network_name(snapshot.network().name().to_owned());
        self.as_mut()
            .set_network_state(snapshot.network().state_label().to_owned());
        self.as_mut().set_battery_percent(snapshot.battery().percent());
        self.as_mut()
            .set_battery_charging(snapshot.battery().is_charging());
        self.as_mut()
            .set_notification_count(snapshot.notifications().unread_count());
        self.as_mut()
            .set_latest_notification_title(snapshot.notifications().latest_title().to_owned());
        self.as_mut()
            .set_latest_notification_body(snapshot.notifications().latest_body().to_owned());
        self.as_mut()
            .set_volume_percent(snapshot.quick_settings().volume_percent());
        self.as_mut()
            .set_brightness_percent(snapshot.quick_settings().brightness_percent());
        self.as_mut()
            .set_has_hyprland(snapshot.capabilities().has_hyprland);
        self.as_mut()
            .set_has_playerctl(snapshot.capabilities().has_playerctl);
        self.as_mut()
            .set_has_brightnessctl(snapshot.capabilities().has_brightnessctl);
        self.as_mut().set_has_nmcli(snapshot.capabilities().has_nmcli);
        self.as_mut().set_has_upower(snapshot.capabilities().has_upower);
        self.as_mut().set_status_line(build_status_line(snapshot));
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
        let (
            launcher_open,
            overview_open,
            notifications_open,
            quick_settings_open,
            wallpaper_selector_open,
            session_open,
        ) = {
            let rust = state.rust();
            (
                rust.ui_state.launcher_open,
                rust.ui_state.overview_open,
                rust.ui_state.notifications_open,
                rust.ui_state.quick_settings_open,
                rust.ui_state.wallpaper_selector_open,
                rust.ui_state.session_open,
            )
        };

        self.as_mut().set_launcher_open(launcher_open);
        self.as_mut().set_overview_open(overview_open);
        self.as_mut().set_notifications_open(notifications_open);
        self.as_mut().set_quick_settings_open(quick_settings_open);
        self.as_mut()
            .set_wallpaper_selector_open(wallpaper_selector_open);
        self.as_mut().set_session_open(session_open);
    }

    fn persist_current_config(mut self: core::pin::Pin<&mut Self>) {
        let config = self.as_ref().rust().config.clone();
        if let Err(error) = persist_config(&config) {
            self.as_mut()
                .set_status_line(format!("Config save failed: {error}"));
        }
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

fn build_status_line(snapshot: &ShellSnapshot) -> String {
    if snapshot.capabilities().has_hyprland {
        format!(
            "Linked to {} with {} workspaces live.",
            snapshot.compositor_name(),
            snapshot.workspaces().len()
        )
    } else {
        String::from("Running in preview mode. Launch inside Hyprland for live compositor data.")
    }
}
