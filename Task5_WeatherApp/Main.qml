import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Weather App")

    // static name instead of using an qpi for the city name for now
    readonly property string cityName:  "Cairo"

    // API url
    readonly property string apiUrl:"REMOVED for GIT"
    //==================  Helper functions ==========================

    // Maps WMO code -> human readable label
    function weatherLabel(code, is_day) {
        if (code === 0)  return is_day ? "Clear Sky"  : "Clear Night"
        if (code === 1)  return "Mainly Clear"
        if (code === 2)  return "Partly Cloudy"
        if (code === 3)  return "Overcast"
        if (code === 45) return "Foggy"
        if (code === 48) return "Icy Fog"
        if (code === 51) return "Light Drizzle"
        if (code === 53) return "Drizzle"
        if (code === 55) return "Heavy Drizzle"
        if (code === 56) return "Freezing Drizzle"
        if (code === 57) return "Heavy Freezing Drizzle"
        if (code === 61) return "Light Rain"
        if (code === 63) return "Rain"
        if (code === 65) return "Heavy Rain"
        if (code === 66) return "Freezing Rain"
        if (code === 67) return "Heavy Freezing Rain"
        if (code === 71) return "Light Snow"
        if (code === 73) return "Snow"
        if (code === 75) return "Heavy Snow"
        if (code === 77) return "Snow Grains"
        if (code === 80) return "Light Showers"
        if (code === 81) return "Showers"
        if (code === 82) return "Heavy Showers"
        if (code === 85) return "Snow Showers"
        if (code === 86) return "Heavy Snow Showers"
        if (code === 95) return "Thunderstorm"
        if (code === 96) return "Thunderstorm w/ Hail"
        if (code === 99) return "Thunderstorm w/ Heavy Hail"
        return "Unknown"
    }
    // Maps WMO code -> emoji icon
    function weatherIcon(code, is_day) {
        if (code === 0)  return is_day ? "☀️" : "🌙"
        if (code === 1)  return is_day ? "🌙" : "🌙"
        if (code === 2)  return "⛅"
        if (code === 3)  return "☁️"
        if (code === 45 || code === 48) return "🌫️"
        if (code >= 51 && code <= 57)   return "🌦️"
        if (code >= 61 && code <= 67)   return "🌧️"
        if (code >= 71 && code <= 77)   return "❄️"
        if (code >= 80 && code <= 82)   return "🌧️"
        if (code === 85 || code === 86) return "❄️"
        if (code >= 95 && code <= 99)   return "⛈️"
        return "❓"
    }

    // gets the day name forom api date string
    function dayName(dateStr) {
        var inputDate = new Date(dateStr)
        var today     = new Date()
        var tomorrow  = new Date()
        tomorrow.setDate(today.getDate() + 1)

        // Compare the date  STRINGS
        var inputDay_Str   = inputDate.toDateString()
        var today_Str   = today.toDateString()
        var tomorrow_Str= tomorrow.toDateString()

        // if it's today or tomorrow we return that instead of the actual day name
        if (inputDay_Str === today_Str)     return "Today"
        if (inputDay_Str === tomorrow_Str)  return "Tomorrow"

        // else we return the actual day name
        var dayNames = [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday"
                ]

        return dayNames[inputDate.getDay()]
    }

    // "2026-03-24T05:53" -> "05:53"
    function getTime(dateTimeStr) {
        var date = new Date(dateTimeStr)
        return date.toLocaleTimeString("en-US", {
                                           hour:   "2-digit",
                                           minute: "2-digit",
                                       })
    }

    // ========================= API Data Storage ==========================


    // Single propery as current weather is not an array
    property var currentWeather: null

    // listModel for days ( 7 days array from API )
    ListModel { id: dailyModelId }

    // ListModel for hours ( 24  hours array from API )
    ListModel { id: hourlyModelId }


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

    // Main Weather Fetch function
    function fetchWeather() {
        console.log("Starting fetchWeather() for", cityName)

        // Reset everything before new fetch
        currentWeather = null
        dailyModelId.clear()
        hourlyModelId.clear()

        fetchData(apiUrl, function(response) {
            if (response) {
                console.log("API response received")

                var data = JSON.parse(response)

                if (!data.current || !data.daily || !data.hourly) {
                    console.log("Error: Missing sections in API response")
                    return
                }

                // parse sections
                parseCurrent(data.current, data.current_units)
                parseDaily(data.daily , data.daily_units)
                parseHourly(data.hourly, data.hourly_units)

            } else {
                console.log("No response received from API")
            }
        })
    }

    // Parses the "current" section of the API response
    function parseCurrent(current , units) {
        console.log("Parsing current weather")

        currentWeather = {
            "temperature":   Math.round(current.temperature_2m) + units.temperature_2m,
            "apparentTemp":  Math.round(current.apparent_temperature) + units.apparent_temperature,
            "humidity":      current.relative_humidity_2m + units.relative_humidity_2m,
            "pressure":      current.surface_pressure + units.surface_pressure,
            "windSpeed":     current.wind_speed_10m + units.wind_speed_10m,
            "weatherCode":   current.weather_code,
            "label":         weatherLabel(current.weather_code, current.is_day),
            "icon":          weatherIcon(current.weather_code, current.is_day)
        }
    }

    // parse the "daily" section of the API response
    function parseDaily(daily, units) {
        console.log("Parsing daily forecast")

        for (var i = 0; i < daily.time.length; i++) {
            dailyModelId.append({
                                    "day":          dayName(daily.time[i]),
                                    "date":         daily.time[i],
                                    "tempMax":      Math.round(daily.temperature_2m_max[i]) + units.temperature_2m_max,
                                    "tempMin":      Math.round(daily.temperature_2m_min[i]) + units.temperature_2m_min,
                                    "windSpeed":     daily.wind_speed_10m_max[i] + units.wind_speed_10m_max,
                                    "weatherCode":   daily.weather_code[i],
                                    "label":         weatherLabel(daily.weather_code[i], true), // Assume day for daily forecast
                                    "icon":          weatherIcon(daily.weather_code[i], true)
                                })
            // log each day :
            console.log("Added day to model: tempMax =", daily.temperature_2m_max[i], units.temperature_2m_max, "tempMin =", daily.temperature_2m_min[i], units.temperature_2m_min, "windSpeed =", daily.wind_speed_10m_max[i], units.wind_speed_10m_max)
        }
        console.log("Daily count:", dailyModelId.count)
    }

    // parse the "hourly" section of the API response
    function parseHourly(hourly, units) {
        console.log("Parsing hourly forecast")

        // only 24 -> 1 day forecast for hourly
        for (var i = 0; i < 24; i++) {
            hourlyModelId.append({
                                     "time":          getTime(hourly.time[i]),
                                     "temperature":   Math.round(hourly.temperature_2m[i]) + units.temperature_2m,
                                     "windSpeed":     hourly.wind_speed_10m[i] + units.wind_speed_10m,
                                     "weatherCode":   hourly.weather_code[i],
                                     "label":         weatherLabel(hourly.weather_code[i], hourly.is_day[i]),
                                     "icon":          weatherIcon(hourly.weather_code[i], hourly.is_day[i])
                                 })
        }
    }



    //==================  UI Components ==========================

    readonly property color clrBackground:  "#f0f4ff"
    readonly property color clrCard:        "#ffffff"
    readonly property color clrPrimary:     "#3a7bd5"
    readonly property color clrTextMain:    "#1a1a2e"
    readonly property color clrTextSub:     "#6b7280"
    readonly property color clrDivider:     "#e5e7eb"
    readonly property color clrAccent:      "#eff6ff"


    readonly property int fontSmall:  11
    readonly property int fontMid:    13
    readonly property int fontBody:   15
    readonly property int fontTitle:  18
    readonly property int fontBIG:   64

    Rectangle {
        anchors.fill: parent
        color: clrBackground
    }

    ///====================================================
    // ============= HEADER ===============================
    ///====================================================
    Rectangle {
        id: headerBar
        anchors {
            top:   parent.top
            left:  parent.left
            right: parent.right
        }
        height: 64
        color:  clrCard
        z: 10   // stays above scroll content

        // Divider at bottom of header
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: clrDivider
        }

        // Current time — left
        Text {
            id: timeText
            anchors {
                left:           parent.left
                leftMargin:     20
                verticalCenter: parent.verticalCenter
            }
            text:            Qt.formatTime(new Date(), "hh:mm AP")
            font.pixelSize:  fontMid
            font.weight:     Font.Medium
            color:           clrTextSub
        }

        // City name — center
        Text {
            anchors.centerIn: parent
            text:             cityName + ", Egypt"
            font.pixelSize:   fontTitle
            font.bold:        true
            color:            clrTextMain
        }

        // Refresh button — right
        Rectangle {
            anchors {
                right:          parent.right
                rightMargin:    16
                verticalCenter: parent.verticalCenter
            }
            width:  80
            height: 40
            radius: 18
            color:  refreshButton.containsMouse?  Qt.darker(clrAccent,1.2) : clrAccent

            Text {
                anchors.centerIn: parent
                text:             "Refresh"
                font.pixelSize:   14
                color:            "black"

                MouseArea {
                    id: refreshButton
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("Refresh clicked")
                        fetchWeather()
                    }
                }
            }

            // Timer to update clock every minute
            Timer {
                interval: 60000
                running:  true
                repeat:   true
                onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm AP")
            }
        }
    }
    ///====================================================
    // ============= MAIN SCROLLABLE CONTENT ==============
    ///====================================================
    ScrollView {
        anchors {
            top:    headerBar.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        contentWidth: parent.width
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // ─────────────────────────────────────
            // SECTION 1 — CURRENT WEATHER
            // ─────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 16
                Layout.topMargin: 48
                height: currentColumn.implicitHeight + 48
                color: clrCard
                radius: 24

                ColumnLayout {
                    id: currentColumn
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 4

                    // Weather Icon (emoji)
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: currentWeather ? currentWeather.icon : "—"
                        font.pixelSize: 72
                    }

                    // Big Temperature
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: currentWeather ? currentWeather.temperature  : "--°C"
                        font.pixelSize: fontBIG
                        font.weight: Font.Bold
                        color: clrTextMain
                    }

                    // Weather Label
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: currentWeather ? currentWeather.label : "Loading..."
                        font.pixelSize: fontBody
                        color: clrTextSub
                    }
                }
            }

            // ─────────────────────────────────────
            // SECTION 2 — 7-DAY FORECAST
            // ─────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 16
                color: clrCard
                radius: 24
                // Dynamic height based on actual content
                implicitHeight: forecastLayout.implicitHeight + 40

                ColumnLayout {
                    id: forecastLayout
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 20
                    }
                    spacing: 0

                    // Section Header
                    Text {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 12
                        text: "7-Day Forecast"
                        font.pixelSize: fontMid
                        color: clrTextSub
                        font.letterSpacing: 0.8
                    }

                    // Forecast Rows
                    Repeater {
                        model: dailyModelId

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                spacing: 12

                                // Day name
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    text: day
                                    font.pixelSize: fontBody
                                    font.weight: Font.Medium
                                    color: clrTextMain
                                }

                                // Weather icon
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    text: icon
                                    font.pixelSize: 24
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                // Weather description
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    text: label
                                    font.pixelSize: fontMid
                                    elide: Text.ElideRight
                                    color: clrTextSub
                                }

                                // Temperature
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    text: tempMin + " / " + tempMax
                                    font.pixelSize: fontBody
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignRight
                                    color: clrTextMain
                                }
                            }
                        }
                    }
                }
            }
            // ─────────────────────────────────────
            // SECTION 3 — HOURLY FORECAST
            // ─────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 16
                Layout.topMargin: 8
                height: hourlyColumn.implicitHeight + 24
                color: clrCard
                radius: 24

                ColumnLayout {
                    id: hourlyColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 20
                        topMargin: 16
                    }
                    spacing: 8

                    // Section header
                    Text {
                        text: "Hourly Forecast"
                        font.pixelSize: fontMid
                        color: clrTextSub
                        font.letterSpacing: 0.8
                    }

                    // Horizontal scroll
                    ListView {
                        id: hourlyListView
                        Layout.fillWidth: true
                        height: 110
                        orientation: ListView.Horizontal
                        spacing: 10
                        clip: true
                        model: hourlyModelId

                        delegate: Rectangle {
                            width: 70
                            height: 100
                            radius: 16
                            color: clrAccent

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                // Time
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: time
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }

                                // Icon
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: icon
                                    font.pixelSize: 24
                                }

                                // Temperature
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: temperature
                                    font.pixelSize: fontMid
                                    color: clrTextMain
                                }

                                // Wind speed
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: windSpeed
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }
                            }
                        }
                    }
                }
            }

            // ─────────────────────────────────────
            // SECTION 4 —  DETAILS
            // ─────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 16
                Layout.topMargin: 8
                Layout.bottomMargin: 24
                height: detailsColumn.implicitHeight + 24
                color: clrCard
                radius: 24

                ColumnLayout {
                    id: detailsColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 20
                        topMargin: 16
                    }
                    spacing: 12

                    // Section header
                    Text {
                        text: "Details"
                        font.pixelSize: fontMid
                        color: clrTextSub
                        font.letterSpacing: 0.8
                    }

                    // Grid:
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        // Apparent Temp
                        Rectangle {
                            Layout.fillWidth: true
                            height: detailItemCol1.implicitHeight + 24
                            radius: 16
                            color: clrAccent

                            ColumnLayout {
                                id: detailItemCol1
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "🌡️"
                                    font.pixelSize: 28
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: currentWeather ? currentWeather.apparentTemp: "--"
                                    font.pixelSize: fontBody
                                    color: clrTextMain
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Apparent Temperature"
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }
                            }
                        }

                        // Humidity
                        Rectangle {
                            Layout.fillWidth: true
                            height: detailItemCol2.implicitHeight + 24
                            radius: 16
                            color: clrAccent

                            ColumnLayout {
                                id: detailItemCol2
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "💧"
                                    font.pixelSize: 28
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: currentWeather ? currentWeather.humidity: "--"
                                    font.pixelSize: fontBody
                                    color: clrTextMain
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Humidity"
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }
                            }
                        }

                        // Pressure
                        Rectangle {
                            Layout.fillWidth: true
                            height: detailItemCol3.implicitHeight + 24
                            radius: 16
                            color: clrAccent

                            ColumnLayout {
                                id: detailItemCol3
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "🔵"
                                    font.pixelSize: 28
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: currentWeather ? currentWeather.pressure : "--"
                                    font.pixelSize: fontBody
                                    color: clrTextMain
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Pressure"
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }
                            }
                        }

                        // Wind Speed
                        Rectangle {
                            Layout.fillWidth: true
                            height: detailItemCol4.implicitHeight + 24
                            radius: 16
                            color: clrAccent

                            ColumnLayout {
                                id: detailItemCol4
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "💨"
                                    font.pixelSize: 28
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: currentWeather ? currentWeather.windSpeed : "--"
                                    font.pixelSize: fontBody
                                    color: clrTextMain
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Wind Speed"
                                    font.pixelSize: fontSmall
                                    color: clrTextSub
                                }
                            }
                        }
                    }
                }
            }

        }
    }



    // fetch on startup
    Component.onCompleted: {
        fetchWeather()
    }

}

