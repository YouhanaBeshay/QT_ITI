import QtQuick
import QtQuick.Controls
import QtMultimedia

Window {
    id: mainWindow
    visible: true
    width: 600
    height: 800
    title: "Recruits Insights"

    property alias bgMusic: globalBgMusic

    MediaPlayer {
        id: globalBgMusic
        source: "qrc:/bg_mp3/EG_comp.mp3"
        audioOutput: AudioOutput {
            id: globalAudioOut
            volume: 0.4
        }
        loops: MediaPlayer.Infinite
    }
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
