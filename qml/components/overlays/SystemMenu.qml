import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

Item {
    id: root

    property bool open: false
    property var theme
    property var shellState

    signal closeRequested()

    visible: open
    opacity: open ? 1 : 0
    x: open ? 0 : -16

    Behavior on opacity {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    FrostedPanel {
        anchors.fill: parent
        theme: root.theme
        padding: 20
        radius: 30
        fillColor: "#eff7fd"
        borderColor: "#b8ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: "Shell Menu"
                        color: root.theme.textPrimary
                        font.family: root.theme.displayFont
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: "Quick actions and shell preferences"
                        color: root.theme.textSoft
                        font.family: root.theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                GlassButton {
                    theme: root.theme
                    text: "close"
                    quiet: true
                    onClicked: root.closeRequested()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "spotlight"
                    accented: true
                    onClicked: {
                        root.closeRequested()
                        root.shellState.toggle_launcher()
                    }
                }

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "mission"
                    onClicked: {
                        root.closeRequested()
                        root.shellState.toggle_overview()
                    }
                }

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "control"
                    onClicked: {
                        root.closeRequested()
                        root.shellState.toggle_quick_settings()
                    }
                }

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "notifications"
                    onClicked: {
                        root.closeRequested()
                        root.shellState.toggle_notifications()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 174
                radius: 24
                color: "#fbfdff"
                border.width: 1
                border.color: "#e1e9f5"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: "Behavior"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: "Compact menu bar"
                            color: root.theme.textPrimary
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                        }

                        Switch {
                            checked: root.shellState.menu_bar_compact_mode
                            onToggled: root.shellState.update_menu_bar_compact_mode(checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: "Auto-hide dock"
                            color: root.theme.textPrimary
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                        }

                        Switch {
                            checked: root.shellState.dock_auto_hide
                            onToggled: root.shellState.update_dock_auto_hide(checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: "Running indicators"
                            color: root.theme.textPrimary
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                        }

                        Switch {
                            checked: root.shellState.dock_show_running_indicators
                            onToggled: root.shellState.update_dock_show_running_indicators(checked)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 200
                radius: 24
                color: "#fbfdff"
                border.width: 1
                border.color: "#e1e9f5"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        text: "Tuning"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Label {
                        text: "Dock magnification  " + root.shellState.dock_magnification + "%"
                        color: root.theme.textPrimary
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 40
                        stepSize: 1
                        value: root.shellState.dock_magnification
                        live: false
                        onMoved: root.shellState.update_dock_magnification_value(Math.round(value))
                    }

                    Label {
                        text: "Launcher results  " + root.shellState.launcher_max_results
                        color: root.theme.textPrimary
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 4
                        to: 16
                        stepSize: 1
                        value: root.shellState.launcher_max_results
                        live: false
                        onMoved: root.shellState.update_launcher_max_results_value(Math.round(value))
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 176
                radius: 24
                color: "#fbfdff"
                border.width: 1
                border.color: "#e1e9f5"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        text: "Commands and wallpaper"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    TextField {
                        Layout.fillWidth: true
                        text: root.shellState.terminal_command
                        placeholderText: "Terminal command"
                        onEditingFinished: root.shellState.update_terminal_command_value(text)
                    }

                    TextField {
                        Layout.fillWidth: true
                        text: root.shellState.wallpaper_path
                        placeholderText: "Wallpaper path"
                        onEditingFinished: root.shellState.update_wallpaper_path_value(text)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "refresh"
                    onClicked: root.shellState.refresh_shell()
                }

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "lock"
                    onClicked: root.shellState.request_lock()
                }
            }
        }
    }
}
