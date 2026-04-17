import QtQuick
import QtQuick.Layouts

import "../foundation"

FrostedPanel {
    id: root

    property string itemsJson: "[]"
    property var theme
    property var shellState
    property bool autoHide: false
    property bool showRunningIndicators: true
    property int magnification: 18
    property var items: parseItems(itemsJson)

    function parseItems(payload) {
        try {
            return JSON.parse(payload)
        } catch (error) {
            return []
        }
    }

    onItemsJsonChanged: items = parseItems(itemsJson)

    padding: 12
    radius: 30
    fillColor: theme ? theme.dockFill : "#d8ffffff"
    borderColor: theme ? theme.dockBorder : "#88ffffff"
    implicitWidth: dockRow.implicitWidth + (padding * 2)
    implicitHeight: dockRow.implicitHeight + (padding * 2)
    opacity: root.autoHide && !dockHover.hovered ? 0.28 : 1.0
    y: root.autoHide && !dockHover.hovered ? 18 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: dockHover
    }

    RowLayout {
        id: dockRow
        anchors.centerIn: parent
        spacing: 14

        Repeater {
            model: root.items

            DockItemButton {
                theme: root.theme
                displayName: modelData.display_name || modelData.app_id || "App"
                appId: modelData.app_id || ""
                iconPath: modelData.icon_path || ""
                running: modelData.running || false
                active: modelData.active || false
                pinned: modelData.pinned || false
                showRunningIndicator: root.showRunningIndicators
                magnification: root.magnification
                onActivated: root.shellState.activate_dock_item(appId)
                onContextRequested: root.shellState.toggle_dock_pin(appId)
            }
        }
    }
}
