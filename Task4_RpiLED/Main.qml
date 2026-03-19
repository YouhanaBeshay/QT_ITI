import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Window {
    visible: true
    width: 600
    height: 350
    title: "GPIO LED Control"

    Rectangle{
        anchors.fill: parent
        anchors.margins: 10
        radius: 10

        border.color: "#aa272d"
        border.width: 2
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12


        Rectangle{
            Layout.fillWidth: true
            height: 50
            radius: 6
            color : "#203947"
            Text {
                text: "GPIO LED Control"
                color: "#f0f0f0"
                font.pixelSize: 24
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: 16
            spacing: 8
            model: ledModel

            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                color: "#f0f0f0"
                radius: 6
                // border.color: "#aa272d"


                RowLayout {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 10

                    // indicator dot
                    Rectangle {
                        width: 20; height: 20
                        radius: 10
                        color: modelData.ledOn ? "lightgreen" : "gray"
                        Layout.alignment: Qt.AlignVCenter

                    }

                    Text {
                        text: modelData.name
                        font.bold: true
                        Layout.preferredWidth: 70
                        Layout.alignment: Qt.AlignVCenter
                    }

                    //spacer
                    Item { Layout.fillWidth: true }

                    Button { Layout.alignment: Qt.AlignVCenter ; text: "On";     enabled: !modelData.ledOn; onClicked: modelData.turnOn()  }
                    Button { Layout.alignment: Qt.AlignVCenter ;  text: "Off";    enabled: modelData.ledOn;  onClicked: modelData.turnOff() }
                    Button { Layout.alignment: Qt.AlignVCenter ; text: "Toggle";                             onClicked: modelData.toggle()  }
                }
            }
        }
    }
    }
}
