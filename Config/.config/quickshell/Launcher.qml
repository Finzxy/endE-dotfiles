import Quickshell
import QtQuick
import QtQuick.Controls

PanelWindow {
    id: launcher
    signal requestClose
    property bool open: false
    property var anchorWindow: null
    property string filterMode: "all"
    property string query: ""
    property int popupSize: 360

    readonly property string queryLower: query.toLowerCase()

    screen: anchorWindow ? anchorWindow.screen : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"
    visible: open

    onOpenChanged: if (open) {
        query = ""
        searchField.text = ""
        focusTimer.restart()
    }
    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchField.forceActiveFocus()
    }
    Keys.onPressed: (event) => {
        // Shift must stay allowed (capitals, symbols) - only real shortcuts get excluded
        const isShortcut = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)
        if (!searchField.activeFocus && event.text && event.text.length > 0 && !isShortcut) {
            searchField.forceActiveFocus()
            searchField.text += event.text
            event.accepted = true
        }
    }

    // click outside the popup asks Bar to close it; keeps the open binding intact
    MouseArea {
        anchors.fill: parent
        onClicked: launcher.requestClose()
    }

    Rectangle {
        width: launcher.popupSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        height: launcher.open ? launcher.popupSize : 0
        Behavior on height { NumberAnimation { duration: 360; easing.type: Easing.OutCubic } }
        color: "#424242"
        border.color: "#505050"
        border.width: 1
        radius: 0
        topLeftRadius: 12
        topRightRadius: 12

        // swallow clicks so empty space inside the panel doesn't trigger the outside-close above
        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Rectangle {
                width: parent.width
                height: 28
                radius: 6
                color: "#2f2f2f"
                border.color: "#4a4a4a"
                border.width: 1
                TextField {
                    id: searchField
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    background: null
                    focus: true
                    selectByMouse: true
                    color: "#ffffff"
                    placeholderText: "search apps"
                    placeholderTextColor: "#bdbdbd"
                    font.pixelSize: 11
                    font.family: "monospace"
                    onTextChanged: launcher.query = text
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: searchField.focus = true
                    onClicked: searchField.focus = true
                }
            }

            // App drawer list: keep it simple, let Qt handle scrolling.
            Flickable {
                width: parent.width
                height: parent.height - 3
                clip: true
                contentHeight: appColumn.height
                Column {
                    id: appColumn
                    width: parent.width
                    spacing: 3
                    Repeater {
                        model: DesktopEntries.applications.values
                        Rectangle {
                            required property var modelData
                            // computed once per app instead of on every keystroke
                            readonly property string searchText: (modelData.name || "").toLowerCase() + " " + (modelData.comment || "").toLowerCase() + " " + (modelData.genericName || "").toLowerCase()
                            readonly property bool isSystemEntry: modelData.noDisplay
                            width: appColumn.width
                            height: 54
                            radius: 6
                            color: "#333333"
                            border.color: "#4f4f4f"
                            border.width: 1
                            visible: (launcher.filterMode === "system" || !isSystemEntry) && (!launcher.query || searchText.indexOf(launcher.queryLower) !== -1)
                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 8
                                    color: "#444444"
                                    border.color: "#555555"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: appIcon
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        cache: true
                                        sourceSize.width: 64
                                        sourceSize.height: 64
                                        visible: status === Image.Ready
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.name.length > 0 ? modelData.name[0].toUpperCase() : "◌"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                        font.family: "monospace"
                                        visible: !appIcon.visible
                                    }
                                }
                                Column {
                                    width: parent.width - 48
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    Text { width: parent.width; text: modelData.name; color: "#ffffff"; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                    Text { width: parent.width; text: modelData.comment || modelData.genericName || ""; color: "#bdbdbd"; font.pixelSize: 9; elide: Text.ElideRight }
                                }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { launcher.requestClose(); modelData.execute(); } }
                        }
                    }
                }
            }
        }
    }
}
