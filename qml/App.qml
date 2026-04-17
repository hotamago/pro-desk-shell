import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ProDeskShell
import io.hotamago.shell

ApplicationWindow {
    id: root

    width: 1600
    height: 960
    visible: true
    color: "transparent"
    title: "Pro Desk Shell"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property bool systemMenuOpen: false
    property bool overlayOpen: shellState.launcher_open
                               || systemMenuOpen
                               || shellState.quick_settings_open
                               || shellState.notifications_open
                               || shellState.overview_open

    function closeOverlays() {
        systemMenuOpen = false
        shellState.close_transient_surfaces()
    }

    function toggleSystemMenu() {
        const nextState = !systemMenuOpen
        closeOverlays()
        systemMenuOpen = nextState
    }

    function toggleLauncherSurface() {
        systemMenuOpen = false
        shellState.toggle_launcher()
    }

    function toggleOverviewSurface() {
        systemMenuOpen = false
        shellState.toggle_overview()
    }

    function toggleQuickSettingsSurface() {
        systemMenuOpen = false
        shellState.toggle_quick_settings()
    }

    function toggleNotificationSurface() {
        systemMenuOpen = false
        shellState.toggle_notifications()
    }

    ShellTheme {
        id: theme
        accentColor: shellState.accent_color
    }

    ShellState {
        id: shellState
    }

    Component.onCompleted: {
        shellState.refresh_shell()
        shellState.update_launcher_query("")
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeOverlays()
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: root.toggleLauncherSurface()
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: root.toggleOverviewSurface()
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: root.toggleSystemMenu()
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            shellState.poll_action_mailbox()
            shellState.refresh_shell()
        }
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#d7e4f5" }
                GradientStop { position: 0.52; color: "#eef3fb" }
                GradientStop { position: 1.0; color: "#dbe8f8" }
            }
        }

        Rectangle {
            width: 460
            height: 460
            radius: 230
            x: -40
            y: 140
            color: "#6bc8ff22"
        }

        Rectangle {
            width: 520
            height: 520
            radius: 260
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -120
            anchors.topMargin: -80
            color: "#ffffff66"
        }

        Rectangle {
            width: 640
            height: 300
            radius: 150
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -80
            color: "#ffffff44"
        }

        Image {
            anchors.fill: parent
            source: shellState.wallpaper_path.length > 0 ? "file://" + shellState.wallpaper_path : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: source.toString().length > 0 && status === Image.Ready
            opacity: 0.46
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: root.overlayOpen
        z: 10
        onClicked: root.closeOverlays()
    }

    MenuBar {
        id: menuBar
        z: 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 22
        theme: theme
        shellState: shellState
        onSystemMenuRequested: root.toggleSystemMenu()
        onLauncherRequested: root.toggleLauncherSurface()
        onNotificationsRequested: root.toggleNotificationSurface()
        onQuickSettingsRequested: root.toggleQuickSettingsSurface()
    }

    Dock {
        id: dock
        z: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        width: Math.min(parent.width - 120, implicitWidth)
        itemsJson: shellState.dock_items_json
        theme: theme
        shellState: shellState
        autoHide: shellState.dock_auto_hide
        showRunningIndicators: shellState.dock_show_running_indicators
        magnification: shellState.dock_magnification
    }

    SystemMenu {
        z: 30
        anchors.top: menuBar.bottom
        anchors.left: parent.left
        anchors.topMargin: 18
        anchors.leftMargin: 22
        width: 390
        height: Math.min(parent.height - dock.height - menuBar.height - 84, 760)
        open: root.systemMenuOpen
        theme: theme
        shellState: shellState
        onCloseRequested: root.systemMenuOpen = false
    }

    Spotlight {
        z: 30
        anchors.fill: parent
        open: shellState.launcher_open
        resultsJson: shellState.search_results_json
        theme: theme
        shellState: shellState
    }

    ControlCenter {
        z: 30
        anchors.top: menuBar.bottom
        anchors.right: parent.right
        anchors.bottom: dock.top
        anchors.topMargin: 18
        anchors.rightMargin: 22
        anchors.bottomMargin: 18
        width: 360
        open: shellState.quick_settings_open
        theme: theme
        shellState: shellState
    }

    NotificationCenter {
        z: 30
        anchors.top: menuBar.bottom
        anchors.right: parent.right
        anchors.bottom: dock.top
        anchors.topMargin: 18
        anchors.rightMargin: 22
        anchors.bottomMargin: 18
        width: 380
        open: shellState.notifications_open
        notificationsJson: shellState.notification_items_json
        theme: theme
        shellState: shellState
    }

    MissionControl {
        z: 25
        anchors.fill: parent
        open: shellState.overview_open
        workspacesJson: shellState.mission_control_json
        theme: theme
        shellState: shellState
    }
}
