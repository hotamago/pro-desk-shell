import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    required property var shellState

    spacing: 8

    Repeater {
        model: root.shellState.workspace_labels

        delegate: Rectangle {
            required property string modelData

            readonly property bool active: modelData === root.shellState.active_workspace

            radius: 14
            implicitWidth: label.implicitWidth + 20
            implicitHeight: 32
            color: active ? "#2a435c" : "#172432"
            border.width: 1
            border.color: active ? "#57d5ff" : "#274059"

            Text {
                id: label

                anchors.centerIn: parent
                text: modelData
                color: active ? "#eef8ff" : "#a0b4c8"
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.weight: active ? Font.DemiBold : Font.Medium
            }
        }
    }
}
