/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *   Copyright 2021 Bangguo Liu <liubangguo@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import MeeGo.QOfono 0.2
import org.kde.kirigami 2.15 as Kirigami
import "../components"
import jingos.display 1.0

PlasmaCore.ColorScope {
    id: root

    anchors.fill: parent
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    visible: simManager.pinRequired != OfonoSimManager.NoPin
    property OfonoSimManager simManager: ofonoSimManager
    property alias edit_input: pinLabel


    function addNumber(number) {
        edit_input.text = edit_input.text + number
    }

    Component.onCompleted: {
        //edit_input.forceActiveFocus()
    }
    Rectangle {
        id: pinScreen
        anchors.fill: parent
        

        color: "white"

        OfonoManager {
            id: ofonoManager
            onAvailableChanged: {
            console.log("Ofono is " + available)
            }
            onModemAdded: {
                console.log("modem added " + modem)
            }
            onModemRemoved: console.log("modem removed")
        }

        OfonoConnMan {
            id: ofono1
            Component.onCompleted: {
                console.log(ofonoManager.modems)
            }
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
        }

        OfonoModem {
            id: modem1
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""

        }

        OfonoContextConnection {
            id: context1
            contextPath : ofono1.contexts.length > 0 ? ofono1.contexts[0] : ""
            Component.onCompleted: {
                print("Context Active: " + context1.active)
            }
            onActiveChanged: {
                print("Context Active: " + context1.active)
            }
        }

        OfonoSimManager {
            id: ofonoSimManager
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
        }

        OfonoNetworkOperator {
            id: netop
        }

        MouseArea {
            anchors.fill: parent
        }

        Connections {
            target: simManager
            onEnterPinComplete: {
                print("Enter Pin complete: " + error + " " + errorString)
            }
        }

        Item {
            id: dialPadArea

            anchors {
                fill: parent
                margins: JDisplay.dp(55)
            }


            Controls.Label {
                id:enter_pin
                anchors.horizontalCenter: parent.horizontalCenter
                //verticalAlignment: Qt.AlignVCenter
                color:"black"
                font.pixelSize:JDisplay.sp(22)

                text: {
                    switch (simManager.pinRequired) {
                    case OfonoSimManager.NoPin: return i18nd("plasma-phone-components", "No pin (error)");
                    case OfonoSimManager.SimPin: return i18nd("plasma-phone-components", "Enter Sim PIN");
                    case OfonoSimManager.SimPin2: return i18nd("plasma-phone-components", "Enter Sim PIN 2");
                    case OfonoSimManager.SimPuk: return i18nd("plasma-phone-components", "Enter Sim PUK");
                    case OfonoSimManager.SimPuk2: return i18nd("plasma-phone-components", "Enter Sim PUK 2");
                    default: return i18nd("plasma-phone-components", "Unknown PIN type: %1", simManager.pinRequired);
                    }
                }
            }
            Controls.Label {
                id:attemp_pin
                anchors.top:enter_pin.bottom
                anchors.topMargin:  JDisplay.dp(8)
                anchors.horizontalCenter: parent.horizontalCenter
                color:"black"
                font.pixelSize:JDisplay.sp(18)
                //verticalAlignment: Qt.AlignVCenter
                text: simManager.pinRetries && simManager.pinRetries[simManager.pinRequired] ? i18np("%1 attempt left", "%1 attempts left", simManager.pinRetries[simManager.pinRequired]) : "";
            }

            Rectangle {
                id: pinInputRect
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:attemp_pin.bottom
                anchors.topMargin:  JDisplay.dp(38)
                width: root.width * 0.2339
                height: root.height * 0.0463


                Kirigami.JTextField {
                    id:pinLabel
                    property color bgColor: "#99C3C3CF"//JTheme.textFieldBackground
                    property color selectColor: Kirigami.JTheme.textFieldSelectColor
                    property int borderWidth: JDisplay.dp(1)
                    property int bgRadius: JDisplay.dp(10)

                    width: root.width * 0.2339
                    height: root.height * 0.0463
                    echoMode:TextInput.Password
                    visible: true

                    background:Rectangle{
                            color:pinLabel.bgColor
                            radius: pinLabel.bgRadius
                            border.color: pinLabel.activeFocus === true ? Kirigami.JTheme.textFieldBorder : Kirigami.JTheme.buttonBorder
                            border.width: pinLabel.activeFocus === true ?  pinLabel.borderWidth : 0
                    }
                }
            }

            Item {
                id:number_pad
                anchors.top: pinInputRect.bottom
                anchors.topMargin: root.height * 0.057
                anchors.horizontalCenter: parent.horizontalCenter

                width: root.width * 0.223//198//
                height: root.height * 0.395//256//

                GridLayout {
                    id: numberGrid
                    property string thePw
                    anchors.fill:  parent
                    visible: true

                    columnSpacing: root.width * 0.0225
                    rowSpacing: root.height * 0.0247

                    columns: 3

                    // numpad keys
                    Repeater {
                        model: ["1", "2", "3", "4", "5", "6","7", "8", "9","←","0","ok"]

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                id: keyRect
                                anchors.centerIn: parent
                                width: parent.width
                                height: width
                                radius: height / 3
                                color: "#255255255"
                                visible: modelData.length > 0
                                opacity: 0.2//modelData === "←" || modelData === " " ? 0 : 0.2
                                enabled: modelData === " " ? false : true

                                PropertyAnimation {
                                    id: colorAnimation
                                    duration: 200
                                    target: keyRect
                                    property: "color"
                                    from: "#255255255"
                                    to: "gray"
                                    onFinished: {
                                        console.log(" animation finished::::")
                                        keyRect.color = "#255255255"
                                    }
                                }

                                MouseArea {
                                    id: mouse
                                    anchors.fill: parent
                                    onPressed: colorAnimation.start()

                                    hoverEnabled: true
                                    onClicked: {
                                        if(modelData === "←")
                                        {
                                            if(edit_input.length>0)
                                            {
                                                edit_input.text = edit_input.text.substring(0,edit_input.length-1)
                                            }
                                            return
                                        }
                                        else if(modelData === "ok")
                                        {
                                            simManager.enterPin(simManager.pinRequired, edit_input.text)
                                            edit_input.clear();
                                            return;
                                        }

                                        edit_input.text = edit_input.text+modelData
                                    }
                                    onPressAndHold: {
                                        if(modelData === "←") {
                                            edit_input.clear()
                                        }
                                    }

                                }
                            }

                            PlasmaComponents.Label {
//                                visible: !(modelData === "←")
                                text: modelData
                                anchors.centerIn: parent
                                font.pixelSize: Math.ceil(root.height * 0.0355) //23
                                color: "#000000"
                            }

//                            Image {
//                                id: keyImage
//                                width: Math.ceil(root.height * 0.0278)
//                                height: Math.ceil(root.height * 0.0216)
//                                anchors.centerIn: parent
//                                visible: modelData === "←"
//                                source: "file:///usr/share/icons/jing/SwiMachine/delate.svg"
//                            }
                        }
                    }
                }
            }

        }
    }
}
