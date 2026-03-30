import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property string compositorName
    required property string activeWorkspace

    color: "#d91b1f26"
    radius: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Label {
            text: "Pro Desk Shell"
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
        }

        Label {
            text: root.compositorName
            color: "#d6e4ff"
            font.pixelSize: 13
        }

        Label {
            text: root.activeWorkspace
            color: "#fce588"
            font.pixelSize: 13
        }
    }
}
