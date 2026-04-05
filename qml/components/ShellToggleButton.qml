import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color activeFill: "#193446"
    property color activeFillHover: Qt.lighter(activeFill, 1.08)
    property color inactiveFill: "#132436"
    property color inactiveFillHover: Qt.lighter(inactiveFill, 1.06)
    property color activeBorderColor: "#58cde8"
    property color inactiveBorderColor: "#31506c"
    property color textColor: "#edf6ff"

    checkable: true
    implicitHeight: 54
    implicitWidth: Math.max(148, label.implicitWidth + 92)
    padding: 0
    hoverEnabled: true

    contentItem: Row {
        leftPadding: 14
        rightPadding: 12
        spacing: 10

        Text {
            id: label

            width: parent.width - stateBadge.width - 10
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            color: control.textColor
            font.family: "Readex Pro"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            id: stateBadge

            width: 44
            height: 28
            radius: 14
            anchors.verticalCenter: parent.verticalCenter
            color: control.checked ? "#dff9ff" : "#1b3044"
            border.width: 1
            border.color: control.checked ? "#ffffff" : "#40607d"

            Text {
                anchors.centerIn: parent
                text: control.checked ? "ON" : "OFF"
                color: control.checked ? "#081119" : "#aac0d4"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }
    }

    background: Rectangle {
        radius: 18
        color: control.checked
               ? (control.down ? Qt.darker(control.activeFill, 1.12) : (control.hovered ? control.activeFillHover : control.activeFill))
               : (control.down ? Qt.darker(control.inactiveFill, 1.08) : (control.hovered ? control.inactiveFillHover : control.inactiveFill))
        border.width: 1
        border.color: control.checked ? control.activeBorderColor : control.inactiveBorderColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, control.checked ? 0.08 : 0.04)
        }
    }
}
