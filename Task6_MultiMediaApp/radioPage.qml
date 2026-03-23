import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import QtMultimedia

import QtQuick.VirtualKeyboard

Page {
    id : radioPageId

    Material.theme: Material.Light
    Material.primary: "#aa272d"
    Material.accent: "#203947"

    // stations model
    ListModel  {
        id: stationsModel
    }
    property var currentStation: null


    //pagination properties
    property int currentPage: 0
    property int itemsPerPage: 10
    property bool hasNextPage: false


    property bool isLoading: false


    // search and filter properties
    property string searchQuery: ""
    property string tagFilter: ""


    //======================= API functions ===================================

    // Generic FETCH
    function fetchData(url, callback) {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                console.log("HEADERS_RECEIVED - status:", xhr.status)
            }

            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("DONE - Request finished")
                console.log("Status:",     xhr.status)
                console.log("StatusText:", xhr.statusText)


                if (xhr.status === 200) {
                    callback(xhr.responseText)
                } else {
                    console.log("Error: Cannot fetch data from API")
                    callback(null)
                }
            }
        }

        xhr.open("GET", url)
        console.log("Sending GET request to:", url)
        xhr.send()
    }

    // Main Stations fetch function
    function fetchStations() {
        console.log("Starting fetch for stations")

        // Reset everything before new fetch
        stationsModel.clear()

        // build the url with the search and filter parameters
        var url = buildURL()

        fetchData(url, function(response) {
            if (response) {
                console.log("API response received")

                var data = JSON.parse(response)

                // parse
                parseStations(data)

            } else {
                console.log("No response received from API")
            }
        })
    }

    // Parses the stations of the API response
    function parseStations(stations) {
        console.log("Parsing stations data")

        hasNextPage = (stations.length === itemsPerPage) // not perfect check but works for now

        for (var i = 0; i < stations.length; i++) {
            stationsModel.append({
                                     "stationuuid": stations[i].stationuuid,
                                     "name": stations[i].name,
                                     "url": stations[i].url_resolved || stations[i].url,
                                     "favicon": stations[i].favicon || "",  //  For station logo
                                     "codec": stations[i].codec,
                                     "tags": stations[i].tags,
                                     "country": stations[i].country,
                                     "votes": stations[i].votes
                                 })
            // log each station :
            console.log("Station added:", stations[i].name, "URL:", stations[i].url, "Tags:", stations[i].tags, "Country:", stations[i].country)
        }
        console.log("stations count:", stationsModel.count)
    }

    // Build the url with the search and filter parameters
    function buildURL() {
        var url = "https://de1.api.radio-browser.info/json/stations/search?"
        url += "hidebroken=true"
        url += "&limit=" + itemsPerPage
        url += "&offset=" + (currentPage * itemsPerPage)
        url += "&order=votes&reverse=true"

        if (searchQuery) {
            url += "&name=" + encodeURIComponent(searchQuery)
        }
        if (tagFilter) {
            url += "&tag=" + encodeURIComponent(tagFilter)
        }

        return url
    }

    function nextPage() {
        if (hasNextPage) {
            currentPage++
            fetchStations()
        }
    }

    function previousPage() {
        if (currentPage > 0) {
            currentPage--
            fetchStations()
        }
    }

    //===================== Multimedia player functions ===============================
    MediaPlayer {
        id: mediaPlayer

        audioOutput: AudioOutput {
            id: audioOutput
            volume: 0.5
        }

        onPlaybackStateChanged: {
            console.log("Playback state:", playbackState)
        }

        onMediaStatusChanged: {
            console.log("Media status:", mediaStatus)

            if (mediaStatus === MediaPlayer.InvalidMedia) {
                console.log("Error: Invalid media or stream unavailable")
            }
        }

        onErrorOccurred: function(error, errorString) {
            console.log("Media error:", error, errorString)
        }
    }

    // Helper function to play a station
    function playStation(station) {
        currentStation = station
        mediaPlayer.stop()
        mediaPlayer.source = station.url

        // increment the click count of the station (required by the API)
         var clickUrl = "https://de1.api.radio-browser.info/json/url/" +station.stationuuid
         fetchData(clickUrl, function(response) {
             if (response) {
                 console.log("Click count updated for station:", station.name)
             } else {
                 console.log("Failed to update click count for station:", station.name)
             }
         })

        mediaPlayer.play()
        console.log("Playing:", station.name, station.url)
    }

    function stopPlayback() {
        mediaPlayer.stop()
        mediaPlayer.source = ""
        currentStation = null
    }

    function togglePlayPause() {
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause()
        } else {
            mediaPlayer.play()
        }
    }

    function toggleMute() {
        audioOutput.muted = !audioOutput.muted
    }


    // ===================== UI Components ===================================


    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10


        //=== HEADER ===
        RowLayout {

            Layout.fillWidth: true

            Text {
                text: "Radio Stations"
                font.pixelSize: 30
                color: Material.accent
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Back"
                Material.background: Material.primary
                Material.foreground: "white"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onClicked: {
                    radioPageId.StackView.view.pop()

                }
            }
        }

        // separtor
        Rectangle {
            Layout.fillWidth: true
            height: 3
            color: Material.primary
        }




        // === SEARCH SECTION ===

        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height *0.10
            placeholderText: "Search by station name..."

            onTextChanged: {
                searchQuery = text
            }

            Keys.onReturnPressed: {
                focus = false
            }

            Keys.onEnterPressed: {
                focus = false
            }
        }


        TextField {
            id: tagField
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height *0.10
            placeholderText: "Filter by tag (e.g., arabic, news)..."

            onTextChanged: {
                tagFilter = text.toLowerCase()
            }
            Keys.onReturnPressed: {
                focus = false
            }

            Keys.onEnterPressed: {
                focus = false
            }

        }


        Button {
            id: searchButton
            Layout.preferredWidth: parent.width *0.5
            Layout.preferredHeight: parent.height *0.10
            Material.background: Material.primary
            Material.foreground: "white"
            text: "Search"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                currentPage = 0
                fetchStations()
            }
        }

        // === STATION LIST SECTION ===
        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: Material.primary
            border.width: 2
            radius: 10

            ListView {
                id: stationListView
                anchors.fill: parent
                anchors.margins: 4

                model: stationsModel
                clip: true
                spacing: 8

                delegate: Rectangle {
                    width: stationListView.width
                    height: 80
                    radius: 8
                    color:  stationMouseArea.containsMouse? "#e0e0e0" : "#f5f5f5"
                    border.color: "#cccccc"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // Station logo
                        Image {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            source: model.favicon
                            fillMode: Image.PreserveAspectFit

                            // Fallback when no image
                            Rectangle {
                                anchors.fill: parent
                                color: "#cccccc"
                                visible: parent.status !== Image.Ready
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: "📻"
                                    font.pixelSize: 24
                                }
                            }
                        }

                        // Station info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: model.name
                                font.pixelSize: 16
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.country + " • " + model.codec
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                color: "#666666"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.tags
                                font.pixelSize: 11
                                color: "#888888"
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        // Play button
                        Button {
                            z: 50
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            text: "▶"
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            Material.background: Material.primary
                            Material.foreground: "white"
                            font.pixelSize: 20

                            onClicked: {
                                // pass the station info to the player
                                playStation({
                                                "stationuuid": model.stationuuid,
                                                "name": model.name,
                                                "url": model.url,
                                                "favicon": model.favicon,
                                                "country": model.country,
                                                "codec": model.codec,
                                                "tags": model.tags
                                            })
                                console.log("Station clicked:", model.name, "URL:", model.url)
                            }
                        }
                    }
                    MouseArea{
                        id :stationMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        z : -1
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    text: isLoading ? "Loading..." : "No stations found.\nTry searching for something!"
                    horizontalAlignment: Text.AlignHCenter
                    color: "#888888"
                    visible: stationsModel.count === 0
                }
            }
        }

        // === PAGINATION SECTION ===
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height *0.10
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: "Previous"
                Material.background: Material.primary
                Layout.preferredHeight: mainLayout.height *0.10

                Material.foreground: "white"
                enabled: currentPage > 0
                onClicked: previousPage()
            }

            Text {
                text: "Page " + (currentPage + 1)
                font.pixelSize: 14
            }

            Button {
                text: "Next"
                Material.background: Material.primary
                Material.foreground: "white"
                Layout.preferredHeight: mainLayout.height *0.10

                enabled: hasNextPage
                onClicked: nextPage()
            }
        }

        // === PLAYER SECTION ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: playerLayout.implicitHeight +20
            color: Material.accent
            radius: 8

            RowLayout {
                id: playerLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                // Station logo
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 8
                    color: "#ffffff"

                    Image {
                        id: playerFavicon
                        anchors.fill: parent
                        anchors.margins: 4
                        source: currentStation ? currentStation.favicon : ""
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                    // Fallback icon
                    Text {
                        anchors.centerIn: parent
                        text: "📻"
                        font.pixelSize: 32
                        visible: playerFavicon.status !== Image.Ready
                    }
                }

                // Station info and status
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    // Station name
                    Text {
                        Layout.fillWidth: true
                        text: currentStation ? currentStation.name : "No station selected"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                    }

                    // Station details
                    Text {
                        Layout.fillWidth: true
                        text: currentStation ? (currentStation.country + " • " + currentStation.codec) : ""
                        font.pixelSize: 12
                        color: "#cccccc"
                        visible: currentStation !== null
                        elide: Text.ElideRight

                    }

                    // Status indicator
                    RowLayout {
                        spacing: 8

                        // Loading spinner
                        BusyIndicator {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            running: mediaPlayer.mediaStatus === MediaPlayer.LoadingMedia ||
                                     mediaPlayer.mediaStatus === MediaPlayer.BufferingMedia
                            visible: running
                            Material.accent: "white"
                        }

                        Text {
                            text: {
                                if (!currentStation) return ""

                                switch (mediaPlayer.mediaStatus) {
                                case MediaPlayer.LoadingMedia:
                                    return "Loading..."
                                case MediaPlayer.BufferingMedia:
                                    return "Buffering..."
                                case MediaPlayer.BufferedMedia:
                                case MediaPlayer.LoadedMedia:
                                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState)
                                        return "▶ Playing"
                                    else if (mediaPlayer.playbackState === MediaPlayer.PausedState)
                                        return "⏸ Paused"
                                    else
                                        return "⏹ Stopped"
                                case MediaPlayer.InvalidMedia:
                                    return "❌ Stream unavailable"
                                case MediaPlayer.NoMedia:
                                    return ""
                                default:
                                    return ""
                                }
                            }
                            font.pixelSize: 12
                            color: "#aaaaaa"
                        }
                    }
                }

                // Control buttons
                RowLayout {
                    spacing: 8

                    // Play/Pause button
                    Button {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                        font.pixelSize: 20
                        enabled: currentStation !== null
                        Material.background: "white"
                        Material.foreground: Material.accent

                        onClicked: togglePlayPause()
                    }

                    // Stop button
                    Button {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        text: "⏹"
                        font.pixelSize: 20
                        enabled: currentStation !== null
                        Material.background: "white"
                        Material.foreground: Material.accent

                        onClicked: stopPlayback()
                    }

                    // Mute button
                    Button {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 50
                        text:  audioOutput.muted ? "🔇" : "🔊"
                        font.pixelSize: 20
                        enabled: currentStation !== null
                        Material.background: "white"
                        Material.foreground: Material.accent

                        onClicked: toggleMute()
                    }
                }

                // Volume slider
                ColumnLayout {
                    Layout.preferredWidth: 100
                    spacing: 4

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

                        onValueChanged: {
                            audioOutput.volume = value
                        }

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


    // mouse area to dismiss keyboard when clicking outside of text fields
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            searchField.focus = false
            tagField.focus = false
        }
    }

    InputPanel {
        z: 999
        id: inputPanel
        visible: Qt.inputMethod.visible

        anchors.left: parent.left
        anchors.right: parent.right

        y: Qt.inputMethod.visible ? parent.height - height : parent.height

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }
    }

}
