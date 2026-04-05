import QtQuick
import QtQuick.Controls

TextField {
    id: control

    property color fill: "#122335"
    property color fillFocus: "#173048"
    property color borderColor: "#2f5371"
    property color borderFocusColor: "#63d7ff"
    property color textColor: "#edf6ff"
    property color placeholderColor: "#6f859a"

    implicitHeight: 48
    padding: 0
    leftPadding: 16
    rightPadding: 16
    topPadding: 0
    bottomPadding: 0
    color: textColor
    selectedTextColor: "#081119"
    selectionColor: "#7ed8ff"
    font.family: "Readex Pro"
    font.pixelSize: 13
    verticalAlignment: TextInput.AlignVCenter

    background: Rectangle {
        radius: 18
        color: control.activeFocus ? control.fillFocus : control.fill
        border.width: 1
        border.color: control.activeFocus ? control.borderFocusColor : control.borderColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, control.activeFocus ? 0.08 : 0.04)
        }
    }

    placeholderTextColor: placeholderColor
}
