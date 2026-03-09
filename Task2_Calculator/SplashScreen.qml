import QtQuick
import QtQuick.Controls

Page {
    id: splashPage

    property int step: 0

    background: Rectangle {
        color: "#3a3a3a"
    }

    Rectangle{
        anchors.centerIn: parent

        height: parent.height *0.7
        width: parent.width * 0.8
        radius : 10
        border.color: "#E95420"
        border.width: 2
        color: "#303030"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Image {
                width: 150
                height: 150
                source: "qrc:/logo.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Calculator App"
                color: "white"
                font.pixelSize: 32
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter

            }

            ProgressBar {
                id: bar
                width: 260
                from: 0
                to: 100
                Behavior on value {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                }
                onValueChanged: {
                    if (value >= 100) {
                        splashPage.StackView.view.replace("CalcScreen.qml")
                    }
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: statusText
                text: "Starting..."
                color: "white"
                font.pixelSize: 15
                height: 20
                anchors.horizontalCenter: parent.horizontalCenter

            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true

        onTriggered: {

            step++

            switch(step) {

            case 1:
                statusText.text = "Entering from the garage..."
                bar.value = 20
                break

            case 2:
                statusText.text = "Asking security for 2028 key..."
                bar.value = 45
                break

            case 3:
                statusText.text = "Lighting Ramadan Decorations.."
                bar.value = 70
                break

            case 4:
                statusText.text = "Thanking Eng. joe for the online Week❤️❤️..."
                bar.value = 90
                break

            case 5:
                bar.value = 100
                statusText.text = "Done"
                stop()
                break
            }
        }
    }
}
