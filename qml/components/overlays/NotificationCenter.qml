import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../foundation"

Item {
    id: root

    property bool open: false
    property string notificationsJson: "[]"
    property var theme
    property var shellState
    property var notifications: parseNotifications(notificationsJson)

    visible: open
    opacity: open ? 1 : 0

    function parseNotifications(payload) {
        try {
            return JSON.parse(payload)
        } catch (error) {
            return []
        }
    }

    onNotificationsJsonChanged: notifications = parseNotifications(notificationsJson)

    FrostedPanel {
        anchors.fill: parent
        theme: root.theme
        padding: 22
        radius: 34
        fillColor: "#ecf5fc"
        borderColor: "#b2ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            Label {
                text: "Notification Center"
                color: root.theme.textPrimary
                font.family: root.theme.displayFont
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }

            Label {
                text: root.notifications.length > 0
                      ? root.notifications.length + " items in history"
                      : "No notifications yet"
                color: root.theme.textMuted
                font.family: root.theme.bodyFont
                font.pixelSize: 12
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                clip: true
                model: root.notifications

                delegate: Rectangle {
                    width: ListView.view.width
                    height: Math.max(110, notificationBody.implicitHeight + 58)
                    radius: 24
                    color: "#fbfdff"
                    border.width: 1
                    border.color: "#dfe7f3"
                    opacity: modelData.dismissed ? 0.55 : 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                Layout.fillWidth: true
                                text: modelData.app_name + "  /  " + modelData.timestamp
                                color: root.theme.textMuted
                                font.family: root.theme.bodyFont
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            GlassButton {
                                theme: root.theme
                                text: "dismiss"
                                quiet: true
                                onClicked: root.shellState.dismiss_notification(modelData.notification_id)
                            }
                        }

                        Label {
                            text: modelData.title
                            color: root.theme.textPrimary
                            font.family: root.theme.displayFont
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Label {
                            id: notificationBody
                            text: modelData.body
                            wrapMode: Text.WordWrap
                            color: root.theme.textSoft
                            font.family: root.theme.bodyFont
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
