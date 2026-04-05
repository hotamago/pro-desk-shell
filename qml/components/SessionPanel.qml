import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState

    ShellTheme {
        id: theme
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#1b2530"
        tintBottom: "#10161d"
        borderTint: "#364b5d"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            Text {
                text: "Session Surface"
                color: theme.textStrong
                font.family: theme.titleFont
                font.pixelSize: 21
                font.weight: Font.DemiBold
            }

            Text {
                text: "Lock the session, refresh live shell state, or close transient surfaces."
                color: theme.textSoft
                font.family: theme.bodyFont
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Lock"
                    onClicked: root.shellState.request_lock()
                }

                Button {
                    text: "Refresh"
                    onClicked: root.shellState.restart_shell()
                }

                Button {
                    text: "Close panels"
                    onClicked: root.shellState.close_transient_surfaces()
                }

                Button {
                    text: "Quit app"
                    onClicked: Qt.quit()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 20
                color: "#121b24"
                border.width: 1
                border.color: "#28394a"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6

                    Text {
                        text: "Action mailbox"
                        color: theme.textStrong
                        font.family: theme.bodyFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Hyprland fragments can toggle launcher, overview, notifications, quick settings, wallpaper, session, lock, and restart-shell by writing stable action IDs into the Pro Desk Shell state mailbox."
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
