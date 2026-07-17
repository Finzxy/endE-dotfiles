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
    
    visible: open || slideAnim.running

    onOpenChanged: if (open) {
        query = ""
        searchField.text = ""
        focusTimer.restart()
    }
    
    // Interval dipercepat menjadi 10ms (cukup untuk memicu fokus tanpa delay yang terasa)
    Timer {
        id: focusTimer
        interval: 10
        onTriggered: searchField.forceActiveFocus()
    }
    
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            launcher.requestClose()
            event.accepted = true
            return
        }
        
        const isShortcut = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)
        if (!searchField.activeFocus && event.text && event.text.length > 0 && !isShortcut) {
            searchField.forceActiveFocus()
            searchField.text += event.text
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: launcher.requestClose()
    }

    Rectangle {
        id: bg
        width: launcher.popupSize
        height: launcher.popupSize 
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        
        anchors.bottomMargin: launcher.open ? 0 : -launcher.popupSize
        
        Behavior on anchors.bottomMargin { 
            NumberAnimation { 
                id: slideAnim
                duration: 300 
                easing.type: Easing.OutQuart // Easing yang lebih modern dan mulus
            } 
        }
        
        color: "#242424" // Warna background yang lebih elegan
        border.color: "#3a3a3a"
        border.width: 1
        radius: 0
        topLeftRadius: 12
        topRightRadius: 12

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 16 // Margin diperbesar agar elemen tidak menempel ke tepi
            spacing: 12

            // Kotak Pencarian
            Rectangle {
                width: parent.width
                height: 36 // Sedikit lebih tinggi agar lebih nyaman diklik
                radius: 8
                color: "#1e1e1e"
                border.color: "#3a3a3a"
                border.width: 1
                
                TextField {
                    id: searchField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    background: null
                    focus: true
                    selectByMouse: true
                    color: "#ffffff"
                    placeholderText: "Search apps..."
                    placeholderTextColor: "#888888"
                    font.pixelSize: 12
                    verticalAlignment: TextInput.AlignVCenter
                    onTextChanged: launcher.query = text
                    Keys.onEscapePressed: launcher.requestClose()
                }
                // MouseArea usang yang menimpa fungsi seleksi TextField telah dihapus di sini
            }

            // Daftar Aplikasi
            Flickable {
                width: parent.width
                height: parent.height - 48 // Menyesuaikan tinggi dengan presisi agar tidak overflow
                clip: true
                contentHeight: appColumn.height
                boundsBehavior: Flickable.StopAtBounds
                
                // Menambahkan scrollbar rapi di sisi kanan
                ScrollBar.vertical: ScrollBar { 
                    width: 4
                    policy: ScrollBar.AsNeeded
                }

                Column {
                    id: appColumn
                    width: parent.width
                    spacing: 4
                    
                    Repeater {
                        model: DesktopEntries.applications.values
                        Rectangle {
                            required property var modelData
                            
                            readonly property string searchText: (modelData.name || "").toLowerCase() + " " + (modelData.comment || "").toLowerCase() + " " + (modelData.genericName || "").toLowerCase()
                            readonly property bool isSystemEntry: modelData.noDisplay
                            readonly property bool matchesSearch: (!launcher.query || searchText.indexOf(launcher.queryLower) !== -1)
                            
                            width: appColumn.width
                            height: visible ? 56 : 0 // Optimasi: Tinggi di-set 0 jika disembunyikan agar layout tidak berantakan
                            radius: 8
                            visible: (launcher.filterMode === "system" || !isSystemEntry) && matchesSearch
                            
                            // UI lebih rapi tanpa border, murni mengandalkan highlight warna saat di-hover
                            color: appMouseArea.containsMouse ? "#333333" : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                // Wadah Ikon
                                Item {
                                    width: 40
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Image {
                                        id: appIcon
                                        anchors.fill: parent
                                        source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        cache: true
                                        sourceSize.width: 64
                                        sourceSize.height: 64
                                        visible: status === Image.Ready
                                    }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 8
                                        color: "#383838"
                                        visible: !appIcon.visible
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name.length > 0 ? modelData.name[0].toUpperCase() : "?"
                                            color: "#ffffff"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }
                                }
                                
                                // Wadah Teks
                                Column {
                                    width: parent.width - 60
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text { 
                                        width: parent.width 
                                        text: modelData.name 
                                        color: "#eeeeee" 
                                        font.pixelSize: 12 // Sedikit lebih besar & menggunakan font sistem yang lebih rapi
                                        font.bold: true 
                                        elide: Text.ElideRight 
                                    }
                                    Text { 
                                        width: parent.width 
                                        text: modelData.comment || modelData.genericName || "" 
                                        color: "#888888" 
                                        font.pixelSize: 10 
                                        elide: Text.ElideRight
                                        visible: text.length > 0 // Sembunyikan jika kosong agar teks nama otomatis berada di tengah vertikal
                                    }
                                }
                            }
                            
                            MouseArea { 
                                id: appMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { launcher.requestClose(); modelData.execute(); } 
                            }
                        }
                    }
                }
            }
        }
    }
}