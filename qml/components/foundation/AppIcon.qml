import QtQuick

Item {
    id: root

    property var theme
    property string displayName: "App"
    property string iconPath: ""
    property color fallbackColor: "transparent"
    property color textColor: theme ? theme.textPrimary : "#162135"
    property real padding: Math.round(Math.min(width, height) * 0.16)
    readonly property bool showingIcon: iconImage.status === Image.Ready
    readonly property string fallbackLabel: initials(displayName)

    function initials(value) {
        const trimmed = (value || "").trim()
        if (trimmed.length === 0) {
            return "?"
        }

        const parts = trimmed.split(/\s+/).filter(Boolean)
        if (parts.length > 1) {
            return (parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase()
        }

        return trimmed.slice(0, 2).toUpperCase()
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) * 0.3
        color: root.fallbackColor
    }

    Image {
        id: iconImage
        anchors.fill: parent
        anchors.margins: root.padding
        source: root.iconPath.length > 0 ? "file://" + root.iconPath : ""
        asynchronous: true
        cache: true
        smooth: true
        sourceSize.width: Math.max(64, width * 2)
        sourceSize.height: Math.max(64, height * 2)
        fillMode: Image.PreserveAspectFit
        visible: root.showingIcon
    }

    Text {
        anchors.centerIn: parent
        visible: !root.showingIcon
        text: root.fallbackLabel
        color: root.textColor
        font.family: root.theme ? root.theme.displayFont : "Sans Serif"
        font.pixelSize: Math.round(Math.min(root.width, root.height) * 0.34)
        font.weight: Font.DemiBold
    }
}
