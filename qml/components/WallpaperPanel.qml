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
        tintTop: "#16293d"
        tintBottom: "#0c1520"
        borderTint: "#335c7c"
        glowTint: root.shellState.accent_color
        glowStrength: 0.12

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Wallpaper Studio"
                        color: theme.textStrong
                        font.family: theme.titleFont
                        font.pixelSize: 24
                        font.weight: Font.Black
                    }

                    Text {
                        text: "Persist shell appearance with local themes and wallpaper settings."
                        color: theme.textDim
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }

                ShellButton {
                    text: "Close"
                    compact: true
                    onClicked: root.shellState.toggle_wallpaper_selector()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    radius: 26
                    border.width: 1
                    border.color: "#375977"
                    implicitHeight: 186
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.shellState.accent_color }
                        GradientStop { position: 0.55; color: root.shellState.accent_color_secondary }
                        GradientStop { position: 1.0; color: root.shellState.accent_color_tertiary }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 2

                        Text {
                            text: root.shellState.theme_name
                            color: "#09131b"
                            font.family: theme.titleFont
                            font.pixelSize: 28
                            font.weight: Font.Black
                        }

                        Text {
                            text: root.shellState.wallpaper_path.length > 0 ? root.shellState.wallpaper_path : "No wallpaper path configured yet"
                            color: "#14212d"
                            font.family: theme.bodyFont
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            text: "Theme preview"
                            color: "#162331"
                            font.family: theme.monoFont
                            font.pixelSize: 10
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 170
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 20
                        color: "#132334"
                        border.width: 1
                        border.color: "#294a64"
                        implicitHeight: 54

                        Text {
                            anchors.centerIn: parent
                            text: "Accent 1"
                            color: theme.textStrong
                            font.family: theme.bodyFont
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 20
                        color: root.shellState.accent_color_secondary
                        border.width: 1
                        border.color: "#8b6946"
                        implicitHeight: 54
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 20
                        color: root.shellState.accent_color_tertiary
                        border.width: 1
                        border.color: "#4c8a66"
                        implicitHeight: 54
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                ShellButton {
                    text: "ii-horizon"
                    Layout.fillWidth: true
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-horizon")
                        root.shellState.set_accent_color_value("#56d6ff")
                    }
                }

                ShellButton {
                    text: "ii-sunset"
                    Layout.fillWidth: true
                    fill: "#36261e"
                    borderColor: "#8c6645"
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-sunset")
                        root.shellState.set_accent_color_value("#ff9163")
                    }
                }

                ShellButton {
                    text: "ii-forest"
                    Layout.fillWidth: true
                    fill: "#223125"
                    borderColor: "#4d8c64"
                    onClicked: {
                        root.shellState.set_theme_name_value("ii-forest")
                        root.shellState.set_accent_color_value("#53d997")
                    }
                }
            }

            ShellTextField {
                id: wallpaperPathField

                Layout.fillWidth: true
                placeholderText: "/path/to/wallpaper.png"
                text: root.shellState.wallpaper_path
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ShellButton {
                    text: "Save wallpaper path"
                    onClicked: root.shellState.set_wallpaper_path_value(wallpaperPathField.text)
                }

                ShellTextField {
                    id: themeField

                    Layout.fillWidth: true
                    placeholderText: "ii-horizon"
                    text: root.shellState.theme_name
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ShellTextField {
                    id: accentField

                    Layout.fillWidth: true
                    placeholderText: "#56d6ff"
                    text: root.shellState.accent_color
                }

                ShellButton {
                    text: "Save accent"
                    onClicked: root.shellState.set_accent_color_value(accentField.text)
                }
            }

            ShellButton {
                text: "Save theme name"
                Layout.fillWidth: true
                fill: "#183148"
                borderColor: "#497ea6"
                onClicked: root.shellState.set_theme_name_value(themeField.text)
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
