import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    required property bool useLayerShell

    ShellTheme {
        id: theme
    }

    component ActionButton: Button {
        id: control

        property color fill: "#203142"
        property color outline: "#314f69"
        property color textColor: theme.textStrong

        implicitHeight: 38
        implicitWidth: label.implicitWidth + 26
        padding: 0
        hoverEnabled: true

        contentItem: Text {
            id: label

            text: control.text
            color: control.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: theme.bodyFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        background: Rectangle {
            radius: 16
            color: control.down ? Qt.darker(control.fill, 1.15) : control.fill
            border.width: 1
            border.color: control.outline
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.useLayerShell ? "transparent" : Qt.rgba(theme.canvasTop.r, theme.canvasTop.g, theme.canvasTop.b, 0.98)
    }

    SurfaceCard {
        anchors.fill: parent
        anchors.margins: 8
        padding: 14
        tintTop: Qt.rgba(theme.surfaceTop.r, theme.surfaceTop.g, theme.surfaceTop.b, 0.98)
        tintBottom: Qt.rgba(theme.surfaceBottom.r, theme.surfaceBottom.g, theme.surfaceBottom.b, 0.98)
        borderTint: theme.surfaceBorder

        RowLayout {
            anchors.fill: parent
            spacing: 14

            RowLayout {
                Layout.preferredWidth: 470
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46
                    radius: 16
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: theme.surfaceHighlight
                        }

                        GradientStop {
                            position: 1.0
                            color: theme.warmAccent
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "PD"
                        color: "#09121a"
                        font.family: theme.monoFont
                        font.pixelSize: 14
                        font.weight: Font.Black
                    }
                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Pro Desk Shell"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.shellState.status_line
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                WorkspaceStrip {
                    Layout.fillWidth: true
                    shellState: root.shellState
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 20
                color: "#12202d"
                border.width: 1
                border.color: "#203747"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.shellState.active_window_title
                            color: theme.textStrong
                            font.family: theme.titleFont
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.shellState.active_window_class + " • " + root.shellState.compositor_name
                            color: theme.textSoft
                            font.family: theme.bodyFont
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        visible: root.shellState.media_title.length > 0
                        radius: 14
                        color: "#182939"
                        border.width: 1
                        border.color: "#2e5870"
                        implicitWidth: mediaColumn.implicitWidth + 26
                        implicitHeight: 38

                        Column {
                            id: mediaColumn

                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                text: root.shellState.media_title
                                color: theme.textStrong
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.shellState.media_artist
                                color: root.shellState.media_playing ? theme.mintAccent : theme.textDim
                                font.family: theme.bodyFont
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.preferredWidth: 520
                Layout.fillHeight: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: "#12202c"
                    border.width: 1
                    border.color: "#243c50"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: root.shellState.network_name
                                color: theme.textStrong
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "Vol " + root.shellState.volume_percent + "% • Bri " + root.shellState.brightness_percent + "% • Bat " + root.shellState.battery_percent + "%"
                                color: theme.textSoft
                                font.family: theme.monoFont
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            radius: 13
                            implicitWidth: stateText.implicitWidth + 16
                            implicitHeight: 28
                            color: root.shellState.battery_charging ? "#173026" : "#261e15"
                            border.width: 1
                            border.color: root.shellState.battery_charging ? "#2f7652" : "#745a2f"

                            Text {
                                id: stateText

                                anchors.centerIn: parent
                                text: root.shellState.battery_charging ? "charging" : root.shellState.network_state.toLowerCase()
                                color: root.shellState.battery_charging ? theme.mintAccent : theme.warmAccent
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                ActionButton {
                    text: "Search"
                    fill: "#1e3548"
                    outline: "#4f8cad"
                    onClicked: root.shellState.toggle_launcher()
                }

                ActionButton {
                    text: "Quick"
                    fill: "#22301d"
                    outline: "#3d7758"
                    onClicked: root.shellState.toggle_quick_settings()
                }

                ActionButton {
                    text: "Notify"
                    fill: "#2a2417"
                    outline: "#7b5a2c"
                    onClicked: root.shellState.toggle_notifications()
                }

                ActionButton {
                    text: "Wall"
                    onClicked: root.shellState.toggle_wallpaper_selector()
                }

                ActionButton {
                    text: "Session"
                    onClicked: root.shellState.toggle_session()
                }

                ActionButton {
                    text: "Prefs"
                    onClicked: root.shellState.toggle_settings()
                }
            }
        }
    }
}
