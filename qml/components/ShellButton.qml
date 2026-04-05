import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color fill: "#173148"
    property color fillHover: Qt.lighter(fill, 1.08)
    property color borderColor: "#355f80"
    property color textColor: "#edf6ff"
    property bool compact: false

    implicitHeight: compact ? 36 : 44
    implicitWidth: Math.max(compact ? 88 : 108, label.implicitWidth + (compact ? 22 : 30))
    padding: 0
    hoverEnabled: true

    contentItem: Text {
        id: label

        text: control.text
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Readex Pro"
        font.pixelSize: control.compact ? 12 : 13
        font.weight: Font.DemiBold
    }

    background: Rectangle {
        radius: control.compact ? 14 : 18
        color: control.down ? Qt.darker(control.fill, 1.15) : (control.hovered ? control.fillHover : control.fill)
        border.width: 1
        border.color: control.borderColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)
        }
    }
}
