import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Window {
    id: mainWindow
    width: 640
    height: 700
    visible: true
    title: qsTr("MultiMedia Player")

    StackView {
        id: stackView

        anchors.fill: parent
        initialItem: "homePage.qml"

    }
}
