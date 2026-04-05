import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ProDeskShell
import io.hotamago.shell 1.0

ApplicationWindow {
    id: root

    readonly property bool useLayerShell: typeof shellUseLayerShell === "boolean" ? shellUseLayerShell : false

    width: 1480
    height: shellState.panel_height
    visible: true
    color: useLayerShell ? "transparent" : "#090d13"
    flags: useLayerShell ? Qt.FramelessWindowHint : Qt.Window
    title: "Pro Desk Shell"

    ShellState {
        id: shellState
    }

    Timer {
        interval: 4500
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: shellState.refresh_shell()
    }

    Timer {
        interval: 300
        repeat: true
        running: true
        onTriggered: shellState.poll_action_mailbox()
    }

    TopBar {
        anchors.fill: parent
        shellState: shellState
        useLayerShell: root.useLayerShell
    }

    Window {
        id: launcherWindow
        transientParent: root
        visible: shellState.launcher_open
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"
        width: 920
        height: 620
        x: root.x + Math.max(24, (root.width - width) / 2)
        y: root.y + root.height + 22

        LauncherPanel {
            anchors.fill: parent
            shellState: shellState
        }
    }

    Window {
        id: quickSettingsWindow
        transientParent: root
        visible: shellState.quick_settings_open
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"
        width: 380
        height: 540
        x: root.x + Math.max(24, root.width - width - 30)
        y: root.y + root.height + 18

        QuickSettingsPanel {
            anchors.fill: parent
            shellState: shellState
        }
    }

    Window {
        id: notificationsWindow
        transientParent: root
        visible: shellState.notifications_open
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"
        width: 400
        height: 460
        x: root.x + Math.max(24, root.width - width - 430)
        y: root.y + root.height + 18

        NotificationPanel {
            anchors.fill: parent
            shellState: shellState
        }
    }

    Window {
        id: wallpaperWindow
        transientParent: root
        visible: shellState.wallpaper_selector_open
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"
        width: 420
        height: 500
        x: root.x + 26
        y: root.y + root.height + 18

        WallpaperPanel {
            anchors.fill: parent
            shellState: shellState
        }
    }

    Window {
        id: sessionWindow
        transientParent: root
        visible: shellState.session_open
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"
        width: 520
        height: 300
        x: root.x + Math.max(24, (root.width - width) / 2)
        y: root.y + root.height + 48

        SessionPanel {
            anchors.fill: parent
            shellState: shellState
        }
    }

    SettingsWindow {
        shellState: shellState
        x: root.x + Math.max(40, (root.width - width) / 2)
        y: root.y + root.height + 16
        visible: shellState.settings_open
    }
}
