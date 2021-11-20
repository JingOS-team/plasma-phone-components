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
import QtQuick.Controls 2.5
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.kirigami 2.15

Item {
    id:tempIrem
    property string pinLabel: i18nd("plasma-phone-components", "Password")
    property string lastKeyPressValue: "0"
    property bool simpleFlag: true
    property int currentIndex : -1
    property bool charFlag: true
    property string password
    property bool screenBrightness: true
    property bool revKeyInput: false
    property bool simpleKeyPressFlag: false
    property int animDuration: 75

    focus: true

    Component.onCompleted: {
        var strType = passTypeFlag.readPassWdTyp()
        if(strType === "simple") {
            simpleFlag = true
        } else if(strType === "complex") {
            simpleFlag = false
        }
        passwdTychange(simpleFlag)
    }

    function passwdTychange(flag) {
        if(flag) {
            virtuaKey.close()
            tempIrem.forceActiveFocus()
            tempIrem.focus = true
        } else {
            keyLineEdit.lableId.forceActiveFocus()
            if(tempIrem.revKeyInput)
                virtuaKey.open()
            else
               virtuaKey.close()
        }
        clear()
        keyLineEdit.clearData()
    }

    function viewDisplay(display) {
        if(display) {
            if(!simpleFlag) {
                virtuaKey.open()
                keyLineEdit.lableId.forceActiveFocus()
            } else {
                tempIrem.forceActiveFocus()
                tempIrem.focus = true
            }
        } else {
            if(!simpleFlag)
                virtuaKey.close()
        }
    }

    // keypad functions
    function backspace() {
        if(currentIndex < 0) {
            charFlag = true
            return;
        }
        charFlag=false
        currentIndex --
        tempIrem.password = tempIrem.password.substr(0, tempIrem.password.length - 1)
    }

    function resetKeyPad() {
        clear()
        keyLineEdit.clearData()
    }

    function clear() {
        charFlag = true
        currentIndex = -1
        tempIrem.password = "";
    }

    function enter() {
        if(simpleFlag) {
            if(tempIrem.password !== "")
                authenticator.tryUnlock(tempIrem.password)
        } else {
            if(keyLineEdit.labelData !== "")
                authenticator.tryUnlock(keyLineEdit.labelData)
        }
    }

    function keyPress(data) {
        if(keypad.pinLabel !== i18nd("plasma-phone-components", "Password")) {
            keypad.pinLabel = i18nd("plasma-phone-components", "Password")
        }
        if(simpleFlag) {
            if(currentIndex >= 5) {
                return
            } else {
                tempIrem.password += data
                if(tempIrem.password.length == 6) {
                    enter()
                }
            }
            lastKeyPressValue = data
//            charFlag = true
//            letterTimer.restart()
            currentIndex ++
        }
    }

    Connections {
        target: authenticator

        function onFailed() {
            if(simpleFlag){
                charFlag = false
                animDuration = 150
                dotDisplay.shake()
            } else {
                resetKeyPad()
            }
            pinLabel = i18nd("plasma-phone-components", "Wrong Password")

        }

        function onSucceeded() {
            startAnim()
            iconChangFlag = true
            tempIrem.revKeyInput = false
            isIgnoreTheFirstSignal=false
            resetKeyPad()
            keypad.pinLabel = i18nd("plasma-phone-components", "Password");
        }

        function onScreenBrightness(status) {
            if(status === 0) {
                tempIrem.screenBrightness=false
                keypad.show(false)
            } else if(status === 1) {
                tempIrem.screenBrightness=true
            } else {
                tempIrem.screenBrightness=true
            }
        }

        function onShowViewSig() {
            var strType = passTypeFlag.readPassWdTyp()
            if(strType === "simple") {
                simpleFlag = true
            } else if(strType === "complex") {
                simpleFlag = false
            }
            passwdTychange(simpleFlag)
        }
    }

    // listen for keyboard events
    Keys.onPressed: {
        if(!tempIrem.screenBrightness || ((event.key === Qt.Key_Escape) && (event.modifiers & Qt.MetaModifier )) || event.key === 0x00 ||
                (event.key > 0x010000b6 && event.key < 0x0100010b)  || ((event.key === Qt.Key_Escape) && (event.modifiers & Qt.AltModifier)) ) {
            return
        }

        if(!tempIrem.revKeyInput) {
            keypad.show(true)
            return
        }

        if(event.key === Qt.Key_Backspace) {
            backspace();
        } else if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            enter()
        } else if(event.key === Qt.Key_Tab) {
            simpleFlag =! simpleFlag
            passwdTychange(simpleFlag)
        } else if(event.key === Qt.Key_Escape) {
            keypad.show(false)
        } else if(event.text !== "") {
            if(event.key === Qt.Key_Space)
                return
            var n = Number(event.text)
            if (!isNaN(n)) {
                keyPress(event.text)
            }
        }
    }

    // trigger turning letter into dot after 500 milliseconds
    Timer {
        id: letterTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            charFlag = false
        }
    }

    Label {
        id:passTitle
        width: root.width * 0.1227
        height: root.height * 0.04475
        anchors.top: parent.top
        anchors.topMargin: root.height * 0.193
        anchors.horizontalCenter: parent.horizontalCenter
        text: pinLabel
        font.pixelSize: Math.ceil(root.height * 0.0293)
        color: "#ffffff"
        font.weight :Font.Medium
        horizontalAlignment:Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Item {
        id:passDisplay
        anchors.top: passTitle.bottom
        anchors.topMargin: root.height * 0.0277
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.height * 0.0463
        width: parent.width

        JKeyBdLineEdit {
            id:keyLineEdit
            anchors.centerIn: parent
            width: root.width * 0.2339
            height: root.height * 0.0463
            visible: !simpleFlag
            courseColor: "white"
            textColor: "white"
            color: JTheme.colorScheme === "jingosLight" ? "#99C3C3CF" : JTheme.textFieldBackground
            cleanIconBackgroundColor: "white"
            visableIconColor: "white"
            cleanIconColor: "#00000000"
            reciveKeyPress: tempIrem.revKeyInput
            onMousePress: {
                if(revKeyInput) {
                    virtuaKey.open()
                }
            }

            onKeyPressSig: {
                if(!tempIrem.screenBrightness || ((event.key === Qt.Key_Escape) && (event.modifiers & Qt.MetaModifier )) || event.key === 0x00 ||
                        (event.key > 0x010000b6 && event.key < 0x0100010b) || ((event.key === Qt.Key_Escape) && (event.modifiers & Qt.AltModifier))) {
                    return
                }
                if(!tempIrem.revKeyInput) {
                    keypad.show(true)
                } else {
                    if(keyevent.key === Qt.Key_Escape ){
                        keypad.show(false)
                    } else if(keyevent.key === Qt.Key_Tab) {
                        simpleFlag =! simpleFlag
                        passwdTychange(simpleFlag)
                    }
                }
            }
        }

        Rectangle{
            id: dotRect
            color: "transparent"
            anchors.centerIn:parent
            width: dotDisplay.width

            Row {
                id: dotDisplay
                //            anchors.centerIn:parent
                visible: simpleFlag
                spacing: root.height * 0.02
                function shake() {
                    shaker.restart()
                }

                property SequentialAnimation shaker:SequentialAnimation {
                    loops: 2
                    alwaysRunToEnd: true

                    PropertyAnimation {
                        target: dotDisplay
                        property: "x"
                        from: 0; to: 15
                        easing.type: Easing.InQuad
                        duration: 25
                    }
                    PropertyAnimation {
                        target: dotDisplay
                        property: "x"
                        from: 15; to: -15
                        easing.type: Easing.OutInQuad
                        duration: 50
                    }
                    PropertyAnimation {
                        target: dotDisplay
                        property: "x"
                        from: -15; to: 0
                        easing.type: Easing.OutQuad
                        duration: 25
                    }
                    onFinished: {
                        resetKeyPad()
                        animDuration = 75
                    }
                }
                Repeater {
                    model: passwordInput

                    delegate: Item {
                        height:root.height * 0.017
                        width: root.height * 0.017

                        Rectangle { // dot
//                            visible: index == currentIndex ? !charFlag : true// hide dot if number is shown
                            anchors.centerIn: parent
                            width:  parent.width
                            height: parent.height
                            radius: height / 2
                            color: index < currentIndex+1 ?  "#ffffff":"#26000000"
//                            opacity: index < currentIndex+1 ? 1 : 0.15
                            Behavior on color {
                                PropertyAnimation {
                                    duration: animDuration
                                }
                            }
                        }
                    }
                }
            }
        }
        ListModel {
            id:passwordInput

            ListElement {value: -1}
            ListElement {value: -1}
            ListElement {value: -1}
            ListElement {value: -1}
            ListElement {value: -1}
            ListElement {value: -1}
        }
    }

    Item {
        id:passType
        anchors.top: passDisplay.bottom
        anchors.topMargin: simpleFlag ? root.height * 0.094 : root.height * 0.0663
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.height * 0.0263
        width: parent.width

        Label {
            height: parent.height
            width: parent.width * 0.0149
            anchors.centerIn: parent
            text: simpleFlag ? i18nd("plasma-phone-components", "Complex Password"):
                              i18nd("plasma-phone-components", "Simple Password")
            font.pixelSize: Math.ceil(root.height * 0.017)
            color: "#99FFFFFF"
            font.underline: false
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item {
        anchors.top: passDisplay.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.height * 0.04
        width: root.width * 0.112
        height: root.height * 0.0973
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(tempIrem.revKeyInput) {
                    simpleFlag =! simpleFlag
                    passwdTychange(simpleFlag)
                }
            }
        }
    }

    Item {
        anchors.top: passType.bottom
        anchors.topMargin: root.height * 0.037
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.width * 0.223//198//
        height: root.height * 0.395//256//

        GridLayout {
            id: numberGrid
            property string thePw
            anchors.fill:  parent
            visible: simpleFlag

            columnSpacing: root.width * 0.0225
            rowSpacing: root.height * 0.0247

            columns: 3

            // numpad keys
            Repeater {
                model: ["1", "2", "3", "4", "5", "6","7", "8", "9","←","0"," "]

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
                        opacity: modelData === "←" || modelData === " " ? 0 : 0.2
                        enabled: tempIrem.simpleKeyPressFlag ? (modelData === " " ? false : true) : false

//                        Behavior on color {
//                            PropertyAnimation {
//                                duration: 500
//                            }
//                        }
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
//                            onReleased: parent.color = "#255255255"
//                            onCanceled: parent.color = "#255255255"
                            hoverEnabled: true
                            onClicked: {
                                if(modelData === "←") {
                                    backspace()
                                } else {
                                    keyPress(modelData)
                                }
                            }
                            onPressAndHold: {
                                if(modelData === "←") {
                                    clear();
                                }
                            }
                            onContainsMouseChanged: {
                                if(mouse.pressed) {
                                    if(modelData === "←") {
                                        backspace()
                                    } else {
                                        keyPress(modelData)
                                    }
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        visible: !(modelData === "←")
                        text: modelData
                        anchors.centerIn: parent
                        font.pixelSize: Math.ceil(root.height * 0.0355) //23
                        color: "#ffffff"
                    }

                    Image {
                        id: keyImage
                        width: Math.ceil(root.height * 0.0278)
                        height: Math.ceil(root.height * 0.0216)
                        anchors.centerIn: parent
                        visible: modelData === "←"
                        source: "file:///usr/share/icons/jing/SwiMachine/delate.svg"
                    }
                }
            }
        }
    }

    JPasswdKeyBd {
        id: virtuaKey
        boardWidth: root.width
        boardHeight: root.height * 0.5069
        y: root.height - boardHeight
        closePolicy: Popup.NoAutoClose
        onKeyBtnClick: {
            if(tempIrem.pinLabel !== i18nd("plasma-phone-components", "Password")) {
                tempIrem.pinLabel = i18nd("plasma-phone-components", "Password")
            }
            keyLineEdit.opAddStr(str)
        }
        onKeyBtnEnter: {
            tempIrem.enter()
        }
        onKeyBtnDel: {
            keyLineEdit.opSubStr()
        }
    }

    PlasmaCore.PassWDType {
        id: passTypeFlag
    }

    Timer {
        id: initTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if(simpleFlag === true) {
                tempIrem.forceActiveFocus()
                tempIrem.focus = true
            } else {
                keyLineEdit.lableId.forceActiveFocus()
            }
        }
    }
}
