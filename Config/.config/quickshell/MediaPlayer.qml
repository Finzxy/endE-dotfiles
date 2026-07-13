import Quickshell
import QtQuick
import Quickshell.Services.Mpris

Item {
    id: media
    implicitWidth: 260
    implicitHeight: 92
    width: implicitWidth
    height: implicitHeight

    property var activePlayer: {
        var list = Mpris.players.values
        if (list.length === 0) return null
        for (var i = 0; i < list.length; i++) {
            if (list[i].isPlaying) return list[i]
        }
        return list[0]
    }

    property string cachedArtUrl: ""

    function loadThumbnail() {
        if (!media.activePlayer) {
            media.cachedArtUrl = ""
            return
        }
        if (media.activePlayer.trackArtUrl) {
            media.cachedArtUrl = media.activePlayer.trackArtUrl
        } else if (media.activePlayer.metadata && media.activePlayer.metadata["mpris:artUrl"]) {
            media.cachedArtUrl = media.activePlayer.metadata["mpris:artUrl"]
        } else {
            media.cachedArtUrl = ""
        }
    }

    // activePlayer switching (or disappearing) didn't used to refresh the art,
    // so the old thumbnail stuck around after pausing/closing a player
    onActivePlayerChanged: loadThumbnail()
    Component.onCompleted: loadThumbnail()

    Rectangle {
        id: content
        width: parent.width
        height: parent.height
        color: "#333333"
        radius: 8
        border.color: "#4f4f4f"
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                width: 62
                height: 62
                radius: 6
                color: "#444444"
                border.color: "#555555"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: artImage
                    anchors.fill: parent
                    anchors.margins: 1
                    source: media.cachedArtUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    cache: true
                    sourceSize.width: 112
                    sourceSize.height: 112
                    visible: status === Image.Ready
                }

                Connections {
                    target: media.activePlayer
                    function onTrackArtUrlChanged() { media.loadThumbnail() }
                    function onMetadataChanged() { media.loadThumbnail() }
                    function onPlaybackStateChanged() { media.loadThumbnail() }
                }

                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    color: "#bdbdbd"
                    font.pixelSize: 14
                    visible: !artImage.visible
                }
            }

            Column {
                width: Math.max(0, parent.width - 62 - 8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    width: parent.width
                    text: media.activePlayer ? (media.activePlayer.trackTitle || "Unknown Title") : "No media playing"
                    color: media.activePlayer ? "#ffffff" : "#888888"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "sans-serif"
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: media.activePlayer ? (media.activePlayer.trackArtist || "Unknown Artist") : ""
                    color: "#b3b3b3"
                    font.pixelSize: 9
                    font.family: "sans-serif"
                    elide: Text.ElideRight
                    visible: media.activePlayer !== null
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    visible: media.activePlayer !== null

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: mousePrev.containsPress ? "#ffffff" : mousePrev.containsMouse ? "#ffffff" : "#353535"
                        opacity: (media.activePlayer && media.activePlayer.canGoPrevious) ? 1 : 0.45
                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            color: mousePrev.containsMouse ? "#353535" : "#ffffff"
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: mousePrev
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: media.activePlayer && media.activePlayer.canGoPrevious
                            onClicked: if (media.activePlayer) media.activePlayer.previous()
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: mousePlay.containsPress ? "#ffffff" : mousePlay.containsMouse ? "#ffffff" : "#353535"
                        opacity: (media.activePlayer && media.activePlayer.canTogglePlaying) ? 1 : 0.45
                        Text {
                            anchors.centerIn: parent
                            text: media.activePlayer && media.activePlayer.isPlaying ? "⏸" : "▶"
                            color: mousePlay.containsMouse ? "#353535" : "#ffffff"
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: mousePlay
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: media.activePlayer && media.activePlayer.canTogglePlaying
                            onClicked: {
                                if (!media.activePlayer) return
                                if (media.activePlayer.isPlaying) media.activePlayer.pause()
                                else media.activePlayer.play()
                            }
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: mouseNext.containsPress ? "#ffffff" : mouseNext.containsMouse ? "#ffffff" : "#353535"
                        opacity: (media.activePlayer && media.activePlayer.canGoNext) ? 1 : 0.45
                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            color: mouseNext.containsMouse ? "#353535" : "#ffffff"
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: mouseNext
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: media.activePlayer && media.activePlayer.canGoNext
                            onClicked: if (media.activePlayer) media.activePlayer.next()
                        }
                    }
                }
            }
        }
    }
}
