import Quickshell
import QtQuick

PopupWindow {
    id: calendar
    property bool open: false
    property var anchorWindow: null

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow ? anchorWindow.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorWindow ? anchorWindow.height + 4 : 0
    grabFocus: true

    implicitWidth: 260
    implicitHeight: bg.height
    visible: open
    color: "transparent"

    // the grid below only computes "today" once at creation; re-stamp it
    // every time the popup opens so it can't go stale across midnight
    onOpenChanged: if (open) calGrid.now = new Date()

    Rectangle {
        id: bg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: mainColumn.implicitHeight + mainColumn.anchors.margins * 2
        opacity: calendar.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        color: "#424242"
        border.color: "#505050"
        border.width: 1
        radius: 12

        Column {
            id: mainColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Time.date_
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
                font.family: "monospace"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    Text {
                        required property string modelData
                        width: 28
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: "#bdbdbd"
                        font.pixelSize: 10
                        font.family: "monospace"
                    }
                }
            }

            Grid {
                id: calGrid
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                spacing: 2

                property var now: new Date()
                property int year: now.getFullYear()
                property int month: now.getMonth()
                property int today: now.getDate()
                property int firstDay: new Date(year, month, 1).getDay()
                property int daysInMonth: new Date(year, month + 1, 0).getDate()

                Repeater {
                    model: 42
                    Rectangle {
                        required property int index
                        property int dayNum: index - calGrid.firstDay + 1
                        property bool isDay: dayNum >= 1 && dayNum <= calGrid.daysInMonth
                        property bool isToday: isDay && dayNum === calGrid.today
                        width: 28
                        height: 22
                        radius: 4
                        color: isToday ? "#ffffff" : "transparent"
                        visible: isDay
                        Text {
                            anchors.centerIn: parent
                            text: isDay ? dayNum : ""
                            color: isToday ? "#424242" : "#ffffff"
                            font.pixelSize: 11
                            font.family: "monospace"
                            font.bold: isToday
                        }
                    }
                }
            }
        }
    }
}
