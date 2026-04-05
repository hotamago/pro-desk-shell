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
        tintTop: "#182433"
        tintBottom: "#111922"
        borderTint: "#2a465c"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notification Center"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 19
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.shellState.notification_count + " runtime notices queued"
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                Button {
                    text: "Close"
                    onClicked: root.shellState.toggle_notifications()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 20
                color: "#13202d"
                border.width: 1
                border.color: "#284257"
                implicitHeight: 122

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Text {
                        text: root.shellState.latest_notification_title
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.shellState.latest_notification_body
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 20
                color: "#111a25"
                border.width: 1
                border.color: "#243a4c"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: "Signal board"
                        color: theme.textStrong
                        font.family: theme.bodyFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Compositor: " + root.shellState.compositor_name
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 12
                    }

                    Text {
                        text: "Workspace: " + root.shellState.active_workspace
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 12
                    }

                    Text {
                        text: "Config: " + root.shellState.config_path
                        color: theme.textDim
                        font.family: theme.monoFont
                        font.pixelSize: 10
                        wrapMode: Text.WrapAnywhere
                    }

                    Text {
                        text: "State: " + root.shellState.state_path
                        color: theme.textDim
                        font.family: theme.monoFont
                        font.pixelSize: 10
                        wrapMode: Text.WrapAnywhere
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Button {
                        text: "Refresh shell snapshot"
                        onClicked: root.shellState.refresh_shell()
                    }
                }
            }
        }
    }
}
