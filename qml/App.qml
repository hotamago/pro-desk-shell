import QtQuick
import QtQuick.Controls
import io.hotamago.shell 1.0

ApplicationWindow {
    id: root

    width: 1440
    height: 40
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    title: "Pro Desk Shell"

    ShellState {
        id: shellState
    }

    PlaceholderBar {
        anchors.fill: parent
        compositorName: shellState.compositorName
        activeWorkspace: shellState.activeWorkspace
    }
}
