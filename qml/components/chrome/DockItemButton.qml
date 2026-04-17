import QtQuick

Item {
    id: root

    property var theme
    property string displayName: "App"
    property string appId: ""
    property bool running: false
    property bool active: false
    property bool pinned: false
    property int magnification: 18

    signal activated()
    signal contextRequested()

    implicitWidth: 72
    implicitHeight: 86

    readonly property real iconScale: hoverArea.containsMouse
                                    ? (1.0 + (magnification / 100.0))
                                    : 1.0

    Behavior on iconScale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: 10

        Rectangle {
            id: iconBubble
            width: 62
            height: 62
            radius: 20
            scale: root.iconScale
            color: root.active ? root.theme.accentColor : "#f6f9fd"
            border.width: 1
            border.color: root.active ? "#44ffffff" : "#5effffff"

            Text {
                anchors.centerIn: parent
                text: root.displayName.length > 0 ? root.displayName.charAt(0).toUpperCase() : "?"
                color: root.active ? "#ffffff" : root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 22
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            width: root.active ? 24 : (root.running ? 12 : 0)
            height: 5
            radius: 3
            color: root.active ? root.theme.accentColor : "#8aa0c9"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.running || root.active
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                root.contextRequested()
            } else {
                root.activated()
            }
        }
    }
}
