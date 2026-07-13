import Quickshell
import QtQuick

Scope {
    id: root

    property bool launcherOpen: false
    property bool calendarOpen: false

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 34
            color: "#303030"

            Rectangle {
                width: 28
                height: 22
                radius: 6
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.calendarOpen = false
                        root.launcherOpen = !root.launcherOpen
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: timeText.implicitWidth + 28
                height: timeText.implicitHeight + 16
                radius: 8
                color: "transparent"
                Text {
                    id: timeText
                    anchors.centerIn: parent
                    text: Time.time
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.launcherOpen = false
                        root.calendarOpen = !root.calendarOpen
                    }
                }
            }

            Launcher {
                anchorWindow: bar
                open: root.launcherOpen
                onRequestClose: root.launcherOpen = false
            }

            Calendar {
                anchorWindow: bar
                open: root.calendarOpen
            }

        }
    }
}

