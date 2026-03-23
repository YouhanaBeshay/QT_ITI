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

        // replaceEnter: Transition {
        //     PropertyAction {
        //         property: "opacity"
        //         value: 0
        //     }
        //     NumberAnimation {
        //         property: "opacity"
        //         from: 0.0
        //         to: 1.0
        //         duration: 1000
        //         easing.type: Easing.InOutQuad
        //     }
        // }

        // replaceExit: Transition {
        //     PropertyAction {
        //         property: "opacity"
        //         value: 1
        //     }
        //     NumberAnimation {
        //         property: "opacity"
        //         from: 1.0
        //         to: 0.0
        //         duration: 800
        //         easing.type: Easing.InOutQuad
        //     }
        // }
    }
}
