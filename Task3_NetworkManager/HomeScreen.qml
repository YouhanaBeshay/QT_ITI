import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: homePage
    background: Rectangle { color: "white" }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TAB BAR
        TabBar {
            id: tabBar
            padding: 0
            Layout.fillWidth: true
            Layout.preferredHeight: homePage.height * 0.07

            background: Rectangle { color: "#203947" }

            TabButton {
                text: "Status"
                hoverEnabled: true
                implicitHeight: tabBar.height
                implicitWidth: tabBar.width / 3

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#aa272d" : "white"
                    font.bold: parent.checked
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.checked ? "white"
                          : parent.hovered ? "#2c5568"
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        // anchors.topMargin: 12
                        // anchors.bottomMargin: 12
                        width: 1
                        color: "#ffffff"
                        opacity: 0.25
                    }
                }
            }

            TabButton {
                text: "WiFi"
                hoverEnabled: true
                implicitHeight: tabBar.height
                implicitWidth: tabBar.width / 3

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#aa272d" : "white"
                    font.bold: parent.checked
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.checked ? "white"
                          : parent.hovered ? "#2c5568"
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: "#ffffff"
                        opacity: 0.25
                    }
                }
            }

            TabButton {
                text: "Bluetooth"
                hoverEnabled: true
                implicitHeight: tabBar.height
                implicitWidth: tabBar.width / 3

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#aa272d" : "white"
                    font.bold: parent.checked
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.checked ? "white"
                          : parent.hovered ? "#2c5568"
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }


        }
        // separtor
        Rectangle {
            Layout.fillWidth: true
            height: 3
            color: "#aa272d"
        }

        // CONTENT
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            StatusView { }
            WiFiListView { }
            BluetoothListView { }
        }
    }
}
