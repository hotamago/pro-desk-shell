import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

FrostedPanel {
    id: root

    property var theme
    property var shellState
    property bool compactMode: shellState ? shellState.menu_bar_compact_mode : false

    signal systemMenuRequested()
    signal launcherRequested()
    signal notificationsRequested()
    signal quickSettingsRequested()

    radius: compactMode ? 22 : 26
    padding: compactMode ? 10 : 14
    fillColor: "#d6f7fbff"
    borderColor: "#96ffffff"
    implicitHeight: compactMode ? 56 : 68

    RowLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 10

            GlassButton {
                theme: root.theme
                text: "menu"
                accented: true
                onClicked: root.systemMenuRequested()
            }

            GlassButton {
                theme: root.theme
                text: "spotlight"
                quiet: true
                onClicked: root.launcherRequested()
            }

            Label {
                text: root.shellState.active_workspace.length > 0 ? root.shellState.active_workspace : "Desktop"
                color: root.theme.textMuted
                font.family: root.theme.displayFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.shellState.active_window_title.length > 0
                      ? root.shellState.active_window_title
                      : "Pro Desk Shell"
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Label {
                visible: !root.compactMode
                Layout.alignment: Qt.AlignHCenter
                text: root.shellState.active_window_class.length > 0
                      ? root.shellState.active_window_class
                      : root.shellState.status_line
                color: root.theme.textSoft
                font.family: root.theme.bodyFont
                font.pixelSize: 11
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 10

            Label {
                text: root.shellState.network_name.length > 0 ? root.shellState.network_name : "network"
                color: root.theme.textMuted
                font.family: root.theme.bodyFont
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            Label {
                text: root.shellState.battery_percent + "%"
                color: root.theme.textMuted
                font.family: root.theme.bodyFont
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            Label {
                id: clockLabel
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
                text: Qt.formatDateTime(new Date(), "ddd  hh:mm")
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "ddd  hh:mm")
            }

            GlassButton {
                theme: root.theme
                text: "notify " + root.shellState.notification_count
                onClicked: root.notificationsRequested()
            }

            GlassButton {
                theme: root.theme
                text: "control"
                onClicked: root.quickSettingsRequested()
            }
        }
    }
}
