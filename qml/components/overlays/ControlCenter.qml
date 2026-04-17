import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

Item {
    id: root

    property bool open: false
    property var theme
    property var shellState

    visible: open
    opacity: open ? 1 : 0

    FrostedPanel {
        anchors.fill: parent
        theme: root.theme
        padding: 22
        radius: 34
        fillColor: "#ecf5fc"
        borderColor: "#b2ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            Label {
                text: "Control Center"
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 124
                radius: 24
                color: "#fbfdff"
                border.width: 1
                border.color: "#e1e9f5"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: "Now Playing"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Label {
                        text: root.shellState.media_title.length > 0 ? root.shellState.media_title : "Nothing playing"
                        color: root.theme.textPrimary
                        font.family: root.theme.displayFont
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: root.shellState.media_artist.length > 0 ? root.shellState.media_artist : "Idle"
                        color: root.theme.textSoft
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 212
                radius: 24
                color: "#fbfdff"
                border.width: 1
                border.color: "#e1e9f5"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Label {
                        text: "Audio"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 150
                        value: root.shellState.volume_percent
                        live: false
                        onMoved: root.shellState.request_volume_percent(Math.round(value))
                    }

                    Label {
                        text: "Brightness"
                        color: root.theme.textMuted
                        font.family: root.theme.bodyFont
                        font.pixelSize: 12
                    }

                    Slider {
                        id: brightnessSlider
                        Layout.fillWidth: true
                        from: 1
                        to: 100
                        value: root.shellState.brightness_percent
                        live: false
                        onMoved: root.shellState.request_brightness_percent(Math.round(value))
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Label {
                            Layout.fillWidth: true
                            text: root.shellState.network_name + "  /  " + root.shellState.network_state
                            color: root.theme.textPrimary
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Label {
                            text: root.shellState.battery_percent + "%"
                            color: root.theme.textPrimary
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "lock"
                    onClicked: root.shellState.request_lock()
                }

                GlassButton {
                    Layout.fillWidth: true
                    theme: root.theme
                    text: "refresh"
                    onClicked: root.shellState.refresh_shell()
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Label {
                Layout.fillWidth: true
                text: root.shellState.status_line
                wrapMode: Text.WordWrap
                color: root.theme.textSoft
                font.family: root.theme.bodyFont
                font.pixelSize: 11
            }
        }
    }
}
