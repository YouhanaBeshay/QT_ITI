import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Page {
    id: aboutPage

    background: Rectangle {
        color: "white"
    }

    header: Rectangle {
        width: parent.width
        height: 80
        color: "white"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 20

            Rectangle {
                width: 120
                height: 50
                color: backMouse.pressed ? "#8a1f23" : "#aa272d"
                radius: 10
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("← Back")
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: aboutPage.StackView.view.pop()
                }

                scale: backMouse.containsMouse ? 1.05 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                text: qsTr("About")
                color: "#aa272d"
                font.bold: true
                font.pixelSize: 36
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 3
            color: "#aa272d"
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        width: parent.width * 0.8
        spacing: 20

        Rectangle {
            width: parent.width
            height: 150
            color: "#203947"
            radius: 15

            Column {
                width: parent.width
                leftPadding: 20
                spacing: 5

                Text {
                    width: parent.width
                    topPadding: 10
                    text: qsTr("About App")
                    color: "white"
                    font.pixelSize: 20
                }

                Text {
                    width: parent.width * 0.8
                    topPadding: 10
                    text: qsTr("This app is developed as a practice project for the Qt course at ITI.\nThe App shows an image gallery of ITI Embedded systems recruits & their information.")
                    color: "gray"
                    wrapMode: Text.Wrap
                    font.pixelSize: 16
                    font.bold: false
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
