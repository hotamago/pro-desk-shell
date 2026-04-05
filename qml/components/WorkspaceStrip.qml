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

            radius: 18
            implicitWidth: active ? label.implicitWidth + 34 : Math.max(54, label.implicitWidth + 22)
            implicitHeight: 36
            color: active ? "#274866" : "#132334"
            border.width: 1
            border.color: active ? "#61d8ff" : "#28435d"

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    visible: active
                    width: 8
                    height: 8
                    radius: 4
                    color: "#61d8ff"
                }

                Text {
                    id: label

                    text: modelData
                    color: active ? "#eef8ff" : "#a5bbcf"
                    font.family: active ? "Readex Pro" : "JetBrains Mono"
                    font.pixelSize: 12
                    font.weight: active ? Font.DemiBold : Font.Medium
                }
            }
        }
    }
}
