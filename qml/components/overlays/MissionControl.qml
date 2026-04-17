import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

Item {
    id: root

    property bool open: false
    property string workspacesJson: "[]"
    property var theme
    property var shellState
    property var workspaces: parseWorkspaces(workspacesJson)

    visible: open
    opacity: open ? 1 : 0

    function parseWorkspaces(payload) {
        try {
            return JSON.parse(payload)
        } catch (error) {
            return []
        }
    }

    onWorkspacesJsonChanged: workspaces = parseWorkspaces(workspacesJson)

    Rectangle {
        anchors.fill: parent
        color: "#7fe6eef8"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: "Mission Control"
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            GlassButton {
                theme: root.theme
                text: "close"
                onClicked: root.shellState.close_transient_surfaces()
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: workspaceRow.width
            clip: true

            Row {
                id: workspaceRow
                spacing: 22

                Repeater {
                    model: root.workspaces

                    FrostedPanel {
                        width: 360
                        height: parent ? parent.height - 8 : 640
                        theme: root.theme
                        padding: 18
                        radius: 30
                        fillColor: modelData.is_active ? "#f7fbff" : "#eef5fc"
                        borderColor: modelData.is_active ? root.theme.accentColor : "#8bdfe8f5"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Label {
                                        text: modelData.workspace_name
                                        color: root.theme.textPrimary
                                        font.family: root.theme.displayFont
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Label {
                                        text: modelData.windows.length + " windows"
                                        color: root.theme.textSoft
                                        font.family: root.theme.bodyFont
                                        font.pixelSize: 12
                                    }
                                }

                                GlassButton {
                                    theme: root.theme
                                    text: modelData.is_active ? "active" : "switch"
                                    quiet: modelData.is_active
                                    onClicked: root.shellState.activate_workspace(String(modelData.workspace_id))
                                }
                            }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 10
                                model: modelData.windows

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 118
                                    radius: 22
                                    color: modelData.focused ? "#eef5ff" : "#fbfdff"
                                    border.width: 1
                                    border.color: modelData.focused ? root.theme.accentColor : "#dfe7f3"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 8

                                        Label {
                                            text: modelData.title
                                            color: root.theme.textPrimary
                                            font.family: root.theme.displayFont
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }

                                        Label {
                                            text: modelData.class_name + "  /  " + modelData.app_id
                                            color: root.theme.textSoft
                                            font.family: root.theme.bodyFont
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }

                                        Label {
                                            text: modelData.fullscreen
                                                  ? "fullscreen"
                                                  : (modelData.floating ? "floating" : "tiling")
                                            color: root.theme.textMuted
                                            font.family: root.theme.bodyFont
                                            font.pixelSize: 11
                                        }

                                        Item {
                                            Layout.fillHeight: true
                                        }

                                        GlassButton {
                                            theme: root.theme
                                            text: "focus"
                                            accented: modelData.focused
                                            onClicked: root.shellState.focus_window(modelData.window_id)
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
}
