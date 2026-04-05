import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState
    required property bool useLayerShell
    property date now: new Date()

    function pad(value) {
        return value < 10 ? "0" + value : value
    }

    ShellTheme {
        id: theme
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.useLayerShell ? "transparent" : Qt.rgba(theme.canvasTop.r, theme.canvasTop.g, theme.canvasTop.b, 0.98) }
            GradientStop { position: 1.0; color: root.useLayerShell ? "transparent" : Qt.rgba(theme.canvasAmbient.r, theme.canvasAmbient.g, theme.canvasAmbient.b, 0.92) }
        }
    }

    Rectangle {
        width: 360
        height: 220
        radius: width / 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 40
        anchors.topMargin: -130
        color: theme.alpha(theme.surfaceHighlight, 0.12)
    }

    Rectangle {
        width: 420
        height: 260
        radius: width / 2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 80
        anchors.topMargin: -150
        color: theme.alpha(theme.warmAccent, 0.08)
    }

    SurfaceCard {
        anchors.fill: parent
        anchors.margins: 6
        padding: 14
        tintTop: Qt.rgba(theme.surfaceTop.r, theme.surfaceTop.g, theme.surfaceTop.b, 0.98)
        tintBottom: Qt.rgba(theme.surfaceBottom.r, theme.surfaceBottom.g, theme.surfaceBottom.b, 0.98)
        borderTint: theme.surfaceBorder
        glowTint: root.shellState.accent_color
        glowStrength: 0.12

        RowLayout {
            anchors.fill: parent
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 352
                Layout.fillHeight: true
                radius: 24
                color: "#102131"
                border.width: 1
                border.color: "#294863"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 52
                            Layout.preferredHeight: 52
                            radius: 18
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: root.shellState.accent_color }
                                GradientStop { position: 1.0; color: theme.warmAccent }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "PD"
                                color: "#081119"
                                font.family: theme.monoFont
                                font.pixelSize: 15
                                font.weight: Font.Black
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Pro Desk Shell"
                                color: theme.textStrong
                                font.family: theme.titleFont
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }

                            Text {
                                text: "Desktop shell online"
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 18
                        color: "#15293c"
                        border.width: 1
                        border.color: "#315677"
                        implicitHeight: 74

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
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
                                text: root.shellState.active_window_class + " / " + root.shellState.active_workspace
                                color: theme.textSoft
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
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

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 26
                color: "#0f1d2c"
                border.width: 1
                border.color: "#264760"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "Workspace focus"
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

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 20
                        color: "#132537"
                        border.width: 1
                        border.color: "#325a79"
                        implicitHeight: 54

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: 15
                                color: root.shellState.media_playing ? "#214231" : "#263446"
                                border.width: 1
                                border.color: root.shellState.media_playing ? "#4f9f73" : "#486889"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.shellState.media_playing ? "ON" : "IDLE"
                                    color: root.shellState.media_playing ? theme.mintAccent : theme.textSoft
                                    font.family: theme.monoFont
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: root.shellState.media_title.length > 0 ? root.shellState.media_title : "No active media session"
                                    color: theme.textStrong
                                    font.family: theme.bodyFont
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: root.shellState.media_artist.length > 0 ? root.shellState.media_artist : "Control center and launcher are ready."
                                    color: root.shellState.media_playing ? theme.mintAccent : theme.textDim
                                    font.family: theme.bodyFont
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 430
                Layout.fillHeight: true
                radius: 24
                color: "#0f1c2a"
                border.width: 1
                border.color: "#29465f"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 18
                            color: "#142739"
                            border.width: 1
                            border.color: "#315677"
                            implicitHeight: 64

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2

                                Text {
                                    text: root.shellState.network_name
                                    color: theme.textStrong
                                    font.family: theme.bodyFont
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: "Vol " + root.shellState.volume_percent + "%  /  Bri " + root.shellState.brightness_percent + "%"
                                    color: theme.textSoft
                                    font.family: theme.monoFont
                                    font.pixelSize: 10
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 138
                            radius: 18
                            color: root.shellState.battery_charging ? "#183226" : "#271f16"
                            border.width: 1
                            border.color: root.shellState.battery_charging ? "#438362" : "#775d33"
                            implicitHeight: 64

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2

                                Text {
                                    text: root.pad(root.now.getHours()) + ":" + root.pad(root.now.getMinutes())
                                    color: theme.textStrong
                                    font.family: theme.titleFont
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                }

                                Text {
                                    text: root.shellState.battery_percent + "%  /  " + (root.shellState.battery_charging ? "charging" : root.shellState.network_state)
                                    color: root.shellState.battery_charging ? theme.mintAccent : theme.warmAccent
                                    font.family: theme.bodyFont
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 10
                        rowSpacing: 10

                        ShellButton {
                            text: "Launcher"
                            onClicked: root.shellState.toggle_launcher()
                        }

                        ShellButton {
                            text: "Overview"
                            fill: "#1a3246"
                            borderColor: "#4b7fa4"
                            onClicked: root.shellState.toggle_overview()
                        }

                        ShellButton {
                            text: "Controls"
                            fill: "#203022"
                            borderColor: "#4b7a5c"
                            onClicked: root.shellState.toggle_quick_settings()
                        }

                        ShellButton {
                            text: "Inbox"
                            fill: "#302519"
                            borderColor: "#7d6437"
                            onClicked: root.shellState.toggle_notifications()
                        }

                        ShellButton {
                            text: "Theme"
                            fill: "#2c2032"
                            borderColor: "#76538a"
                            onClicked: root.shellState.toggle_wallpaper_selector()
                        }

                        ShellButton {
                            text: "Power"
                            fill: "#321f25"
                            borderColor: "#85545e"
                            onClicked: root.shellState.toggle_session()
                        }
                    }

                    ShellButton {
                        text: "Open Settings"
                        Layout.fillWidth: true
                        fill: "#152d40"
                        borderColor: "#436f93"
                        onClicked: root.shellState.toggle_settings()
                    }
                }
            }
        }
    }
}
