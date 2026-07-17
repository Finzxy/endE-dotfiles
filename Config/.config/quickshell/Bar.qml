import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            property bool launcherOpen: false
            property bool calendarOpen: false

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
                    text: "󰣇"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        bar.calendarOpen = false
                        bar.launcherOpen = !bar.launcherOpen
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: timeText.implicitWidth + 28
                height: timeText.implicitHeight + 16
                radius: 8
                color: "transparent"
                
                Timer {
                    id: calendarTimer
                    interval: 150
                    onTriggered: bar.calendarOpen = false
                }

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
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor // Kursor berubah menjadi tangan di sini
                    onEntered: {
                        calendarTimer.stop()
                        bar.launcherOpen = false
                        bar.calendarOpen = true
                    }
                    onExited: {
                        calendarTimer.start()
                    }
                }
            }

            Launcher {
                anchorWindow: bar
                open: bar.launcherOpen
                onRequestClose: bar.launcherOpen = false
            }

            Calendar {
                anchorWindow: bar
                open: bar.calendarOpen
            }

        }
    }
}