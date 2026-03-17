import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root
    Material.theme: Material.Light
    Material.primary: "#aa272d"
    Material.accent: "#203947"

    // ===== C++ SIGNAL HANDLERS =====
    Connections {
        target: wifiManager

        function onConnectionSuccess(ssid) {
            console.log("Connected to:", ssid)
        }

        function onConnectionFailed(message) {
            errorLabel.text = message
            errorLabel.visible = true
            errorTimer.restart()
        }

        function onDisconnected() {}

        function onErrorOccurred(message) {
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

    // ===== PASSWORD POPUP =====
    Popup {
        id: passwordDialog
        anchors.centerIn: parent
        width: 350
        height: popupColumn.implicitHeight + 50
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string networkSsid: ""

        background: Rectangle {
            color: "white"
            radius: 15
            border.color: "#aa272d"
            border.width: 3
        }

        Column {
            id: popupColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15


            Text {
                text: "Connect to Network"
                color: "#aa272d"
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                text: passwordDialog.networkSsid
                font.pixelSize: 16
                font.bold: true
                color: "#203947"
            }

            Rectangle {
                width: parent.width
                height: 60
                radius: 8
                color: "#f5f5f5"
                border.color: "#aa272d"
                border.width: 2

                TextField {
                    Material.accent: "#aa272d"

                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 8
                    background: null
                    color: "#000000"
                    placeholderText: "Enter password"
                    echoMode: showPasswordCheckbox.checked
                              ? TextInput.Normal
                              : TextInput.Password
                }
            }

            CheckBox {
                id: showPasswordCheckbox
                Material.accent: "#aa272d"
                text: "Show password"
            }

            Row {
                spacing: 10
                anchors.right: parent.right

                // Cancel
                Rectangle {
                    width: 90
                    height: 40
                    radius: 10
                    color: cancelMouse.pressed ? "#203947" : "#607d8b"

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "white"
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passwordField.text = ""
                            passwordDialog.close()
                        }
                    }
                }

                // Connect
                Rectangle {
                    width: 90
                    height: 40
                    radius: 10
                    color: connectMouse.pressed ? "#8a1f23" : "#aa272d"

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: "white"
                        font.bold: true
                    }

                    MouseArea {
                        id: connectMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiManager.connectToNetwork(
                                passwordDialog.networkSsid,
                                passwordField.text
                            )
                            passwordField.text = ""
                            passwordDialog.close()
                        }
                    }
                }
            }
        }
    }

    // ===== MAIN LAYOUT =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        // WIFI TOGGLE
        RowLayout {

            Layout.fillWidth: true

            Text {
                text: "WiFi Toggle"
                font.pixelSize: 30
                color: "#203947"
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Switch {
                Material.accent: "#aa272d"
                checked: wifiManager.wifiEnabled
                onToggled: wifiManager.wifiEnabled = checked
            }
        }

        // separtor
        Rectangle {
            Layout.fillWidth: true
            height: 3
            color: "#aa272d"
        }

        // Devices
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "WiFi Networks"
                font.pixelSize: 30
                font.bold: true
                color: "#aa272d"
            }

            Item { Layout.fillWidth: true }



            Rectangle {
                width: 110
                height: 40
                radius: 10
                color: scanMouse.pressed ? "#8a1f23" : "#aa272d"

                Text {
                    anchors.centerIn: parent
                    text: wifiManager.isScanning ? "Scanning..." : "Scan"
                    color: "white"
                    font.bold: true
                }

                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: wifiManager.wifiEnabled && !wifiManager.isScanning
                    onClicked: wifiManager.scanNetworks()
                }
            }
        }


        // Error banner
        Rectangle {
            id: errorLabel
            Layout.fillWidth: true
            height: 45
            radius: 10
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
        // NETWORK LIST
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true

            model: wifiManager.networks

            delegate: Rectangle {
                width: parent.width
                height: 70
                radius: 15
                color: modelData.connected ? "#e8f5e9" : "white"
                border.color: modelData.connected ? "#aa272d" : "#e0e0e0"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // WIFI ICON
                    Rectangle {
                        width: 45
                        height: 45
                        radius: 22
                        color: "#203947"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🛜"
                            font.pixelSize: 20
                            color: "white"
                        }
                    }

                    // NETWORK INFO
                    ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter
                        Layout.maximumWidth: 260   // prevents pushing button
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 5

                            Text {
                                text: modelData.ssid
                                font.bold: true
                                font.pixelSize: 16
                                color: "#203947"

                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.secured ? "🔒" : ""
                            }
                        }

                        Text {
                            text: {
                                var state = ""
                                if (modelData.connected)
                                    state = "Connected"
                                else if (modelData.secured)
                                    state = "Secured"
                                else
                                    state = "Open"

                                return state + " • " + modelData.strength + "%"
                            }

                            font.pixelSize: 12

                            color: {
                                if (modelData.strength > 70) return "#4caf50"
                                if (modelData.strength > 40) return "#ff9800"
                                return "#f44336"
                            }
                        }
                    }

                    // FLEX SPACER
                    Item {
                        Layout.fillWidth: true
                    }

                    // BUTTON (fixed position)
                    Rectangle {
                        width: 100
                        height: 40
                        radius: 10
                        Layout.alignment: Qt.AlignVCenter
                        color: modelData.connected ? "#203947": (connectBtnMouse.pressed ? "#8a1f23" : "#aa272d")

                        Text {
                            anchors.centerIn: parent
                            text: modelData.connected ? "Disconnect" : "Connect"
                            color: "white"
                            font.bold: true
                        }

                        MouseArea {
                            id: connectBtnMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (modelData.connected) {
                                    wifiManager.disconnectFromNetwork()
                                } else if (modelData.secured) {
                                    passwordDialog.networkSsid = modelData.ssid
                                    passwordDialog.open()
                                } else {
                                    wifiManager.connectToNetwork(modelData.ssid, "")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (wifiManager.wifiEnabled)
            wifiManager.scanNetworks()
    }
}
