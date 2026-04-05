import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property string compositorName
    required property string activeWorkspace

    readonly property color panelBorder: "#304c63"
    readonly property color sectionBorder: "#24374a"
    readonly property color textStrong: "#f6f8fb"
    readonly property color textMuted: "#8ea2b5"
    readonly property color skyFill: "#162736"
    readonly property color skyStroke: "#2d6b8b"
    readonly property color skyText: "#9ed9ff"
    readonly property color amberFill: "#2b2116"
    readonly property color amberStroke: "#7d5a2e"
    readonly property color amberText: "#f3cb89"
    readonly property color mintFill: "#17261e"
    readonly property color mintStroke: "#2f6f57"
    readonly property color mintText: "#9be1bb"
    readonly property string sansFont: "Noto Sans"
    readonly property string monoFont: "JetBrains Mono"

    component StatusChip: Rectangle {
        required property string label
        required property color fillColor
        required property color strokeColor
        required property color labelColor

        radius: 15
        color: fillColor
        border.width: 1
        border.color: strokeColor
        implicitHeight: 30
        implicitWidth: chipLabel.implicitWidth + 24

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 180
            }
        }

        Text {
            id: chipLabel

            anchors.centerIn: parent
            text: label
            color: labelColor
            font.family: root.sansFont
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
    }

    component ActionButton: Button {
        id: control

        required property color accentColor

        implicitHeight: 40
        implicitWidth: buttonLabel.implicitWidth + 30
        hoverEnabled: true
        padding: 0

        contentItem: Text {
            id: buttonLabel

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: control.text
            color: "#071018"
            font.family: root.sansFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        background: Rectangle {
            radius: 16
            color: control.down ? Qt.darker(control.accentColor, 1.12) : control.accentColor
            border.width: 1
            border.color: Qt.lighter(control.accentColor, 1.08)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 24
        border.width: 1
        border.color: root.panelBorder
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#e00d1218"
            }

            GradientStop {
                position: 1.0
                color: "#d9131d27"
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 460
            Layout.fillHeight: true
            radius: 18
            color: "#c0121922"
            border.width: 1
            border.color: root.sectionBorder

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 14
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#6fe0ff"
                        }

                        GradientStop {
                            position: 1.0
                            color: "#f7c77d"
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "PD"
                        color: "#091119"
                        font.family: root.monoFont
                        font.pixelSize: 13
                        font.weight: Font.Black
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 120
                    spacing: 2

                    Text {
                        text: "Pro Desk Shell"
                        color: root.textStrong
                        font.family: root.sansFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Desktop UI test surface"
                        color: root.textMuted
                        font.family: root.sansFont
                        font.pixelSize: 11
                    }
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    placeholderText: "Search apps, files, actions"
                    placeholderTextColor: "#70859a"
                    color: root.textStrong
                    font.family: root.sansFont
                    font.pixelSize: 13
                    leftPadding: 14
                    rightPadding: 14
                    selectByMouse: true

                    background: Rectangle {
                        radius: 16
                        color: "#141d27"
                        border.width: 1
                        border.color: parent.activeFocus ? "#69d0ff" : "#263544"

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 160
                            }
                        }
                    }
                }

                StatusChip {
                    label: "Ctrl K"
                    fillColor: "#121c25"
                    strokeColor: "#2a3b4d"
                    labelColor: "#c7d3df"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: "#c0141d27"
            border.width: 1
            border.color: root.sectionBorder

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Workspace Lane"
                        color: root.textStrong
                        font.family: root.sansFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Focus mode ready"
                        color: root.textMuted
                        font.family: root.sansFont
                        font.pixelSize: 11
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StatusChip {
                        label: activeWorkspace.length > 0 ? "Active " + activeWorkspace : "Active Desk"
                        fillColor: root.skyFill
                        strokeColor: root.skyStroke
                        labelColor: root.skyText
                    }

                    StatusChip {
                        label: "Code Review"
                        fillColor: "#1f1925"
                        strokeColor: "#59406f"
                        labelColor: "#d1b6ff"
                    }

                    StatusChip {
                        label: "Browser"
                        fillColor: root.amberFill
                        strokeColor: root.amberStroke
                        labelColor: root.amberText
                    }

                    StatusChip {
                        label: "Notes"
                        fillColor: root.mintFill
                        strokeColor: root.mintStroke
                        labelColor: root.mintText
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            radius: 18
            color: "#c0111821"
            border.width: 1
            border.color: root.sectionBorder

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StatusChip {
                            label: compositorName.length > 0 ? compositorName : "Wayland"
                            fillColor: root.skyFill
                            strokeColor: root.skyStroke
                            labelColor: root.skyText
                        }

                        StatusChip {
                            label: "Battery 84%"
                            fillColor: root.mintFill
                            strokeColor: root.mintStroke
                            labelColor: root.mintText
                        }

                        StatusChip {
                            label: "3 alerts"
                            fillColor: root.amberFill
                            strokeColor: root.amberStroke
                            labelColor: root.amberText
                        }
                    }

                    Text {
                        text: "Launch a few common actions and validate spacing, hierarchy, and readability."
                        color: root.textMuted
                        wrapMode: Text.WordWrap
                        font.family: root.sansFont
                        font.pixelSize: 11
                    }
                }

                ActionButton {
                    text: "Launch Demo"
                    accentColor: "#8ce7c1"
                }

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 14
                    color: "#202b36"
                    border.width: 1
                    border.color: "#324252"

                    Text {
                        anchors.centerIn: parent
                        text: "HT"
                        color: root.textStrong
                        font.family: root.monoFont
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
