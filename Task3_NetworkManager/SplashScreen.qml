import QtQuick
import QtQuick.Controls

Page {
    id: splashPage

    background: Rectangle {
       color: "white"
    }

    Rectangle {
        anchors.centerIn: parent
        color: "#f7f9fb"
        border.color: "#e0e0e0"
        border.width: 1
        width: parent.width * 0.6
        height: contentColumn.height +40

        radius: 40
    Column {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter

        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 1200
            running: true
        }

        Image {
            id: logo
            width: 150
            height: 150
            source: "qrc:/icons/status.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: qsTr("NetLens")
            color: "#aa272d"
            font.pixelSize: 32
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: qsTr("WiFi/Bluetooth Manager")
            color: "#203947"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //footer
        Rectangle {
            id: footerRect
            width: splashPage.width
            height: 50
            color: "transparent"

            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: qsTr("© Youhana Beshay - Intake 46")
                color: "gray"
                font.pixelSize: 12
            }
        }
    }
    }
    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: {
            splashPage.StackView.view.replace("HomeScreen.qml");
        }
    }



}
