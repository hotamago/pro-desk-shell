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

    property bool overlayOpen: shellState.launcher_open
                               || shellState.quick_settings_open
                               || shellState.notifications_open
                               || shellState.overview_open

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
        onActivated: shellState.close_transient_surfaces()
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: shellState.toggle_launcher()
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: shellState.toggle_overview()
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
    }

    MouseArea {
        anchors.fill: parent
        visible: root.overlayOpen
        z: 10
        onClicked: shellState.close_transient_surfaces()
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
        magnification: shellState.dock_magnification
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
