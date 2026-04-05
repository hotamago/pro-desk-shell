import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    property string query: ""

    readonly property var catalog: [
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
        if (actionId === "quick") {
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
        tintTop: "#162333"
        tintBottom: "#0d1620"
        borderTint: "#30516b"
        padding: 22

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    placeholderText: "Search shell actions, integrations, and surfaces"
                    text: root.query
                    onTextChanged: root.query = text.toLowerCase()
                    Component.onCompleted: forceActiveFocus()
                }

                Button {
                    text: "Close"
                    onClicked: root.shellState.toggle_launcher()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    radius: 20
                    color: "#13202c"
                    border.width: 1
                    border.color: "#264154"
                    implicitHeight: 88

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text {
                            text: root.shellState.active_window_title
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 17
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

                Rectangle {
                    radius: 20
                    color: "#1c2b1d"
                    border.width: 1
                    border.color: "#3c7256"
                    implicitWidth: 170
                    implicitHeight: 88

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 2

                        Text {
                            text: root.shellState.network_name
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: "Battery " + root.shellState.battery_percent + "% • Volume " + root.shellState.volume_percent + "%"
                            color: theme.textSoft
                            font.family: theme.monoFont
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    width: parent.width
                    spacing: 12

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
                            color: "#121c28"
                            border.width: 1
                            border.color: matches ? "#25455d" : "#182736"
                            implicitHeight: 94

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.runAction(parent.modelData.actionId)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16

                                Rectangle {
                                    Layout.preferredWidth: 44
                                    Layout.preferredHeight: 44
                                    radius: 15
                                    color: "#203244"
                                    border.width: 1
                                    border.color: "#4a84a6"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "→"
                                        color: theme.surfaceHighlight
                                        font.family: theme.titleFont
                                        font.pixelSize: 20
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
}
