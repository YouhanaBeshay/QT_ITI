import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtMultimedia
import QtQuick.Dialogs

import Task6_MultiMediaApp 1.0

Page {
    id: videoPlayerPageId

    // general styling for ui
    Material.theme:  Material.Light
    Material.primary: "#aa272d"
    Material.accent: "#203947"
    property int controlBtnSize: 56


    // black background for immersion while watching :)
    background: Rectangle {
        color: "black"
        visible: isVideoMode
    }


    // =============================== C++ classes ===============================
    UsbScanner {
        id: usbScanner
    }

    function loadUsbFromCpp() {
        var files = usbScanner.getUsbVideoFiles()
        for (var i = 0; i < files.length; i++) {
            if (!isDuplicate(files[i].url))
                tracksModel.append(files[i])
        }
        console.log("USB tracks loaded:", tracksModel.count)
    }

    // =============================== Properties ===============================
    property int    currentIndex:  -1
    property var    currentTrack:  null
    property string currentSource: "local"
    property bool isVideoMode: false
    property bool showControls: true


    // =============================== Tracks list ===============================
    ListModel { id: tracksModel }

    // =============================== FileDialog ===============================
    FileDialog {
        id: fileDialog
        title: "Select Video Files"
        nameFilters: ["Video files (*.mp4 *.mov *.mkv *.webm *.avi *.mpg *.ogg *.flv)"]
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            for (var i = 0; i < selectedFiles.length; i++) {
                var fileUrl  = selectedFiles[i].toString()
                if (isDuplicate(fileUrl)) continue
                var filename = decodeURIComponent(fileUrl.substring(fileUrl.lastIndexOf("/") + 1))
                tracksModel.append({ "title": filename, "url": fileUrl })
            }
            console.log("Local files loaded:", tracksModel.count)
        }
    }

    // =============================== Helper Functions ===============================
    function playTrack(index) {
        if (index < 0 || index >= tracksModel.count) return
        var track = tracksModel.get(index)
        if (!track.url) return
        currentIndex = index
        currentTrack = { "title": track.title, "url": track.url }
        mediaPlayer.stop()
        mediaPlayer.source = track.url
        mediaPlayer.play()
        isVideoMode = true
        console.log("Playing:", track.title)
    }

    function stopPlayback() {
        mediaPlayer.stop()
        mediaPlayer.source = ""
        currentTrack  = null
        currentIndex  = -1
        isVideoMode   = false
    }

    function togglePlayPause() {
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState)
            mediaPlayer.pause()
        else
            mediaPlayer.play()
    }

    function toggleMute()      { audioOutput.muted = !audioOutput.muted }

    function nextTrack() {
        if (currentIndex + 1 < tracksModel.count) playTrack(currentIndex + 1)
    }

    function previousTrack() {
        if (currentIndex > 0) playTrack(currentIndex - 1)
    }

    function formatTime(ms) {
        if (ms <= 0 || isNaN(ms)) return "--:--"
        var s   = Math.floor(ms / 1000)
        var min = Math.floor(s / 60)
        var sec = s % 60
        return min + ":" + (sec < 10 ? "0" + sec : sec)
    }

    function isDuplicate(url) {
        for (var i = 0; i < tracksModel.count; i++)
            if (tracksModel.get(i).url === url) return true
        return false
    }

    // =============================== Media Player ===============================
    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput

        audioOutput: AudioOutput {
            id: audioOutput
            volume: 0.5
        }

        onPlaybackStateChanged: console.log("Playback state:", playbackState)

        onMediaStatusChanged: {
            console.log("Media status:", mediaStatus)
            if (mediaStatus === MediaPlayer.EndOfMedia)  nextTrack()
            if (mediaStatus === MediaPlayer.InvalidMedia)
                console.log("Invalid media:", currentTrack ? currentTrack.url : "")
        }

        onErrorOccurred: function(error, errorString) {
            console.log("Media error:", error, errorString)
        }
    }


    // ===============================
    //  NORMAL PAGE UI
    // ===============================
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // =============================== HEADER ===============================
        RowLayout {
            Layout.fillWidth: true
            visible: !isVideoMode

            Text {
                text: "Video Player"
                font.pixelSize: 30
                color: Material.accent
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Back"
                Material.background: Material.primary
                Material.foreground: "white"
                onClicked: videoPlayerPageId.StackView.view.pop()
            }
        }

        Rectangle {
            visible: !isVideoMode
            Layout.fillWidth: true
            height: 3
            color: Material.primary
        }

        // =============================== SOURCE SELECTOR ===============================
        Rectangle {
            Layout.fillWidth: true
            height: sourceSelectorLayout.implicitHeight + 16
            radius: 8
            color: "#f5f5f5"
            border.color: Material.primary
            border.width: 1
            visible: !isVideoMode


            RowLayout {
                id: sourceSelectorLayout
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                Text {
                    text: "Source:"
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: 14
                    font.bold: true
                    color: Material.accent
                }

                Button {
                    text: "USB"
                    Layout.alignment: Qt.AlignVCenter
                    Material.background: currentSource === "usb"   ? Material.primary : "transparent"
                    Material.foreground: currentSource === "usb"   ? "white"          : Material.accent
                    onClicked: {
                        if (currentSource !== "usb") {
                            currentSource = "usb"
                            tracksModel.clear()
                            stopPlayback()
                        }
                    }
                }

                Button {
                    text: "Local"
                    Layout.alignment: Qt.AlignVCenter
                    Material.background: currentSource === "local" ? Material.primary : "transparent"
                    Material.foreground: currentSource === "local" ? "white"          : Material.accent
                    onClicked: {
                        if (currentSource !== "local") {
                            currentSource = "local"
                            tracksModel.clear()
                            stopPlayback()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: tracksModel.count > 0
                    text: tracksModel.count + " videos"
                    font.pixelSize: 12
                    color: "#888888"
                }

                Button {
                    text: currentSource === "usb" ? "Scan USB" : "Add Files"
                    Layout.alignment: Qt.AlignVCenter
                    Material.background: Material.primary
                    Material.foreground: "white"
                    onClicked: {
                        if (currentSource === "usb") {
                            tracksModel.clear()
                            loadUsbFromCpp()
                        } else {
                            fileDialog.open()
                        }
                    }
                }
            }
        }

        // ========== TRACK LIST ==============
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: Material.primary
            border.width: 2
            radius: 10
            clip: true



            // ============= Video output (shown when playing) ========
            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: VideoOutput.Stretch
                visible: isVideoMode

            }

            MouseArea {
                anchors.fill: videoOutput
                visible: isVideoMode

                onClicked: {
                    togglePlayPause()
                }

                onDoubleClicked: {
                    showControls = !showControls
                }
            }

            // =============== Track list (shown when not in video mode) =============
            ListView {
                id: trackListView
                anchors.fill: parent
                anchors.margins: 4
                model: tracksModel
                clip: true
                spacing: 6
                visible: !isVideoMode

                delegate: Rectangle {
                    width: trackListView.width
                    height: trackRowLayout.implicitHeight + 12
                    radius: 8
                    color: currentIndex === index
                           ? "#dce8f0"
                           : (trackHover.containsMouse ? "#e0e0e0" : "#f5f5f5")
                    border.color: currentIndex === index ? Material.accent : "#cccccc"
                    border.width: currentIndex === index ? 2 : 1

                    RowLayout {
                        id: trackRowLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: "🎬"
                            Layout.alignment: Qt.AlignVCenter
                            font.pixelSize: 22
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: model.title
                            font.pixelSize: 14
                            font.bold: currentIndex === index
                            elide: Text.ElideRight
                            color: currentIndex === index ? Material.accent : "#333333"
                        }

                        Button {
                            z: 50
                            Layout.preferredWidth: controlBtnSize
                            Layout.preferredHeight: controlBtnSize
                            Layout.alignment: Qt.AlignVCenter
                            text: (currentIndex === index &&
                                   mediaPlayer.playbackState === MediaPlayer.PlayingState)
                                  ? "⏸" : "▶"
                            font.pixelSize: 16
                            Material.background: Material.primary
                            Material.foreground: "white"
                            onClicked: {
                                if (currentIndex === index)
                                    togglePlayPause()
                                else
                                    playTrack(index)
                            }
                        }
                    }

                    MouseArea {
                        id: trackHover
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                        onDoubleClicked: playTrack(index)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "No videos loaded.\nSelect Source above."
                    horizontalAlignment: Text.AlignHCenter
                    color: "#888888"
                    visible: tracksModel.count === 0
                }
            }
        }
        // ===================== PLAYER BAR ==========================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: playerBarLayout.implicitHeight + 20
                    color: Material.accent
                    radius: 8

                    visible: showControls

                    opacity: showControls ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 300 }
                    }

                    ColumnLayout {
                        id: playerBarLayout
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        // Now playing label
                        Text {
                            Layout.fillWidth: true
                            text: currentTrack
                                  ? (isVideoMode ? "🎬  " : "🎬  ") + currentTrack.title
                                  : "No video selected"
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                            elide: Text.ElideRight
                        }

                        // Progress row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: formatTime(mediaPlayer.position)
                                font.pixelSize: 11
                                color: "#cccccc"
                                Layout.preferredWidth: 40
                                horizontalAlignment: Text.AlignRight
                            }

                            Slider {
                                id: progressSlider
                                Layout.fillWidth: true
                                from: 0
                                to: mediaPlayer.duration > 0 ? mediaPlayer.duration : 1
                                value: mediaPlayer.position
                                Material.accent: "white"

                                property bool userDragging: false

                                onPressedChanged: {
                                    userDragging = pressed
                                    if (!pressed)
                                        mediaPlayer.position = value
                                }

                                Connections {
                                    target: mediaPlayer
                                    function onPositionChanged() {
                                        if (!progressSlider.userDragging)
                                            progressSlider.value = mediaPlayer.position
                                    }
                                }
                            }

                            Text {
                                text: currentTrack === null ? "--:--" : formatTime(mediaPlayer.duration)
                                font.pixelSize: 11
                                color: "#cccccc"
                                Layout.preferredWidth: 40
                            }
                        }

                        // Controls row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            // ⏮
                            Button {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 46
                                text: "⏮"
                                font.pixelSize: 18
                                enabled: currentIndex > 0
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: previousTrack()
                            }

                            // ▶ / ⏸
                            Button {
                                Layout.preferredWidth: controlBtnSize
                                Layout.preferredHeight: controlBtnSize
                                text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                                font.pixelSize: 18
                                enabled: currentTrack !== null
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: togglePlayPause()
                            }

                            // ⏹
                            Button {
                                Layout.preferredWidth: controlBtnSize
                                Layout.preferredHeight: controlBtnSize
                                text: "⏹"
                                font.pixelSize: 18
                                enabled: currentTrack !== null
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: stopPlayback()
                            }

                            // ⏭
                            Button {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 46
                                text: "⏭"
                                font.pixelSize: 18
                                enabled: currentIndex >= 0 && currentIndex + 1 < tracksModel.count
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: nextTrack()
                            }

                            // Toggle video / list view
                            Button {
                                Layout.preferredWidth: controlBtnSize + 50
                                Layout.preferredHeight: controlBtnSize
                                text: isVideoMode ? "☰ List" : "🎬 Video"
                                font.pixelSize: 13
                                enabled: currentTrack !== null
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: isVideoMode = !isVideoMode
                            }

                            Item { Layout.fillWidth: true }

                            // Status indicator
                            BusyIndicator {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                running: mediaPlayer.mediaStatus === MediaPlayer.LoadingMedia ||
                                         mediaPlayer.mediaStatus === MediaPlayer.BufferingMedia
                                visible: running
                                Material.accent: "white"
                            }

                            Text {
                                text: {
                                    if (!currentTrack) return ""
                                    switch (mediaPlayer.mediaStatus) {
                                    case MediaPlayer.LoadingMedia:   return "Loading..."
                                    case MediaPlayer.BufferingMedia: return "Buffering..."
                                    case MediaPlayer.InvalidMedia:   return "❌ Unavailable"
                                    default:
                                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) return "▶ Playing"
                                        if (mediaPlayer.playbackState === MediaPlayer.PausedState)  return "⏸ Paused"
                                        return "⏹ Stopped"
                                    }
                                }
                                font.pixelSize: 12
                                color: "#aaaaaa"
                            }

                            Item { Layout.fillWidth: true }

                            // 🔇 / 🔊 Mute
                            Button {
                                Layout.preferredWidth: controlBtnSize + 20
                                Layout.preferredHeight: controlBtnSize
                                text: audioOutput.muted ? "🔇" : "🔊"
                                font.pixelSize: 18
                                Material.background: "white"
                                Material.foreground: Material.accent
                                onClicked: toggleMute()
                            }

                            // Volume slider
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                spacing: 2

                                Text {
                                    text: "Volume"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#cccccc"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Slider {
                                    id: volumeSlider
                                    Layout.fillWidth: true
                                    from: 0.0
                                    to: 1.0
                                    value: audioOutput.volume
                                    onValueChanged: audioOutput.volume = value
                                    Material.accent: "white"
                                }

                                Text {
                                    text: Math.round(volumeSlider.value * 100) + "%"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#cccccc"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
    }

}
