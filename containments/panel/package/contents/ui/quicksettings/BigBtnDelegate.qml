/*
 *   Copyright 2021 wangrui <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import QtGraphicalEffects 1.6

Rectangle {
    id: delegateRoot
    anchors.fill: parent
    color: delegateRoot.toggled ? "#3c4be8" : "#f0f0f0"
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
                color: delegateRoot.toggled ? "#ffffff" : "#000000"
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
                anchors.leftMargin: -10
                anchors.top: parent.top
                // anchors.topMargin: - (titleText.contentHeight * 0.5)
                text: model.text
                font.pixelSize: 13
                color: delegateRoot.toggled ? "#ffffff" : "#000000"
                elide: Text.ElideRight
            } 

            Text {
                id: nameText
                anchors.left: parent.left
                anchors.leftMargin: -10
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: titleText.bottom
		anchors.topMargin: 1
                // anchors.bottomMargin: -(nameText.contentHeight * 0.5)
                text: delegateRoot.toggled ? model.currentConnectedName : i18nd("plasma-phone-components", "No connection")
                font.pixelSize: 10
                color: delegateRoot.toggled ? "#ffffff" : "#000000"
                elide: Text.ElideRight
            } 
        }
    }
}
