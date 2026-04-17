import QtQuick
import QtQuick.Layouts

import "../foundation"

FrostedPanel {
    id: root

    property string itemsJson: "[]"
    property var theme
    property var shellState
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
                running: modelData.running || false
                active: modelData.active || false
                pinned: modelData.pinned || false
                magnification: root.magnification
                onActivated: root.shellState.activate_dock_item(appId)
                onContextRequested: root.shellState.toggle_dock_pin(appId)
            }
        }
    }
}
