import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    readonly property var feed: [
        {
            title: root.shellState.latest_notification_title.length > 0 ? root.shellState.latest_notification_title : "Shell ready",
            body: root.shellState.latest_notification_body.length > 0 ? root.shellState.latest_notification_body : "Runtime notifications will land here as the shell gets richer services.",
            accent: "#59d3ff",
            tag: "Latest"
        },
        {
            title: "Network status",
            body: root.shellState.network_name + " / " + root.shellState.network_state,
            accent: "#7ef0bc",
            tag: "Network"
        },
        {
            title: "Power state",
            body: root.shellState.battery_percent + "% / " + (root.shellState.battery_charging ? "charging" : "steady drain"),
            accent: "#f0d18d",
            tag: "Battery"
        },
        {
            title: "Current focus",
            body: root.shellState.active_window_title,
            accent: "#ffaf72",
            tag: "Workspace"
        }
    ]

    ShellTheme {
        id: theme
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#15283c"
        tintBottom: "#0d1721"
        borderTint: "#325a79"
        glowTint: root.shellState.accent_color
        glowStrength: 0.11

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notification Center"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 24
                        font.weight: Font.Black
                    }

                    Text {
                        text: root.shellState.notification_count + " runtime notices queued"
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                ShellButton {
                    text: "Refresh"
                    compact: true
                    fill: "#173046"
                    borderColor: "#4a7ea3"
                    onClicked: root.shellState.refresh_shell()
                }

                ShellButton {
                    text: "Close"
                    compact: true
                    onClicked: root.shellState.toggle_notifications()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 24
                color: "#132436"
                border.width: 1
                border.color: "#31597a"
                implicitHeight: 118

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6

                    Text {
                        text: root.shellState.latest_notification_title
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 18
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

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: root.feed

                        delegate: Rectangle {
                            required property var modelData

                            width: parent.width
                            radius: 22
                            color: "#101a26"
                            border.width: 1
                            border.color: "#234155"
                            implicitHeight: 104

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 6
                                radius: 3
                                color: modelData.accent
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                anchors.leftMargin: 20
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: modelData.tag
                                        color: theme.textDim
                                        font.family: theme.monoFont
                                        font.pixelSize: 10
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.shellState.active_workspace
                                        color: theme.textFaint
                                        font.family: theme.monoFont
                                        font.pixelSize: 10
                                    }
                                }

                                Text {
                                    text: modelData.title
                                    color: theme.textStrong
                                    font.family: theme.titleFont
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: modelData.body
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ShellButton {
                    text: "Controls"
                    Layout.fillWidth: true
                    fill: "#1f3023"
                    borderColor: "#4a7858"
                    onClicked: root.shellState.toggle_quick_settings()
                }

                ShellButton {
                    text: "Session"
                    Layout.fillWidth: true
                    fill: "#321f24"
                    borderColor: "#86545f"
                    onClicked: root.shellState.toggle_session()
                }
            }
        }
    }
}
