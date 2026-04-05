import QtQuick

Rectangle {
    id: root

    property real padding: 18
    property color tintTop: "#16273b"
    property color tintBottom: "#0d1622"
    property color borderTint: "#284663"
    property color glowTint: "#59d3ff"
    property real glowStrength: 0.12

    default property alias contentData: contentItem.data

    radius: 30
    border.width: 1
    border.color: borderTint
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: Qt.rgba(root.tintTop.r, root.tintTop.g, root.tintTop.b, 0.97)
        }

        GradientStop {
            position: 1.0
            color: Qt.rgba(root.tintBottom.r, root.tintBottom.g, root.tintBottom.b, 0.98)
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height * 0.52
        radius: root.radius
        color: Qt.rgba(root.glowTint.r, root.glowTint.g, root.glowTint.b, root.glowStrength)
        opacity: 0.55
    }

    Rectangle {
        width: parent.width * 0.55
        height: parent.height * 0.72
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: -parent.width * 0.08
        anchors.topMargin: -parent.height * 0.15
        radius: width / 2
        color: Qt.rgba(root.glowTint.r, root.glowTint.g, root.glowTint.b, root.glowStrength * 0.9)
        opacity: 0.35
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.rgba(1, 1, 1, 0.06)
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
