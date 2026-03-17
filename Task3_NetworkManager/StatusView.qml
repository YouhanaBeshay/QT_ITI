import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    function getConnectedBluetoothDevice() {
        for (var i = 0; i < bluetoothManager.devices.length; i++) {
            if (bluetoothManager.devices[i].connected) {
                return bluetoothManager.devices[i].name
            }
        }
        return ""
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text {
            text: "Connection Status"
            font.pixelSize: 30
            font.bold: true
            color: "#aa272d"
        }

        // WIFI CARD
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.height *0.3
            radius: 15
            color: "white"
            border.color: "#aa272d"
            border.width: 2


            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // ICON
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: "#203947"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "🛜"
                        font.pixelSize: 24
                        color: "white"
                    }
                }

                // TEXT AREA
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.maximumWidth: 300
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "WiFi"
                        font.pixelSize: 14
                        color: "gray"
                    }

                    Text {
                        text: {
                            if (!wifiManager.wifiEnabled) return "Disabled"
                            if (wifiManager.connectedNetwork === "") return "Not Connected"
                            return wifiManager.connectedNetwork
                        }

                        font.pixelSize: 18
                        font.bold: true
                        color: "#203947"

                        elide: Text.ElideRight
                    }
                }


                // STATUS DOT
                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    Layout.alignment: Qt.AlignVCenter

                    color: {
                        if (!wifiManager.wifiEnabled) return "#9e9e9e"
                        if (wifiManager.connectedNetwork === "") return "#ff9800"
                        return "#4caf50"
                    }
                }
            }
        }

        // BLUETOOTH CARD
        Rectangle {
            Layout.fillWidth: true
            // Layout.fillHeight: true
            Layout.preferredHeight: root.height *0.3
            radius: 15
            color: "white"
            border.color: "#aa272d"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // ICON
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: "#203947"
                    Layout.alignment: Qt.AlignVCenter


                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/Bluetooth.svg.png"
                        width: 40
                        height: 40
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true

                    }
                }

                // TEXT AREA
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.maximumWidth: 300
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "Bluetooth"
                        font.pixelSize: 14
                        color: "gray"
                    }

                    Text {
                        text: {
                            if (!bluetoothManager.bluetoothEnabled) return "Disabled"
                            var connected = getConnectedBluetoothDevice()
                            if (connected === "") return "Not Connected"
                            return connected
                        }

                        font.pixelSize: 18
                        font.bold: true
                        color: "#203947"

                        elide: Text.ElideRight
                    }
                }


                // STATUS DOT
                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    Layout.alignment: Qt.AlignVCenter

                    color: {
                        if (!bluetoothManager.bluetoothEnabled) return "#9e9e9e"
                        if (getConnectedBluetoothDevice() === "") return "#ff9800"
                        return "#4caf50"
                    }
                }
            }
        }

    }
}
