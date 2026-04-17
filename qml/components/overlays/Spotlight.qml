import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

Item {
    id: root

    property bool open: false
    property string resultsJson: "[]"
    property var theme
    property var shellState
    property var results: parseResults(resultsJson)

    visible: open
    opacity: open ? 1 : 0

    function parseResults(payload) {
        try {
            return JSON.parse(payload)
        } catch (error) {
            return []
        }
    }

    onResultsJsonChanged: results = parseResults(resultsJson)
    onOpenChanged: {
        if (open) {
            searchField.forceActiveFocus()
            searchField.selectAll()
            root.shellState.update_launcher_query(searchField.text)
        }
    }

    FrostedPanel {
        width: Math.min(720, parent.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 110
        theme: root.theme
        padding: 24
        radius: 34
        fillColor: "#edf6fd"
        borderColor: "#b6ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search, launch, or pin apps"
                text: root.shellState.launcher_query
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 17
                padding: 18
                selectByMouse: true

                background: Rectangle {
                    radius: 20
                    color: "#fbfdff"
                    border.width: 1
                    border.color: "#d7e4f5"
                }

                onTextChanged: root.shellState.update_launcher_query(text)
                onAccepted: {
                    if (root.results.length > 0) {
                        root.shellState.launch_app(root.results[0].app_id)
                    }
                }
            }

            Label {
                text: root.results.length > 0 ? "Top matches" : "No matches yet"
                color: root.theme.textMuted
                font.family: root.theme.bodyFont
                font.pixelSize: 12
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(360, contentHeight)
                clip: true
                spacing: 10
                model: root.results

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 72
                    radius: 20
                    color: index === 0 ? "#f4f8fd" : "#fbfdff"
                    border.width: 1
                    border.color: "#e1e9f5"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        Rectangle {
                            width: 42
                            height: 42
                            radius: 14
                            color: root.theme.accentColor

                            AppIcon {
                                anchors.fill: parent
                                theme: root.theme
                                displayName: modelData.display_name || modelData.app_id || "App"
                                iconPath: modelData.icon_path || ""
                                textColor: "#ffffff"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: modelData.display_name
                                color: root.theme.textPrimary
                                font.family: root.theme.displayFont
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }

                            Label {
                                text: modelData.app_id
                                color: root.theme.textSoft
                                font.family: root.theme.bodyFont
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        GlassButton {
                            theme: root.theme
                            text: "pin"
                            quiet: true
                            onClicked: root.shellState.toggle_dock_pin(modelData.app_id)
                        }

                        GlassButton {
                            theme: root.theme
                            text: "open"
                            accented: index === 0
                            onClicked: root.shellState.launch_app(modelData.app_id)
                        }
                    }
                }
            }
        }
    }
}
