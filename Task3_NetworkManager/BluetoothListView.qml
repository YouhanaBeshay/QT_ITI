import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
Item {
    id: root

    Material.theme: Material.Light
    Material.primary: "#aa272d"
    Material.accent: "#203947"

    // ===== HELPER FUNCTION =====
    function getDeviceIcon(iconType) {
        switch(iconType) {
            case "audio-headphones":
            case "audio-headset": return "🎧"
            case "audio-card":
            case "audio-speakers": return "🔊"
            case "input-mouse": return "🖱️"
            case "input-keyboard": return "⌨️"
            case "phone": return "📱"
            case "computer": return "💻"
            default: return "📶"
        }
    }

    // ===== C++ SIGNAL HANDLERS =====
    Connections {
        target: bluetoothManager

        function onDeviceConnected(name) { console.log("Device connected:", name) }
        function onDeviceDisconnected(name) { console.log("Device disconnected:", name) }
        function onDevicePaired(name) { console.log("Device paired:", name) }

        function onErrorOccurred(message) {
            console.log("Bluetooth error:", message)
            errorLabel.text = message
            errorLabel.visible = true
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 5000
        onTriggered: errorLabel.visible = false
    }




    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18



        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Bluetooth Toggle"
                font.pixelSize: 30
                font.bold: true
                color: "#203947"
            }

            Item { Layout.fillWidth: true }

            Switch {
                Material.accent: "#aa272d"
                checked: bluetoothManager.bluetoothEnabled
                onToggled: bluetoothManager.bluetoothEnabled = checked
            }
        }

        // separtor
        Rectangle {
            Layout.fillWidth: true
            height: 3
            color: "#aa272d"
        }

        // ===== HEADER =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Bluetooth Devices"
                font.pixelSize: 30
                font.bold: true
                color: "#aa272d"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 120
                height: 40
                radius: 10
                color: refreshMouse.pressed ? "#8a1f23" : "#aa272d"
                enabled: bluetoothManager.bluetoothEnabled

                Text {
                    anchors.centerIn: parent
                    text:  "Refresh"
                    color: "white"
                    font.bold: true
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        bluetoothManager.refreshDevices()
                    }
                }
            }
        }




        // ===== DISCOVERING INDICATOR =====
        Rectangle {
            Layout.fillWidth: true
            height: 45
            radius: 10
            color: "#f5faff"
            border.color: "#aa272d"
            visible: bluetoothManager.isDiscovering

            RowLayout {
                anchors.centerIn: parent
                spacing: 10


                Text {
                    Layout.alignment: Qt.AlignVCenter

                    text: "Discovering devices..."
                    color: "#203947"
                }
                Item {
                    width: 20
                    height: 20
                BusyIndicator {
                    anchors.centerIn: parent
                    running: true
                    width: 30
                    height: 30
                }
                }
            }
        }

        // ===== ERROR LABEL =====
        Rectangle {
            id: errorLabel
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#ffebee"
            visible: false

            property alias text: errorText.text

            Text {
                id: errorText
                anchors.centerIn: parent
                color: "#c62828"
            }
        }

        // ===== SEPARATOR =====
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }

        // ===== DEVICE LIST =====
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true

            model: bluetoothManager.devices

            section.property: "paired"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                width: parent.width
                height: 35
                color: "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: section === "true" ? "Paired Devices" : "Available Devices"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#aa272d"
                }
            }

            delegate: Rectangle {
                width: parent.width
                height: 75
                radius: 15
                color: modelData.connected ? "#e8f5e9" : "white"
                border.color: modelData.connected ? "#aa272d" : "#e0e0e0"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // DEVICE ICON
                    Rectangle {
                        width: 45
                        height: 45
                        radius: 22
                        color: "#203947"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: getDeviceIcon(modelData.icon)
                            font.pixelSize: 20
                            color: "white"
                        }
                    }

                    // DEVICE INFO
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Layout.maximumWidth: 300
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: modelData.name
                            font.bold: true
                            font.pixelSize: 16
                            color: "#203947"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: {
                                if (modelData.connected) return "Connected"
                                if (modelData.paired) return "Paired"
                                return "Available"
                            }
                            font.pixelSize: 12
                            color: modelData.connected ? "#4caf50" :
                                   modelData.paired ? "#ff9800" : "#757575"
                        }
                    }

                    // FLEX SPACER
                    Item { Layout.fillWidth: true }

                    // BUTTONS
                    RowLayout {
                        Layout.preferredWidth: 220
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            visible: modelData.paired || modelData.connected
                            width: 100
                            height: 36
                            radius: 8
                            color: connectMouse.pressed ? "#8a1f23" : "#aa272d"

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (modelData.connected) return "Disconnect"
                                    if (bluetoothManager.isConnecting) return "Connecting..."
                                    return "Connect"
                                }
                                color: "white"
                                font.bold: true
                            }

                            MouseArea {
                                id: connectMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (modelData.connected)
                                        bluetoothManager.disconnectFromDevice(modelData.address)
                                    else
                                        bluetoothManager.connectToDevice(modelData.address)
                                }
                            }
                        }

                        Rectangle {
                            visible: !modelData.paired
                            width: 70
                            height: 36
                            radius: 8
                            color: "#203947"

                            Text {
                                anchors.centerIn: parent
                                text: "Pair"
                                color: "white"
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bluetoothManager.pairDevice(modelData.address)
                            }
                        }

                        Rectangle {
                            visible: modelData.paired && !modelData.connected
                            width: 36
                            height: 36
                            radius: 8
                            color: "#eeeeee"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bluetoothManager.removeDevice(modelData.address)
                            }
                        }
                    }
                }
            }

            // EMPTY STATE
            Text {
                anchors.centerIn: parent
                text: bluetoothManager.bluetoothEnabled ?
                      "No devices found. Try scanning." :
                      "Bluetooth is disabled"
                color: "#757575"
                visible: bluetoothManager.devices.length === 0
            }
        }
    }

    Component.onCompleted: {
        console.log("BluetoothListView loaded")
    }
}
