/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import QtGraphicalEffects 1.6
import jingos.display 1.0

Rectangle {
    id: delegateRoot
    anchors.fill: parent
    color: delegateRoot.toggled ? "#3c4be8" : root.isDarkScheme? Qt.rgba(142 / 255,142 / 255,147 / 255,0.2): Qt.rgba(248 / 255,248 / 255,248 / 255,0.7)
    radius: height / 3
    property bool toggled: model.enabled
    signal closeRequested
    signal panelClosed

    Rectangle {
        id: stateRectangle
        anchors.fill: parent
        color: "#000000"
        radius: delegateRoot.radius
        opacity: 0
    }

    Behavior on opacity {
        NumberAnimation { duration: 100 }
    }

    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            stateRectangle.opacity = 0.2
        }

        onExited: {
            stateRectangle.opacity = 0
        }

        onPressed: {
            stateRectangle.opacity = 0.4
        }
        onReleased: {
            stateRectangle.opacity = 0
        }
        onCanceled: {
            stateRectangle.opacity = 0
        }

        onClicked: {
            if (delegateRoot.toggle) {
                delegateRoot.toggle();
            } else if (model.toggleFunction) {
                root[model.toggleFunction]();
            } else if (model.settingsCommand) {
                plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                root.closeRequested();
            }
        }
        onPressAndHold: {
            if (model.settingsCommand) {
                plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                closeRequested();
            } else if (model.toggleFunction) {
                root[model.toggleFunction]();
            }
        }
    }

    Row {
        anchors.fill: parent
        z: 100

        Item {
            width: (parent.width / 5) * 2
            height: parent.height

            Image {
                id: imgIcon
                anchors.centerIn: parent
                sourceSize.width: parent.height / 2;
                sourceSize.height: parent.height / 2;

                source: "file:///usr/share/icons/jing/jing/settings/" + model.icon + ".svg"
                visible: false
                antialiasing:true
            }

            ColorOverlay {
                anchors.fill: imgIcon
                source: imgIcon
                color: delegateRoot.toggled ? "#ffffff" : root.isDarkScheme? "white":"#000000"
                opacity: delegateRoot.toggled ? 1 : 0.8
                antialiasing: true
            }
        }

        Item {
            width: (parent.width / 5) * 3
            height: parent.height*2 / 3
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: titleText
                anchors.left: parent.left
                anchors.leftMargin: - JDisplay.dp(10)
                anchors.top: parent.top
                anchors.topMargin: nameText.text == "" ? parent.height / 2 - titleText.height / 2 : 0
                text: model.text
                font.pixelSize: JDisplay.sp(13)
                color: delegateRoot.toggled ? "#ffffff" : root.isDarkScheme? "white": "#000000"
                elide: Text.ElideRight
            }

            Text {
                id: nameText
                anchors.left: parent.left
                anchors.leftMargin: - JDisplay.dp(10)
                anchors.right: parent.right
                anchors.rightMargin: JDisplay.dp(20)
                anchors.top: titleText.bottom
		        anchors.topMargin: JDisplay.dp(3)
                // anchors.bottomMargin: -(nameText.contentHeight * 0.5)
                text: delegateRoot.toggled ? (model.connectStatus=="Connected"? model.currentConnectedName:"") : i18nd("plasma-phone-components", "No connection")
                font.pixelSize: JDisplay.sp(10)
                color: delegateRoot.toggled ? "#ffffff" : root.isDarkScheme? "white":"#000000"
                elide: Text.ElideRight
            }
        }
    }
}
