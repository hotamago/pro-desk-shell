import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var shellState

    ShellTheme {
        id: theme
    }

    SurfaceCard {
        anchors.fill: parent
        tintTop: "#172433"
        tintBottom: "#0f1720"
        borderTint: "#2b485f"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Wallpaper + Theme"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 19
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Persist shell appearance with local themes and wallpaper settings."
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                Button {
                    text: "Close"
                    onClicked: root.shellState.toggle_wallpaper_selector()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 148
                radius: 22
                border.width: 1
                border.color: "#35556f"
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.shellState.accent_color
                    }

                    GradientStop {
                        position: 0.55
                        color: root.shellState.accent_color_secondary
                    }

                    GradientStop {
                        position: 1.0
                        color: root.shellState.accent_color_tertiary
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
                    text: root.shellState.theme_name
                    color: "#09131b"
                    font.family: theme.titleFont
                    font.pixelSize: 22
                    font.weight: Font.Black
                }
            }

            TextField {
                id: wallpaperPathField

                Layout.fillWidth: true
                placeholderText: "/path/to/wallpaper.png"
                text: root.shellState.wallpaper_path
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Save path"
                    onClicked: root.shellState.set_wallpaper_path_value(wallpaperPathField.text)
                }

                Button {
                    text: "ii-horizon"
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-horizon")
                        root.shellState.set_accent_color_value("#56d6ff")
                    }
                }

                Button {
                    text: "ii-sunset"
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-sunset")
                        root.shellState.set_accent_color_value("#ff9163")
                    }
                }

                Button {
                    text: "ii-forest"
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-forest")
                        root.shellState.set_accent_color_value("#53d997")
                    }
                }
            }

            TextField {
                id: accentField

                Layout.fillWidth: true
                placeholderText: "#56d6ff"
                text: root.shellState.accent_color
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Save accent"
                    onClicked: root.shellState.set_accent_color_value(accentField.text)
                }

                Button {
                    text: "Save theme name"
                    onClicked: root.shellState.set_theme_name_value(themeField.text)
                }
            }

            TextField {
                id: themeField

                Layout.fillWidth: true
                placeholderText: "ii-horizon"
                text: root.shellState.theme_name
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
