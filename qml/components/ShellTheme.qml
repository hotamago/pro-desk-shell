import QtQuick

QtObject {
    readonly property color canvasTop: "#060f18"
    readonly property color canvasBottom: "#0b1420"
    readonly property color canvasAmbient: "#102033"
    readonly property color surfaceTop: "#16273b"
    readonly property color surfaceMiddle: "#101d2d"
    readonly property color surfaceBottom: "#0b1520"
    readonly property color surfaceElevated: "#1a3047"
    readonly property color surfaceBorder: "#284663"
    readonly property color surfaceBorderStrong: "#3a6388"
    readonly property color surfaceHighlight: "#59d3ff"
    readonly property color warmAccent: "#ffaf72"
    readonly property color mintAccent: "#7ef0bc"
    readonly property color goldAccent: "#f0d18d"
    readonly property color dangerAccent: "#ff7d8b"
    readonly property color textStrong: "#edf6ff"
    readonly property color textSoft: "#b2c4d6"
    readonly property color textDim: "#74889d"
    readonly property color textFaint: "#536578"
    readonly property color scrim: "#c9081119"
    readonly property color shadow: "#80040a12"
    readonly property real radiusS: 16
    readonly property real radiusM: 22
    readonly property real radiusL: 28
    readonly property real radiusXl: 34
    readonly property real spacingXs: 6
    readonly property real spacingS: 10
    readonly property real spacingM: 14
    readonly property real spacingL: 18
    readonly property real spacingXl: 24
    readonly property string titleFont: "Space Grotesk"
    readonly property string bodyFont: "Readex Pro"
    readonly property string monoFont: "JetBrains Mono"

    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }
}
