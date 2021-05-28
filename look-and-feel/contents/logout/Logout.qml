/***************************************************************************
 *   Copyright (C) 2014 by Aleix Pol Gonzalez <aleixpol@blue-systems.com>  *
 *   Copyright (C) 2020 by Linus Jahn <lnj@kaidan.im>                      *
 *   Copyright (C) 2020 by Marco Martin <mart@kde.org                      *
 *   Copyright (C) 2021 by Bangguo Liu <liubangguo@jingos.com>             *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.8 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.plasma.private.sessions 2.0

import "../components"
import "../lockscreen"

Item {
    id: root

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    clip: true

    Controls.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    Image {
        id: background
        anchors.fill: parent
        source: "file:///usr/share/icons/jing/bgblur.png"
    }

    Rectangle {
        id:backgroundMask
        anchors.fill: background
        opacity: 0.5
        color: "#000000"
    }
    SimpleHeaderBar {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.gridUnit
        opacity: 1
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            closeAnim.execute(root.cancelRequested);
        }
    }

    Component.onCompleted: openAnim.restart()
    onVisibleChanged: {
        if (visible) {
            openAnim.restart()
        }
    }

    ParallelAnimation {
        id: openAnim
        OpacityAnimator {
            target: lay
            from: 0
            to: 1
            duration: 100//units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0
            to: 1
            duration: 100//units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: backgroundMask
            from: 0
            to: 0.5
            duration: 100//units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: closeAnim
        property var callback
        function execute(call) {
            if(closeAnim.running)
                return;
            callback = call;
            closeAnim.restart();
        }
        ParallelAnimation {
            OpacityAnimator {
                target: lay
                from: 1
                to: 0
                duration: 100//units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: background
                from: 1
                to: 0
                duration: 100//units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: backgroundMask
                from: 0.5
                to: 0
                duration: 100//units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                if (closeAnim.callback) {
                    closeAnim.callback();
                }
                lay.opacity = 1;
                lay.scale = 1;
                background.opacity = 1;
                backgroundMask=0.5
            }
        }
    }

    Column {
        id: lay
        anchors.centerIn: parent
        width: root.width*0.22
        Item
        {
            id:btnspace1
            width: lay.width
            height: parent.height*0.290
        }
        ActionButton {
            width:lay.width
            height:root.height * 0.1
            iconSource:"file:///usr/share/icons/jing/SwiMachine/system-shutdown.svg"
            text: i18nd("plasma-phone-components", "Close")
            onClicked: {
                closeAnim.execute(root.haltRequested);
            }
        }
        Item
        {
            id:btnspace2
            width: lay.width
            height: parent.height*0.05
        }
        ActionButton {
            width:lay.width
            height:root.height * 0.1
            iconSource: "file:///usr/share/icons/jing/SwiMachine/system-reboot.svg"
            text: i18nd("plasma-phone-components", "Reboot")
            onClicked: {
                closeAnim.execute(root.rebootRequested);
            }
        }

        Item{
            id:concelbtn
            width:lay.width
            height:root.height*0.434
            CancelButton {
                width:root.height * 0.1
                height:root.height * 0.1
                anchors {
                    top: concelbtn.top
                    topMargin:concelbtn.height*0.49
                    leftMargin: 0
                    horizontalCenter: concelbtn.horizontalCenter
                }
                iconSource: "file:///usr/share/icons/jing/SwiMachine/system-cancel.svg"
                text: i18nd("plasma-phone-components", "Cancel")
                onClicked: {
                    closeAnim.execute(root.cancelRequested);
                }
            }
        }

    }
}
