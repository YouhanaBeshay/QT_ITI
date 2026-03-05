import QtQuick
import QtQuick.Controls
import QtMultimedia

Page {
    id: galleryPage
    property bool isMuted: false

    background: Rectangle {
        color: "white"
    }

    StackView.onActivated: {
        mainWindow.bgMusic.play()
    }

    StackView.onDeactivating: {
        mainWindow.bgMusic.stop()
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
                    onClicked: galleryPage.StackView.view.pop()
                }

                scale: backMouse.containsMouse ? 1.05 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                text: qsTr("Gallery")
                color: "#aa272d"
                font.bold: true
                font.pixelSize: 36
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //Mute buttonn
        Rectangle {
            width: 50
            height: 50
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color:  "#aa272d"
            radius: 15

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: galleryPage.isMuted ? "🔇" : "🔊"
                font.pixelSize: 24
            }

            MouseArea {
                id: muteMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    galleryPage.isMuted = !galleryPage.isMuted
                    mainWindow.bgMusic.audioOutput.muted = galleryPage.isMuted
                }
            }

            scale: muteMouse.containsMouse ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 3
            color: "#aa272d"
        }
    }
    // Photos Data
    ListModel {
        id: photosModel

        ListElement {
            photoName: "Recruit #1"
            photoDescription: "-Name: Youhana Beshay\n\n-Republic: October republic (Refugee).\n\n-Notes: Struggles to differentiate between left & right.  "
            photoUrl: "qrc:/recruits_imgs/youhana.jpeg"
        }
        ListElement {
            photoName: "Recruit #2"
            photoDescription: "-Name: Abdelfatah Moawed\n\n-Republic: Helwan republic.\n\n-Notes: 🔥ولع . "
            photoUrl: "qrc:/recruits_imgs/abdelfatah.jpeg"
        }
        ListElement {
            photoName: "Recruit #3"
            photoDescription: "-Name: Mohamed Gamal\n\n-Republic: Helwan republic.\n\n-Notes: Tends to access NULL. "
            photoUrl: "qrc:/recruits_imgs/gemy.webp"
        }
        ListElement {
            photoName: "Recruit #4"
            photoDescription: "-Name: Youssef El Kashef \n\n-Republic: October republic.\n\n-Notes: Snitch*.\n\n-Quote: \"unconventional problems require conventional solutions\""
            photoUrl: "qrc:/recruits_imgs/joe.jpeg"
        }
        ListElement {
            photoName: "Recruit #5"
            photoDescription: "-Name: Mostafa Mahgoub\n\n-Republic: Nasr-City republic.\n\n-Notes: Best Leader. (also only leader)."
            photoUrl: "qrc:/recruits_imgs/mahgoub.webp"
        }
        ListElement {
            photoName: "Recruit #6"
            photoDescription: "-Name: Ahmed Aboelyazeed\n\n-Republic: October republic.\n\n-Notes: 1st person on earth to like MATLAB."
            photoUrl: "qrc:/recruits_imgs/aboelyazeed.webp"
        }

        ListElement {
            photoName: "Recruit #7"
            photoDescription: "-Name: Mostafa Hesham\n\n-Republic: Nasr-City republic (Co-Founder).\n\n-Notes: Actively looking for 16Gb DDR5 Ram."
            photoUrl: "qrc:/recruits_imgs/mostafa_H.jpeg"

        }
        ListElement {
            photoName: "Recruit #8"
            photoDescription: "-Name: Ayman Abohamed\n\n-Republic: Nasr-City republic.\n\n-Notes: Founder of ITI-ES Cafeteria."
            photoUrl: "qrc:/recruits_imgs/ayman.jpeg"
        }
        ListElement {
            photoName: "Recruit #9"
            photoDescription: "-Name: Ehab Magdy\n\n-Republic: October republic (Founder).\n\n-Notes: Publicly Racist."
            photoUrl: "qrc:/recruits_imgs/ehab.jpeg"
        }
    }

    // POP UP
    Popup {
        id: detailPopup
        anchors.centerIn: parent
        width: 500
        height: 550
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Properties to hold selected photo data
        property string selectedName: ""
        property string selectedDescription: ""
        property string selectedUrl: ""

        background: Rectangle {
            color: "white"
            radius: 15
            border.color: "#aa272d"
            border.width: 3
        }

        Column {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Row {
                width: parent.width
                height: 40

                Text {
                    text: detailPopup.selectedName
                    color: "#aa272d"
                    font.bold: true
                    font.pixelSize: 28
                    width: parent.width - 50
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: closeMouse.containsMouse ? "#aa272d" : "#203947"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: detailPopup.close()
                    }
                }
            }

            // Image preview
            Rectangle {
                width: parent.width
                height: 200
                color: "#203947"
                radius: 15
                clip : true

                Image {
                    anchors.fill: parent

                    source: detailPopup.selectedUrl
                    fillMode: Image.PreserveAspectFit

                    // Placeholder
                    Text {
                        anchors.centerIn: parent
                        text: "🫡"
                        font.pixelSize: 64
                        color: "white"
                        visible: parent.status !== Image.Ready
                    }
                }
            }


            Column {
                width: parent.width
                spacing: 12
                // info card
                Rectangle {
                    width: parent.width
                    height: descriptionText.implicitHeight + 50
                    color: "#f5f5f5"
                    radius: 10

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8

                        Text {
                            text: "📝 Information:"
                            color: "gray"
                            font.pixelSize: 12
                        }

                        Text {
                            id: descriptionText
                            text: detailPopup.selectedDescription
                            color: "#203947"
                            font.pixelSize: 15
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }
        }
    }

    // actual LIST
    ListView {
        id: photosList
        anchors.fill: parent
        anchors.bottomMargin: 50
        anchors.margins: 20
        spacing: 20
        clip: true

        model: photosModel

   // DELEGATE 
        delegate: Item {
            width: photosList.width
            height: 220

            Rectangle {
                width: 200
                height: 200
                anchors.centerIn: parent
                color: "#203947"
                radius: 15
                clip: true

                scale: photoMouse.containsMouse ? 1.02 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Image {
                    anchors.fill: parent
                    source: model.photoUrl
                    fillMode: Image.PreserveAspectFit

                    Rectangle {
                        anchors.fill: parent
                        color: "#203947"
                        visible: parent.status !== Image.Ready
                        radius: 15
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            text: "🫡"
                            font.pixelSize: 64
                            color: "white"
                        }
                    }
                }

                // Hover overlay
                Rectangle {
                    anchors.fill: parent
                    color: "#aa272d"
                    opacity: photoMouse.containsMouse ? 0.85 : 0
                    radius: 15
                    clip: true

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: model.photoName
                            color: "white"
                            font.pixelSize: 28
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Click for Information"
                            color: "white"
                            font.pixelSize: 16
                            opacity: 0.9
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Mouse interaction
                MouseArea {
                    id: photoMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        detailPopup.selectedName = model.photoName
                        detailPopup.selectedDescription = model.photoDescription
                        detailPopup.selectedUrl = model.photoUrl
                        detailPopup.open()
                    }
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
