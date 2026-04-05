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
        tintTop: "#172432"
        tintBottom: "#0f1822"
        borderTint: "#29445a"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Quick Settings"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Runtime signals from Rust plus persisted shell preferences."
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                Button {
                    text: "Close"
                    onClicked: root.shellState.toggle_quick_settings()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 18
                color: "#12202d"
                border.width: 1
                border.color: "#243c50"
                implicitHeight: 132

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: root.shellState.network_name + " • " + root.shellState.network_state
                        color: theme.textStrong
                        font.family: theme.bodyFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Volume " + root.shellState.volume_percent + "%"
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 11
                        }

                        Slider {
                            Layout.fillWidth: true
                            enabled: false
                            from: 0
                            to: 100
                            value: root.shellState.volume_percent
                        }

                        Text {
                            text: "Brightness " + root.shellState.brightness_percent + "%"
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 11
                        }

                        Slider {
                            Layout.fillWidth: true
                            enabled: false
                            from: 0
                            to: 100
                            value: root.shellState.brightness_percent
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CheckBox {
                    text: "Transparency"
                    checked: root.shellState.transparency_enabled
                    onToggled: root.shellState.set_transparency_preference(checked)
                }

                CheckBox {
                    text: "Dense bar"
                    checked: root.shellState.bar_dense
                    onToggled: root.shellState.set_bar_dense_preference(checked)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 18
                color: "#111b26"
                border.width: 1
                border.color: "#24394b"
                implicitHeight: 152

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Text {
                        text: "Terminal command"
                        color: theme.textStrong
                        font.family: theme.bodyFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    TextField {
                        id: terminalField

                        Layout.fillWidth: true
                        text: root.shellState.terminal_command
                        placeholderText: "kitty -1"
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            text: "Save"
                            onClicked: root.shellState.set_terminal_command_value(terminalField.text)
                        }

                        Button {
                            text: "Refresh"
                            onClicked: root.shellState.refresh_shell()
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Config " + root.shellState.config_path
                            color: theme.textDim
                            font.family: theme.monoFont
                            font.pixelSize: 10
                            elide: Text.ElideLeft
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: "#101824"
                border.width: 1
                border.color: "#22384b"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 6

                    Text {
                        text: "Capability edge"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 14
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
                        text: "nmcli " + (root.shellState.has_nmcli ? "ready" : "missing") + " • brightnessctl " + (root.shellState.has_brightnessctl ? "ready" : "missing")
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
