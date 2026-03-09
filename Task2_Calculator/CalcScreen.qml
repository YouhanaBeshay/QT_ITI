import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Page {
    id: calcWindow
    visible: true


    // background color
    Rectangle {
        color: "#3a3a3a"
        z: -1
        anchors.fill: parent
    }

    // Button data model
    ListModel {
        id: buttonModel

        // Row 1: Clear, delete, ()
        ListElement { text: "AC"; color: "#aa272d"; textColor: "white"; action: "clear" }
        ListElement { text: "⌫"; color: "#aa272d"; textColor: "white"; action: "delete" }
        ListElement { text: "("; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: ")"; color: "#505050"; textColor: "white"; action: "number" }

        // Row 2: 7, 8, 9, +
        ListElement { text: "7"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "8"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "9"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "÷"; color: "#E95420"; textColor: "white"; action: "number" }

        // Row 3: 4, 5, 6, ×
        ListElement { text: "4"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "5"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "6"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "×"; color: "#E95420"; textColor: "white"; action: "number" }

        // Row 4: 1, 2, 3, −
        ListElement { text: "1"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "2"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "3"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "−"; color: "#E95420"; textColor: "white"; action: "number" }

        // Row 5: 0, ., +, =
        ListElement { text: "0"; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "."; color: "#505050"; textColor: "white"; action: "number" }
        ListElement { text: "+"; color: "#E95420"; textColor: "white"; action: "number" }
        ListElement { text: "="; color: "green"; textColor: "white"; action: "equals" }
    }



    ColumnLayout {
        height: parent.height
        spacing: 10
        anchors.fill: parent
        anchors.margins: 20
        Rectangle {
            id: displayId
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.3

            Layout.alignment: Qt.AlignTop
            radius: 5
            border.color: "black"
            border.width: 1
            color: "#cfe3e2"

            clip: true

            ColumnLayout {
                id: displayLayoutID
                anchors.fill: parent
                anchors.margins: 15
                spacing: 5
                Row{
                    spacing: 0
                    Text {
                        id: inputTextId
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        text: qsTr("")
                        wrapMode: Text.Wrap
                        font.pixelSize: displayLayoutID.height * 0.15
                        color: "#666666"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        id: cursorId
                        text: "|"
                        font.pixelSize: inputTextId.font.pixelSize
                        color: "#666666"
                        visible: true
                    }

                }

                Item { Layout.fillHeight: true } // space between the 2 texts

                Text {
                    id: outputTextId
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("")
                    font.pixelSize: parent.height * 0.28
                    font.bold: true
                    color: "black"
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight  // any overflow will be "...."
                }
            }
        }

        // Button grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: buttonModel

                delegate:  Button {
                    id: buttonId
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.columnSpan: 1

                    // all butoons same size
                    Layout.preferredWidth: 0
                    Layout.preferredHeight: 0

                    hoverEnabled: true
                    scale: hovered ? 1.02 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(model.color, 1.2) : model.color
                        radius: 8
                    }

                    contentItem: Text {
                        text: model.text
                        font.pixelSize: calcWindow.height * 0.035
                        font.bold: true
                        color: model.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (model.action === "number") {
                            calcWindow.numberClicked(model.text)
                        }
                        else if (model.action === "clear") {
                            calcWindow.clearAllClicked()
                        }
                        else if (model.action === "delete") {
                            calcWindow.deleteClicked()
                        }
                        else if (model.action === "equals") {
                            calcWindow.equalsClicked()
                        }


                    }
                }
            }
        }
    }


    Timer{
        running: true
        interval: 600
        onTriggered: {
            cursorId.visible = !cursorId.visible
        }
        repeat: true
    }



    // signals
    signal numberClicked (string number)
    onNumberClicked: {
        inputTextId.text += number
    }

    signal clearAllClicked()
    onClearAllClicked: {
        inputTextId.text = ""
        outputTextId.text = ""
    }

    signal deleteClicked()
    onDeleteClicked: {
        inputTextId.text = inputTextId.text.slice(0, -1)
        outputTextId.text = ""
    }

    signal equalsClicked()

    function calculateExpression(expr) {
        try {
            var expression = expr
            .replace(/×/g, "*")
            .replace(/÷/g, "/")
            .replace(/−/g, "-")
            // javascript regex syntax is not fun :(
            .replace(/(\d)\(/g, "$1*(")
            .replace(/\)\(/g, ")*(")
            return eval(expression).toString()
        } catch(e) {
            return "Syntax Error"
        }
    }

    onEqualsClicked: {
        var x  = calculateExpression(inputTextId.text)
        if (x === "Infinity" || x === "-Infinity" || x === "NaN") {
            outputTextId.text = "Math Error"
        }
        else
        outputTextId.text = x

    }
}
