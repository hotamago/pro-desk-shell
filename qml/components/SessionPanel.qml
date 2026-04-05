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
        tintTop: "#172636"
        tintBottom: "#0d141d"
        borderTint: "#3b5a77"
        glowTint: root.shellState.accent_color
        glowStrength: 0.1

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Session"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 28
                        font.weight: Font.Black
                    }

                    Text {
                        text: "Lock, reset, close shell surfaces, or step into settings from one clear session deck."
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                }

                ShellButton {
                    text: "Dismiss"
                    compact: true
                    onClicked: root.shellState.toggle_session()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 24
                color: "#122334"
                border.width: 1
                border.color: "#31526d"
                implicitHeight: 92

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56
                        radius: 18
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: root.shellState.accent_color }
                            GradientStop { position: 1.0; color: theme.warmAccent }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "OS"
                            color: "#081119"
                            font.family: theme.monoFont
                            font.pixelSize: 16
                            font.weight: Font.Black
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.shellState.active_window_title
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.shellState.active_workspace + " / " + root.shellState.network_name + " / battery " + root.shellState.battery_percent + "%"
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                columnSpacing: 14
                rowSpacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 24
                    color: "#142738"
                    border.width: 1
                    border.color: "#3a6a8f"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.shellState.request_lock()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 6

                        Text {
                            text: "Lock session"
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }

                        Text {
                            text: "Send a lock request and close the session surface."
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
                    radius: 24
                    color: "#202a1d"
                    border.width: 1
                    border.color: "#587752"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.shellState.restart_shell()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 6

                        Text {
                            text: "Refresh shell"
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }

                        Text {
                            text: "Reload live state, close transient views, and sync the shell again."
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
                    radius: 24
                    color: "#2a231b"
                    border.width: 1
                    border.color: "#7b613a"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.shellState.close_transient_surfaces()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 6

                        Text {
                            text: "Close surfaces"
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }

                        Text {
                            text: "Dismiss launcher, overview, controls, notifications, and session views."
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
                    radius: 24
                    color: "#261c21"
                    border.width: 1
                    border.color: "#86535e"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.quit()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 6

                        Text {
                            text: "Quit app"
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }

                        Text {
                            text: "Exit the shell process entirely from the current session."
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 20
                color: "#111a25"
                border.width: 1
                border.color: "#2a4154"
                implicitHeight: 84

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Text {
                        text: "Mailbox flow"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Hyprland keybind fragments write stable action IDs into the state mailbox so the shell can react without QML shell-outs."
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
