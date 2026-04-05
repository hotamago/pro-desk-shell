import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    required property var shellState

    width: 1060
    height: 760
    color: "transparent"
    title: "Pro Desk Shell Settings"
    flags: Qt.Window | Qt.FramelessWindowHint

    onClosing: function(close) {
        close.accepted = false
        root.shellState.toggle_settings()
    }

    ShellTheme {
        id: theme
    }

    SurfaceCard {
        anchors.fill: parent
        anchors.margins: 10
        tintTop: "#162231"
        tintBottom: "#101721"
        borderTint: "#35546d"
        padding: 20

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Settings"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "A Pro Desk Shell control room rebuilt from a behavioral spec, not copied source."
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                Button {
                    text: "Close"
                    onClicked: root.shellState.toggle_settings()
                }
            }

            TabBar {
                id: tabs
                Layout.fillWidth: true

                TabButton { text: "Quick" }
                TabButton { text: "General" }
                TabButton { text: "Bar" }
                TabButton { text: "Background" }
                TabButton { text: "Integrations" }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabs.currentIndex

                ScrollView {
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 16

                        Text {
                            text: root.shellState.status_line
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                        }

                        CheckBox {
                            text: "Enable transparency"
                            checked: root.shellState.transparency_enabled
                            onToggled: root.shellState.set_transparency_preference(checked)
                        }

                        CheckBox {
                            text: "Use dense top bar"
                            checked: root.shellState.bar_dense
                            onToggled: root.shellState.set_bar_dense_preference(checked)
                        }

                        Button {
                            text: "Refresh shell snapshot"
                            onClicked: root.shellState.refresh_shell()
                        }
                    }
                }

                ScrollView {
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "Config path"
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.shellState.config_path
                            color: theme.textSoft
                            font.family: theme.monoFont
                            font.pixelSize: 11
                            wrapMode: Text.WrapAnywhere
                        }

                        Text {
                            text: "State path"
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.shellState.state_path
                            color: theme.textSoft
                            font.family: theme.monoFont
                            font.pixelSize: 11
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                }

                ScrollView {
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "Panel height"
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.shellState.panel_height + " px"
                            color: theme.textSoft
                            font.family: theme.monoFont
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Active workspace"
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.shellState.active_workspace
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 12
                        }
                    }
                }

                ScrollView {
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        TextField {
                            id: wallpaperPathField

                            width: parent.width
                            placeholderText: "/path/to/wallpaper.png"
                            text: root.shellState.wallpaper_path
                        }

                        Button {
                            text: "Save wallpaper path"
                            onClicked: root.shellState.set_wallpaper_path_value(wallpaperPathField.text)
                        }

                        TextField {
                            id: accentField

                            width: parent.width
                            placeholderText: "#56d6ff"
                            text: root.shellState.accent_color
                        }

                        Button {
                            text: "Save accent color"
                            onClicked: root.shellState.set_accent_color_value(accentField.text)
                        }
                    }
                }

                ScrollView {
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        TextField {
                            id: terminalField

                            width: parent.width
                            placeholderText: "kitty -1"
                            text: root.shellState.terminal_command
                        }

                        Button {
                            text: "Save terminal command"
                            onClicked: root.shellState.set_terminal_command_value(terminalField.text)
                        }
                    }
                }
            }
        }
    }
}
