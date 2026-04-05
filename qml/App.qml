import QtQuick
import QtQuick.Controls
import io.hotamago.shell 1.0

ApplicationWindow {
    id: root

    readonly property int panelHeight: 88
    readonly property bool useLayerShell: typeof shellUseLayerShell === "boolean" ? shellUseLayerShell : false

    width: 1440
    height: panelHeight
    visible: true
    color: useLayerShell ? "transparent" : "#0a1016"
    flags: useLayerShell ? Qt.FramelessWindowHint : Qt.Window
    title: "Pro Desk Shell"

    ShellState {
        id: shellState
    }

    DesktopTestBar {
        anchors.fill: parent
        compositorName: shellState.compositorName
        activeWorkspace: shellState.activeWorkspace
    }
}
