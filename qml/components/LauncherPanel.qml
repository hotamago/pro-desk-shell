import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    property string query: ""

    readonly property var catalog: [
        {
            label: "Toggle overview",
            description: "Open the larger shell dashboard for workspaces, context, and actions.",
            keywords: "overview dashboard workspaces scene",
            actionId: "overview"
        },
        {
            label: "Toggle quick settings",
            description: "Open the control rail for audio, brightness, and shell prefs.",
            keywords: "quick settings audio brightness network",
            actionId: "quick"
        },
        {
            label: "Toggle notifications",
            description: "Review the current shell inbox and runtime status.",
            keywords: "notifications inbox alerts",
            actionId: "notifications"
        },
        {
            label: "Toggle wallpaper controls",
            description: "Update wallpaper path, accent color, and shell theme name.",
            keywords: "wallpaper background accent theme",
            actionId: "wallpaper"
        },
        {
            label: "Open settings window",
            description: "Inspect persisted config and tune Pro Desk Shell pages.",
            keywords: "settings preferences config",
            actionId: "settings"
        },
        {
            label: "Toggle session surface",
            description: "Lock, refresh, or close the shell from one control point.",
            keywords: "session lock restart shell",
            actionId: "session"
        },
        {
            label: "Refresh shell snapshot",
            description: "Pull a fresh Hyprland and system integration snapshot from Rust.",
            keywords: "refresh reload hyprland snapshot",
            actionId: "refresh"
        }
    ]

    ShellTheme {
        id: theme
    }

    function runAction(actionId) {
        if (actionId === "overview") {
            root.shellState.toggle_overview()
        } else if (actionId === "quick") {
            root.shellState.toggle_quick_settings()
        } else if (actionId === "notifications") {
            root.shellState.toggle_notifications()
        } else if (actionId === "wallpaper") {
            root.shellState.toggle_wallpaper_selector()
        } else if (actionId === "settings") {
            root.shellState.toggle_settings()
        } else if (actionId === "session") {
            root.shellState.toggle_session()
        } else if (actionId === "refresh") {
            root.shellState.refresh_shell()
        }

        root.shellState.toggle_launcher()
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#15283d"
        tintBottom: "#0c1520"
        borderTint: "#355e81"
        glowTint: root.shellState.accent_color
        glowStrength: 0.12
        padding: 22

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Launcher"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 24
                        font.weight: Font.Black
                    }

                    Text {
                        text: "A compact command palette for shell surfaces and runtime actions."
                        color: theme.textSoft
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                ShellTextField {
                    id: searchField

                    Layout.preferredWidth: 390
                    placeholderText: "Search shell actions, integrations, and surfaces"
                    text: root.query
                    onTextChanged: root.query = text.toLowerCase()
                    Component.onCompleted: forceActiveFocus()
                }

                ShellButton {
                    text: "Close"
                    compact: true
                    onClicked: root.shellState.toggle_launcher()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 24
                    color: "#0f1b28"
                    border.width: 1
                    border.color: "#2b4d69"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 20
                            color: "#14283c"
                            border.width: 1
                            border.color: "#315777"
                            implicitHeight: 88

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 4

                                Text {
                                    text: root.shellState.active_window_title
                                    color: theme.textStrong
                                    font.family: theme.titleFont
                                    font.pixelSize: 18
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: root.shellState.status_line
                                    color: theme.textSoft
                                    font.family: theme.bodyFont
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                }
                            }
                        }

                        Text {
                            text: root.query.length > 0 ? "Results" : "Pinned actions"
                            color: theme.textDim
                            font.family: theme.bodyFont
                            font.pixelSize: 11
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
                                        radius: 20
                                        color: "#132435"
                                        border.width: 1
                                        border.color: "#315476"
                                        implicitHeight: 90

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
                                                Layout.preferredWidth: 42
                                                Layout.preferredHeight: 42
                                                radius: 14
                                                color: "#18364d"
                                                border.width: 1
                                                border.color: "#4b86ab"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (index + 1).toString()
                                                    color: theme.surfaceHighlight
                                                    font.family: theme.monoFont
                                                    font.pixelSize: 14
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
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 272
                    Layout.fillHeight: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 24
                        color: "#112030"
                        border.width: 1
                        border.color: "#29475f"
                        implicitHeight: 124

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 6

                            Text {
                                text: root.shellState.network_name
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "Battery " + root.shellState.battery_percent + "%  /  Volume " + root.shellState.volume_percent + "%"
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: root.shellState.media_title.length > 0 ? root.shellState.media_title : "No media session"
                                color: theme.textDim
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 24
                        color: "#0f1a26"
                        border.width: 1
                        border.color: "#243d52"
                        implicitHeight: 178

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Text {
                                text: "Pinned shortcuts"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            ShellButton {
                                text: "Overview"
                                Layout.fillWidth: true
                                onClicked: root.runAction("overview")
                            }

                            ShellButton {
                                text: "Controls"
                                Layout.fillWidth: true
                                fill: "#1f3024"
                                borderColor: "#4d795a"
                                onClicked: root.runAction("quick")
                            }

                            ShellButton {
                                text: "Settings"
                                Layout.fillWidth: true
                                fill: "#192f43"
                                borderColor: "#4a7799"
                                onClicked: root.runAction("settings")
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 24
                        color: "#0d1621"
                        border.width: 1
                        border.color: "#21384a"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
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
                                implicitHeight: 110
                                radius: 20
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: root.shellState.accent_color }
                                    GradientStop { position: 0.5; color: root.shellState.accent_color_secondary }
                                    GradientStop { position: 1.0; color: root.shellState.accent_color_tertiary }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.leftMargin: 14
                                    anchors.bottomMargin: 14
                                    text: root.shellState.theme_name
                                    color: "#09131b"
                                    font.family: theme.titleFont
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                }
                            }

                            Text {
                                text: "Jump to wallpaper tools to keep the shell language cohesive."
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
