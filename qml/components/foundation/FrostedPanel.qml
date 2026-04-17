import QtQuick

Item {
    id: root

    default property alias contentData: body.data

    property var theme
    property color fillColor: theme ? theme.glassFill : "#d9ffffff"
    property color borderColor: theme ? theme.glassBorder : "#88ffffff"
    property real radius: theme ? theme.cornerRadiusLarge : 24
    property real padding: 20

    implicitWidth: body.implicitWidth + (padding * 2)
    implicitHeight: body.implicitHeight + (padding * 2)

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.fillColor
        border.width: 1
        border.color: root.borderColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, root.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: "#22ffffff"
    }

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
