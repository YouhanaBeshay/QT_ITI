import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Window {
    id: calcWindow
    width: 450
    height: 600
    visible: true
    title: qsTr("Calculator")

    StackView {
        id: stackView

        anchors.fill: parent
        initialItem: "SplashScreen.qml"

        replaceEnter: Transition {
            PropertyAction {
                property: "opacity"
                value: 0
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        replaceExit: Transition {
            PropertyAction {
                property: "opacity"
                value: 1
            }
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }
    }

}
