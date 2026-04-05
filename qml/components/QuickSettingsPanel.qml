import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    property date now: new Date()

    ShellTheme {
        id: theme
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#15283c"
        tintBottom: "#0d1721"
        borderTint: "#315878"
        glowTint: root.shellState.accent_color
        glowStrength: 0.12

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Control Center"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 24
                        font.weight: Font.Black
                    }

                    Text {
                        text: root.shellState.network_name + " / " + root.shellState.network_state + " / " + Qt.formatDateTime(root.now, "ddd dd MMM  hh:mm")
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                ShellButton {
                    text: "Close"
                    compact: true
                    onClicked: root.shellState.toggle_quick_settings()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 22
                        color: "#112233"
                        border.width: 1
                        border.color: "#2b4b66"
                        implicitHeight: 226

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Quick toggles"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 10

                                ShellToggleButton {
                                    text: root.shellState.transparency_enabled ? "Transparency on" : "Transparency off"
                                    checked: root.shellState.transparency_enabled
                                    activeFill: "#19374a"
                                    inactiveFill: "#122335"
                                    activeBorderColor: "#66d8ff"
                                    inactiveBorderColor: "#31516f"
                                    onClicked: root.shellState.set_transparency_preference(!root.shellState.transparency_enabled)
                                }

                                ShellToggleButton {
                                    text: root.shellState.bar_dense ? "Dense bar on" : "Dense bar off"
                                    checked: root.shellState.bar_dense
                                    activeFill: "#1f3128"
                                    inactiveFill: "#152737"
                                    activeBorderColor: "#75d7a5"
                                    inactiveBorderColor: "#34536d"
                                    onClicked: root.shellState.set_bar_dense_preference(!root.shellState.bar_dense)
                                }

                                ShellButton {
                                    text: "Inbox"
                                    compact: true
                                    fill: "#30261a"
                                    borderColor: "#7b6438"
                                    onClicked: root.shellState.toggle_notifications()
                                }

                                ShellButton {
                                    text: "Theme"
                                    compact: true
                                    fill: "#2b2031"
                                    borderColor: "#755089"
                                    onClicked: root.shellState.toggle_wallpaper_selector()
                                }

                                ShellButton {
                                    text: "Settings"
                                    compact: true
                                    fill: "#173046"
                                    borderColor: "#4c7ea3"
                                    onClicked: root.shellState.toggle_settings()
                                }

                                ShellButton {
                                    text: "Session"
                                    compact: true
                                    fill: "#311f24"
                                    borderColor: "#83525d"
                                    onClicked: root.shellState.toggle_session()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 22
                        color: "#0f1a26"
                        border.width: 1
                        border.color: "#264258"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Capability edge"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "Hyprland " + (root.shellState.has_hyprland ? "online" : "preview")
                                color: root.shellState.has_hyprland ? theme.mintAccent : theme.warmAccent
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                            }

                            Text {
                                text: "playerctl " + (root.shellState.has_playerctl ? "ready" : "missing")
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                            }

                            Text {
                                text: "nmcli " + (root.shellState.has_nmcli ? "ready" : "missing")
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                            }

                            Text {
                                text: "brightnessctl " + (root.shellState.has_brightnessctl ? "ready" : "missing")
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                            }

                            Text {
                                text: "upower " + (root.shellState.has_upower ? "ready" : "missing")
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 184
                    Layout.fillHeight: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 22
                        color: "#122334"
                        border.width: 1
                        border.color: "#2d4f6c"
                        implicitHeight: 150

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "Volume"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.shellState.volume_percent + "%"
                                color: theme.surfaceHighlight
                                font.family: theme.titleFont
                                font.pixelSize: 28
                                font.weight: Font.Black
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 12
                                radius: 6
                                color: "#1b3045"

                                Rectangle {
                                    width: parent.width * Math.max(0, Math.min(100, root.shellState.volume_percent)) / 100
                                    height: parent.height
                                    radius: parent.radius
                                    color: root.shellState.accent_color
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 22
                        color: "#102232"
                        border.width: 1
                        border.color: "#2b4c65"
                        implicitHeight: 150

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "Brightness"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.shellState.brightness_percent + "%"
                                color: theme.goldAccent
                                font.family: theme.titleFont
                                font.pixelSize: 28
                                font.weight: Font.Black
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 12
                                radius: 6
                                color: "#1b3045"

                                Rectangle {
                                    width: parent.width * Math.max(0, Math.min(100, root.shellState.brightness_percent)) / 100
                                    height: parent.height
                                    radius: parent.radius
                                    color: "#f0d18d"
                                }
                            }
                        }
                    }

                    ShellButton {
                        text: "Refresh runtime"
                        Layout.fillWidth: true
                        onClicked: root.shellState.refresh_shell()
                    }
                }
            }
        }
    }
}
