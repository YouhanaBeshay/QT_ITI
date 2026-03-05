import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Page {
    id: homePage

    background: Rectangle {
        color: "white"
    }

    Column {
        anchors.centerIn: parent
        spacing: 40

        Column {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: qsTr("Recruits Insights")
                color: "#aa272d"
                font.bold: true
                font.pixelSize: 48
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // a line to underline the title
            Rectangle {
                width: 100
                height: 3
                color: "#aa272d"
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 2
            }
        }

        Row {
            id: infoRow
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: dateRect
                width: 140
                height: 120
                color: "#203947"
                radius: 15

                Column {

                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: Qt.formatDate(new Date(), "dd/MM/yyyy")
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Date"
                        color: "gray"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                id: timeRect
                width: 140
                height: 120
                color: "#203947"
                radius: 15
                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        id: timeText
                        text: Qt.formatTime(new Date(), "hh:mm:ss")
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: {
                                timeText.text = Qt.formatTime(new Date(), "hh:mm:ss");
                            }
                        }
                    }

                    Text {
                        text: qsTr("Time")
                        color: "gray"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                id: tempRect
                width: 140
                height: 120
                color: "#203947"
                radius: 15

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "25°C"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: qsTr("Temperature")
                        color: "gray"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: 200
                height: 55
                color: aboutMouse.pressed ? "#8a1f23" : "#aa272d"
                radius: 10

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("🛈 About")
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    id: aboutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: homePage.StackView.view.push("AboutScreen.qml")
                }

                scale: aboutMouse.containsMouse ? 1.05 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            Rectangle {
                width: 200
                height: 55
                color: galleryMouse.pressed ? "#8a1f23" : "#aa272d"
                radius: 10

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("→ Gallery")
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    id: galleryMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: homePage.StackView.view.push("GalleryScreen.qml")
                }

                scale: galleryMouse.containsMouse ? 1.05 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    //footer
    Rectangle {
        id: footerRect
        width: parent.width
        height: 50
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            anchors.centerIn: parent
            text: qsTr("© Youhana Beshay - Intake 46")
            color: "gray"
            font.pixelSize: 12
        }
    }
}
