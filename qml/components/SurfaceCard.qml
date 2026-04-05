import QtQuick

Rectangle {
    id: root

    property real padding: 18
    property color tintTop: "#182434"
    property color tintBottom: "#101823"
    property color borderTint: "#27425b"

    default property alias contentData: contentItem.data

    radius: 28
    border.width: 1
    border.color: borderTint
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: Qt.rgba(root.tintTop.r, root.tintTop.g, root.tintTop.b, 0.96)
        }

        GradientStop {
            position: 1.0
            color: Qt.rgba(root.tintBottom.r, root.tintBottom.g, root.tintBottom.b, 0.96)
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.04)
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
