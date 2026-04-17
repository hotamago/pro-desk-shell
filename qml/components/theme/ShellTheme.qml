import QtQuick

QtObject {
    id: root

    property color accentColor: "#5d91ff"
    property color backgroundTop: "#d7e4f5"
    property color backgroundBottom: "#ecf2fa"
    property color glassFill: "#d9f8fbff"
    property color glassStrong: "#eef9fbff"
    property color glassBorder: "#7affffff"
    property color dockFill: "#d8ffffff"
    property color dockBorder: "#8fffffff"
    property color textPrimary: "#162135"
    property color textMuted: "#5c6a82"
    property color textSoft: "#7f8ca3"
    property color cardFill: "#f6f9fd"
    property color indicator: accentColor
    property color critical: "#c25959"
    property color shadowTone: "#140d2136"

    property string displayFont: "SF Pro Display"
    property string bodyFont: "SF Pro Text"
    property real cornerRadiusLarge: 28
    property real cornerRadiusMedium: 22
    property real cornerRadiusSmall: 16
}
