import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    required property var shellState
    property int pageIndex: 0

    width: 1220
    height: 820
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

    component NavButton: Button {
        id: control

        required property int page
        required property string label

        text: label
        implicitHeight: 44
        Layout.fillWidth: true
        checkable: true
        checked: root.pageIndex === page
        onClicked: root.pageIndex = page

        contentItem: Text {
            text: control.text
            color: control.checked ? "#09131b" : theme.textStrong
            verticalAlignment: Text.AlignVCenter
            leftPadding: 16
            font.family: theme.bodyFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        background: Rectangle {
            radius: 16
            color: control.checked ? theme.surfaceHighlight : "#132638"
            border.width: 1
            border.color: control.checked ? "#81e4ff" : "#2d4f6b"
        }
    }

    component SettingsCard: Rectangle {
        radius: 22
        color: "#111d2b"
        border.width: 1
        border.color: "#294761"
    }

    SurfaceCard {
        anchors.fill: parent
        anchors.margins: 10
        tintTop: "#15283d"
        tintBottom: "#0d1620"
        borderTint: "#355e81"
        glowTint: root.shellState.accent_color
        glowStrength: 0.12
        padding: 20

        RowLayout {
            anchors.fill: parent
            spacing: 18

            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                radius: 26
                color: "#102030"
                border.width: 1
                border.color: "#2b4b65"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Text {
                        text: "Settings"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 30
                        font.weight: Font.Black
                    }

                    Text {
                        text: "Control room for layout, surfaces, runtime edges, and integrations."
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 20
                        color: "#142739"
                        border.width: 1
                        border.color: "#335a7a"
                        implicitHeight: 88

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 4

                            Text {
                                text: root.shellState.active_window_title
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                text: root.shellState.status_line
                                color: theme.textDim
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    NavButton { page: 0; label: "Quick" }
                    NavButton { page: 1; label: "General" }
                    NavButton { page: 2; label: "Bar" }
                    NavButton { page: 3; label: "Background" }
                    NavButton { page: 4; label: "Integrations" }

                    Item {
                        Layout.fillHeight: true
                    }

                    ShellButton {
                        text: "Close settings"
                        Layout.fillWidth: true
                        onClicked: root.shellState.toggle_settings()
                    }
                }
            }

            SettingsCard {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    currentIndex: root.pageIndex

                    ScrollView {
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 148

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "Quick actions"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 20
                                        font.weight: Font.DemiBold
                                    }

                                    ShellToggleButton {
                                        text: "Enable transparency"
                                        checked: root.shellState.transparency_enabled
                                        activeFill: "#193649"
                                        inactiveFill: "#122335"
                                        activeBorderColor: "#64d7ff"
                                        inactiveBorderColor: "#31516f"
                                        onClicked: root.shellState.set_transparency_preference(!root.shellState.transparency_enabled)
                                    }

                                    ShellToggleButton {
                                        text: "Use dense top bar"
                                        checked: root.shellState.bar_dense
                                        activeFill: "#1f3128"
                                        inactiveFill: "#142536"
                                        activeBorderColor: "#72d6a2"
                                        inactiveBorderColor: "#31506c"
                                        onClicked: root.shellState.set_bar_dense_preference(!root.shellState.bar_dense)
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                ShellButton {
                                    text: "Refresh shell snapshot"
                                    onClicked: root.shellState.refresh_shell()
                                }

                                ShellButton {
                                    text: "Open control center"
                                    fill: "#1f3123"
                                    borderColor: "#4b7859"
                                    onClicked: root.shellState.toggle_quick_settings()
                                }

                                ShellButton {
                                    text: "Open wallpaper studio"
                                    fill: "#2b2031"
                                    borderColor: "#75518a"
                                    onClicked: root.shellState.toggle_wallpaper_selector()
                                }
                            }
                        }
                    }

                    ScrollView {
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 126

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "Config path"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: root.shellState.config_path
                                        color: theme.textSoft
                                        font.family: theme.monoFont
                                        font.pixelSize: 11
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 126

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "State path"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
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

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 164

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "Capabilities"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Text { text: "Hyprland  /  " + (root.shellState.has_hyprland ? "online" : "preview"); color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                    Text { text: "playerctl  /  " + (root.shellState.has_playerctl ? "ready" : "missing"); color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                    Text { text: "nmcli  /  " + (root.shellState.has_nmcli ? "ready" : "missing"); color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                    Text { text: "brightnessctl  /  " + (root.shellState.has_brightnessctl ? "ready" : "missing"); color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                }
                            }
                        }
                    }

                    ScrollView {
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 120

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "Bar metrics"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Text { text: "Panel height  /  " + root.shellState.panel_height + " px"; color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                    Text { text: "Active workspace  /  " + root.shellState.active_workspace; color: theme.textSoft; font.family: theme.bodyFont; font.pixelSize: 12 }
                                }
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 130

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10

                                    Text {
                                        text: "Workspace preview"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    WorkspaceStrip {
                                        shellState: root.shellState
                                    }
                                }
                            }
                        }
                    }

                    ScrollView {
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 172

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10

                                    Text {
                                        text: "Theme preview"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 90
                                        radius: 20
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: root.shellState.accent_color }
                                            GradientStop { position: 0.5; color: root.shellState.accent_color_secondary }
                                            GradientStop { position: 1.0; color: root.shellState.accent_color_tertiary }
                                        }
                                    }
                                }
                            }

                            ShellTextField {
                                id: wallpaperPathField
                                Layout.fillWidth: true
                                placeholderText: "/path/to/wallpaper.png"
                                text: root.shellState.wallpaper_path
                            }

                            ShellButton {
                                text: "Save wallpaper path"
                                onClicked: root.shellState.set_wallpaper_path_value(wallpaperPathField.text)
                            }

                            ShellTextField {
                                id: accentField
                                Layout.fillWidth: true
                                placeholderText: "#56d6ff"
                                text: root.shellState.accent_color
                            }

                            ShellButton {
                                text: "Save accent color"
                                onClicked: root.shellState.set_accent_color_value(accentField.text)
                            }
                        }
                    }

                    ScrollView {
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            SettingsCard {
                                Layout.fillWidth: true
                                implicitHeight: 132

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: "Terminal command"
                                        color: theme.textStrong
                                        font.family: theme.titleFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    ShellTextField {
                                        id: terminalField
                                        Layout.fillWidth: true
                                        placeholderText: "kitty -1"
                                        text: root.shellState.terminal_command
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                ShellButton {
                                    text: "Save terminal command"
                                    onClicked: root.shellState.set_terminal_command_value(terminalField.text)
                                }

                                ShellButton {
                                    text: "Open control center"
                                    fill: "#1f3123"
                                    borderColor: "#4b7859"
                                    onClicked: root.shellState.toggle_quick_settings()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
