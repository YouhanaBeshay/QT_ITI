import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: homePageId

    Material.theme: Material.Light
    Material.primary: "#aa272d"
    Material.accent: "#203947"

    // ==================== HOME SCREEN ====================
    ColumnLayout {
        id: homeScreen
        anchors.fill: parent
        anchors.margins: 30

        spacing: 20
        visible: true

        // Title
        Text {
            text: qsTr("MultiMedia Player")
            color: Material.primary
            font.bold: true
            font.pixelSize: 48
            Layout.alignment: Qt.AlignHCenter
        }

        // Underline
        Rectangle {
            width: 200
            height: 3
            color: Material.primary
            Layout.alignment: Qt.AlignHCenter
            radius: 2
        }

        // Date and Time Row
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                width: 140
                height: 100
                color: Material.accent
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
                        color: "#aaaaaa"
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: 140
                height: 100
                color: Material.accent
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
                            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm:ss")
                        }
                    }

                    Text {
                        text: "Time"
                        color: "#aaaaaa"
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Instruction
        Text {
            text: "Swipe or click to select"
            color: Material.accent
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }

        // ==================== PATH VIEW SECTION ====================
        Rectangle {
            id: pathViewSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: Material.accent
            border.width: 2
            radius: 15
            clip: true

            ListModel {
                id: menuModel

                ListElement {
                    name: "Radio"
                    iconText: "📻"
                    pageSource: "radioPage.qml"
                }
                ListElement {
                    name: "Audio"
                    iconText: "🎵"
                    pageSource: "audioPage.qml"
                }
                ListElement {
                    name: "Video"
                    iconText: "🎬"
                    pageSource: "videoPage.qml"
                }
            }

            Component {
                id: menuDelegate

                Column {
                    id: wrapper

                    required property int index
                    required property string name
                    required property string iconText
                    required property string pageSource

                    opacity: PathView.isCurrentItem ? 1.0 : 0.4
                    scale: PathView.isCurrentItem ? 1.0 : 0.7


                    Behavior on opacity {
                        NumberAnimation { duration: 300 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 300 }
                    }

                    Rectangle {
                        id: cardRect
                        width: pathViewSection.width * 0.2
                        height: pathViewSection.height * 0.4
                        radius: 15
                        color: wrapper.PathView.isCurrentItem ? Material.primary : Material.accent
                        anchors.horizontalCenter: parent.horizontalCenter


                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                text: wrapper.iconText
                                font.pixelSize: 50
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: wrapper.name
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (wrapper.PathView.isCurrentItem) {
                                    homePageId.StackView.view.push(menuModel.get(menuPathView.currentIndex).pageSource)

                                } else {
                                    menuPathView.currentIndex = wrapper.index
                                }
                            }
                        }
                    }
                }
            }

            // Credit for this effect : Qt docs for path view (https://doc.qt.io/qt-6/qml-qtquick-pathview.html)
            PathView {
                id: menuPathView
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: pageDots.top
                anchors.margins: 20
                model: menuModel
                delegate: menuDelegate

                preferredHighlightBegin: 0.0
                preferredHighlightEnd: 0.0
                highlightRangeMode: PathView.StrictlyEnforceRange

                path: Path {
                    // Bottom center - where current item appears
                    startX: menuPathView.width / 2
                    startY: menuPathView.height - 90

                    // Go up and right to top
                    PathQuad {
                        x: menuPathView.width / 2
                        y: 90
                        controlX: menuPathView.width - 60
                        controlY: menuPathView.height / 2
                    }

                    // Go down and left back to start
                    PathQuad {
                        x: menuPathView.width / 2
                        y: menuPathView.height - 90
                        controlX: 60
                        controlY: menuPathView.height / 2
                    }
                }
            }

            // Page dots
            Row {
                id : pageDots
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10
                spacing: 8
                z: 10

                Repeater {
                    model: menuModel.count

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: menuPathView.currentIndex === index ? Material.primary : "#cccccc"

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: menuPathView.currentIndex = index
                        }
                    }
                }
            }
        }

        // Open button
        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            Layout.preferredHeight: 50
            text: "Open " + menuModel.get(menuPathView.currentIndex).name
            Material.background: Material.primary
            Material.foreground: "white"
            font.pixelSize: 16

            onClicked: {
                homePageId.StackView.view.push(menuModel.get(menuPathView.currentIndex).pageSource)

            }
        }
    }


}
