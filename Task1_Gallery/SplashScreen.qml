import QtQuick
import QtQuick.Controls

Page {
    id: splashPage

    background: Rectangle {
        color: "white"
    }

    Column {
        anchors.centerIn: parent
        spacing: 20
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 2000
            running: true
        }

        Image {
            id: logoITI
            width: 100
            height: 150
            source: "qrc:/logo.png"
            anchors.horizontalCenter: parent.horizontalCenter  
        }

        Text {
            text: qsTr("Recurits Insights")
            color: "#aa272d"
            font.pixelSize: 32
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
            Text {
            text: qsTr("ES - Intake 46")
            color: "#203947"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: false
        onTriggered: {
            splashPage.StackView.view.replace("HomeScreen.qml");
        }
    }


    
}
