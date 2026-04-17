import QtQuick
import QtQuick.Controls

Button {
    id: root

    property var theme
    property bool accented: false
    property bool quiet: false

    hoverEnabled: true
    padding: 0
    implicitHeight: 38
    implicitWidth: Math.max(92, contentItem.implicitWidth + 28)

    background: Rectangle {
        radius: 19
        color: root.accented
               ? theme.accentColor
               : (root.down
                  ? "#f1f5fb"
                  : (root.hovered ? "#eef4fb" : (root.quiet ? "#f6f9fc99" : "#f9fbfecc")))
        border.width: 1
        border.color: root.accented ? "#33ffffff" : "#55ffffff"
    }

    contentItem: Label {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.text
        color: root.accented ? "#ffffff" : theme.textPrimary
        font.family: theme.displayFont
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }
}
