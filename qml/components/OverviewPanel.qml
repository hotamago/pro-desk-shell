import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    property string query: ""

    readonly property var catalog: [
        {
            label: "Open launcher",
            description: "Bring up the compact command palette for shell actions.",
            keywords: "launcher command palette search actions",
            actionId: "launcher"
        },
        {
            label: "Open control center",
            description: "Adjust audio, brightness, toggles, and shell controls.",
            keywords: "control center quick settings audio brightness",
            actionId: "quick"
        },
        {
            label: "Open notification center",
            description: "Inspect inbox signals, runtime state, and shell notices.",
            keywords: "notifications inbox alerts signals",
            actionId: "notifications"
        },
        {
            label: "Open wallpaper studio",
            description: "Tune wallpaper path, accent colors, and preset themes.",
            keywords: "wallpaper theme background accent",
            actionId: "wallpaper"
        },
        {
            label: "Open session menu",
            description: "Lock, reset, close transient surfaces, or exit the shell.",
            keywords: "session lock restart close quit",
            actionId: "session"
        },
        {
            label: "Open settings",
            description: "Jump into the full Pro Desk Shell control room.",
            keywords: "settings preferences config",
            actionId: "settings"
        },
        {
            label: "Refresh shell snapshot",
            description: "Reload Hyprland and system runtime state from Rust.",
            keywords: "refresh reload hyprland runtime snapshot",
            actionId: "refresh"
        }
    ]

    ShellTheme {
        id: theme
    }

    function runAction(actionId) {
        if (actionId === "launcher") {
            root.shellState.toggle_launcher()
        } else if (actionId === "quick") {
            root.shellState.toggle_quick_settings()
        } else if (actionId === "notifications") {
            root.shellState.toggle_notifications()
        } else if (actionId === "wallpaper") {
            root.shellState.toggle_wallpaper_selector()
        } else if (actionId === "session") {
            root.shellState.toggle_session()
        } else if (actionId === "settings") {
            root.shellState.toggle_settings()
        } else if (actionId === "refresh") {
            root.shellState.refresh_shell()
        }

        root.shellState.toggle_overview()
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#15293e"
        tintBottom: "#0c1520"
        borderTint: "#355d80"
        glowTint: root.shellState.accent_color
        glowStrength: 0.14
        padding: 26

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 220
            radius: parent.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(theme.surfaceHighlight.r, theme.surfaceHighlight.g, theme.surfaceHighlight.b, 0.16)
                }

                GradientStop {
                    position: 0.65
                    color: Qt.rgba(theme.warmAccent.r, theme.warmAccent.g, theme.warmAccent.b, 0.08)
                }

                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Overview"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 30
                        font.weight: Font.Black
                    }

                    Text {
                        text: "A focused shell dashboard for workspaces, context, and fast actions."
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 12
                    }
                }

                ShellTextField {
                    id: searchField

                    Layout.preferredWidth: 360
                    placeholderText: "Search shell actions"
                    text: root.query
                    onTextChanged: root.query = text.toLowerCase()
                    Component.onCompleted: forceActiveFocus()
                }

                ShellButton {
                    text: "Close"
                    compact: true
                    fill: "#17293b"
                    borderColor: "#35526d"
                    onClicked: root.shellState.toggle_overview()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 28
                        color: "#10202f"
                        border.width: 1
                        border.color: "#2f5373"
                        implicitHeight: 186

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 8

                            Text {
                                text: root.shellState.active_window_title
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 26
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                text: root.shellState.active_window_class + "  /  " + root.shellState.active_workspace
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            Text {
                                text: root.shellState.status_line
                                color: theme.textDim
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            RowLayout {
                                spacing: 10

                                Rectangle {
                                    radius: 16
                                    color: "#172d42"
                                    border.width: 1
                                    border.color: "#40698e"
                                    implicitWidth: 210
                                    implicitHeight: 42

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.shellState.media_title.length > 0 ? root.shellState.media_title : "No active media"
                                        color: theme.textStrong
                                        font.family: theme.bodyFont
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        width: parent.width - 24
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                Rectangle {
                                    radius: 16
                                    color: "#19271f"
                                    border.width: 1
                                    border.color: "#3e7754"
                                    implicitWidth: 168
                                    implicitHeight: 42

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.shellState.network_name + "  /  " + root.shellState.battery_percent + "%"
                                        color: theme.textStrong
                                        font.family: theme.bodyFont
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        width: parent.width - 24
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 26
                        color: "#0f1a27"
                        border.width: 1
                        border.color: "#26435d"
                        implicitHeight: 132

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Workspace board"
                                    color: theme.textStrong
                                    font.family: theme.titleFont
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.shellState.compositor_name
                                    color: theme.textDim
                                    font.family: theme.monoFont
                                    font.pixelSize: 10
                                }
                            }

                            WorkspaceStrip {
                                Layout.fillWidth: true
                                shellState: root.shellState
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 26
                        color: "#0d1722"
                        border.width: 1
                        border.color: "#223a51"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Action results"
                                    color: theme.textStrong
                                    font.family: theme.titleFont
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.query.length > 0 ? "Filtered" : "Pinned"
                                    color: theme.textDim
                                    font.family: theme.bodyFont
                                    font.pixelSize: 11
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
                                        model: root.catalog

                                        delegate: Rectangle {
                                            required property var modelData

                                            readonly property bool matches: root.query.length === 0
                                                                             || modelData.label.toLowerCase().indexOf(root.query) >= 0
                                                                             || modelData.description.toLowerCase().indexOf(root.query) >= 0
                                                                             || modelData.keywords.indexOf(root.query) >= 0

                                            visible: matches
                                            width: parent.width
                                            radius: 22
                                            color: "#132435"
                                            border.width: 1
                                            border.color: "#305474"
                                            implicitHeight: 94

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: root.runAction(parent.modelData.actionId)
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 16
                                                spacing: 14

                                                Rectangle {
                                                    Layout.preferredWidth: 46
                                                    Layout.preferredHeight: 46
                                                    radius: 16
                                                    color: "#18344b"
                                                    border.width: 1
                                                    border.color: "#4a84aa"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: (index + 1).toString()
                                                        color: theme.surfaceHighlight
                                                        font.family: theme.monoFont
                                                        font.pixelSize: 15
                                                        font.weight: Font.Bold
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.label
                                                        color: theme.textStrong
                                                        font.family: theme.titleFont
                                                        font.pixelSize: 15
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Text {
                                                        text: modelData.description
                                                        color: theme.textSoft
                                                        font.family: theme.bodyFont
                                                        font.pixelSize: 11
                                                        wrapMode: Text.Wrap
                                                    }
                                                }

                                                Text {
                                                    text: "Run"
                                                    color: theme.textDim
                                                    font.family: theme.monoFont
                                                    font.pixelSize: 10
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 332
                    Layout.fillHeight: true
                    spacing: 16

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 26
                        color: "#0f1b29"
                        border.width: 1
                        border.color: "#2a4761"
                        implicitHeight: 178

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            Text {
                                text: "Control deck"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 10

                                ShellButton {
                                    text: "Launcher"
                                    compact: true
                                    onClicked: root.runAction("launcher")
                                }

                                ShellButton {
                                    text: "Controls"
                                    compact: true
                                    fill: "#1e3328"
                                    borderColor: "#3f775a"
                                    onClicked: root.runAction("quick")
                                }

                                ShellButton {
                                    text: "Inbox"
                                    compact: true
                                    fill: "#30281b"
                                    borderColor: "#7a6337"
                                    onClicked: root.runAction("notifications")
                                }

                                ShellButton {
                                    text: "Theme"
                                    compact: true
                                    fill: "#2e1e31"
                                    borderColor: "#735089"
                                    onClicked: root.runAction("wallpaper")
                                }

                                ShellButton {
                                    text: "Power"
                                    compact: true
                                    fill: "#311e23"
                                    borderColor: "#89545f"
                                    onClicked: root.runAction("session")
                                }

                                ShellButton {
                                    text: "Refresh"
                                    compact: true
                                    fill: "#152c3e"
                                    borderColor: "#457295"
                                    onClicked: root.runAction("refresh")
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 26
                        color: "#101b28"
                        border.width: 1
                        border.color: "#244258"
                        implicitHeight: 162

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            Text {
                                text: "Signal stack"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "Network  /  " + root.shellState.network_name + "  /  " + root.shellState.network_state
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Battery  /  " + root.shellState.battery_percent + "%  /  " + (root.shellState.battery_charging ? "charging" : "steady")
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Unread  /  " + root.shellState.notification_count + " notices"
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                            }

                            Text {
                                text: root.shellState.latest_notification_title
                                color: theme.textDim
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 26
                        color: "#0e1822"
                        border.width: 1
                        border.color: "#22374d"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            Text {
                                text: "Theme pulse"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 118
                                radius: 22
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: root.shellState.accent_color }
                                    GradientStop { position: 0.5; color: root.shellState.accent_color_secondary }
                                    GradientStop { position: 1.0; color: root.shellState.accent_color_tertiary }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.leftMargin: 16
                                    anchors.bottomMargin: 16
                                    text: root.shellState.theme_name
                                    color: "#09131b"
                                    font.family: theme.titleFont
                                    font.pixelSize: 20
                                    font.weight: Font.Black
                                }
                            }

                            Text {
                                text: "Use Theme from the top bar or open Settings for deeper surface tuning."
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
    }
}
