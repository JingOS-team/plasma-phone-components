/*
Copyright (C) 2020 Devin Lin <espidev@gmail.com>
Copyright (C) 2021 Rui Wang <wangrui@jingos.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0

Item {
//    color: Qt.rgba(250, 250, 250, 0.85) // slightly translucent background, for key contrast
    property string pinLabel: qsTr("Enter PIN")
    
    // for displaying temporary number in pin dot display
    property string lastKeyPressValue: "0"
    property int indexWithNumber: -2
    focus: true

    // keypad functions
    function backspace() {
        lastKeyPressValue = "0";
        indexWithNumber = -2;
        root.password = root.password.substr(0, root.password.length - 1);
    }

    function clear() {
        lastKeyPressValue = "0";
        indexWithNumber = -2;
        root.password = "";
    }
    
    function enter() {
        authenticator.tryUnlock(root.password);
    }
    
    function keyPress(data) {
        if (keypad.pinLabel !== qsTr("Enter PIN")) {
            keypad.pinLabel = qsTr("Enter PIN");
        }
        lastKeyPressValue = data;
        indexWithNumber = root.password.length;
        root.password += data
        
        // trigger turning letter into dot later
        letterTimer.restart();
    }
    
    Connections {
        target: authenticator
        function onFailed() {
            root.password = null;
            pinLabel = qsTr("Wrong PIN")
        }
    }
    
    // listen for keyboard events
    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace) {
            backspace();
        } else if (event.key === Qt.Key_Return) {
            enter();
        } else if (event.text != "") {
            keyPress(event.text);
        }
    }
    
    // trigger turning letter into dot after 500 milliseconds
    Timer {
        id: letterTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            lastKeyPressValue = "0";
            indexWithNumber = -2;
        }
    }
    
    ColumnLayout {
        anchors.centerIn: parent

        spacing: units.gridUnit
        
        // pin dot display
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.minimumHeight: units.gridUnit * 0.5
            
            Label {
                // visible: root.password.length === 0
                anchors.centerIn: parent
                text: pinLabel
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#ffffff"
            }
        }

        RowLayout {
            id: dotDisplay
            Layout.alignment: Qt.AlignCenter

            Layout.minimumHeight: units.gridUnit * 2
            spacing: 6
                
            Repeater {
                model: root.password.length

                onCountChanged: {
                    if(count === 6)
                        enter();
                }

                delegate: Rectangle { // dot
                    visible: index !== indexWithNumber // hide dot if number is shown
                    Layout.preferredWidth: units.gridUnit * 0.4
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignVCenter
                    radius: width
                    color: "#ffffff"
                }
            }

            Label { // number/letter
                visible: root.password.length - 1 === indexWithNumber // hide label if no label needed
                Layout.alignment: Qt.AlignHCenter
                color: "#ffffff"
                text: lastKeyPressValue
                font.pointSize: theme.defaultFont.pointSize + 2
            }
        }

        GridLayout {
            id: numberGrid
            property string thePw
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.leftMargin: units.gridUnit * 18// 0.5
            Layout.rightMargin: units.gridUnit * 18//0.5
            Layout.topMargin: units.gridUnit * 1
            Layout.bottomMargin: units.gridUnit * 4//0.5

            Layout.preferredWidth: units.gridUnit * 12
            Layout.preferredHeight: units.gridUnit * 16

            columnSpacing: units.gridUnit * 1
            rowSpacing: units.gridUnit * 1

            columns: 3

            // numpad keys
            Repeater {
                model: ["1", "2", "3", "4", "5", "6","7", "8", "9","←","0","↵"]

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        id: keyRect
                        anchors.centerIn: parent
                        width: parent.width
                        height: width // parent.height
                        radius: height / 3
                        color: "#255255255"
                        visible: modelData.length > 0
                        opacity: modelData === "←" || modelData === "↵" ? 0 : 0.2

                        Behavior on color {
                            PropertyAnimation { duration: 500 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = "gray"
                            onReleased: parent.color = "#255255255"
                            onCanceled: parent.color = "#255255255"
                            onClicked: {
                                if (modelData === "←") {
                                    backspace();
                                } else if (modelData === "↵") {
                                    enter();
                                } else {
                                    keyPress(modelData);
                                }
                            }
                            onPressAndHold: {
                                if (modelData === "←") {
                                    clear();
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        visible: true
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: theme.defaultFont.pointSize + 10
                        color: "#ffffff"
                    }
                }
            }
        }
    }
}
