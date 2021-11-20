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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import QtGraphicalEffects 1.6

Rectangle {
    id: stateDelegateRoot
    anchors.fill: parent
    color:  isDarkScheme ? Qt.rgba(142 / 255,142 / 255,147 / 255,0.2): Qt.rgba(248 / 255,248 / 255,248 / 255,0.7)
    radius: height / 4
    property bool toggled: model.enabled
    signal closeRequested
    signal panelClosed

    property string icon_source: model.enabled ? model.enableIcon : model.disableIcon

    opacity: 1

    Rectangle {
        id: stateRectangle
        anchors.fill: parent
        color: "#000000"
        radius: stateDelegateRoot.radius
        opacity: 0
    }

    Behavior on opacity {
        NumberAnimation { duration: 100 }
    }

    // DropShadow {
    //     anchors.fill: delegateRoot
    //     horizontalOffset: 0
    //     verticalOffset: 1
    //     radius: 1.0
    //     samples: 10
    //     cached: true
    //     color: Qt.rgba(0, 0, 0, 0.1)
    //     source: delegateRoot
    //     visible: true
    // }

    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            if(!model.active)
                return;
            stateRectangle.opacity = 0.2
        }

        onExited: {
            stateRectangle.opacity = 0
        }

        onPressed: {
            if(!model.active)
                return;
            stateRectangle.opacity = 0.4
        }
        onReleased: {
            stateRectangle.opacity = 0
        }
        onCanceled: {
            stateRectangle.opacity = 0
        }

        onClicked: {
            if(!model.active)
                return;
            if (stateDelegateRoot.toggle) {
                stateDelegateRoot.toggle();
            } else if (model.toggleFunction) {
                root[model.toggleFunction]();
            } else if (model.settingsCommand) {
                plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                root.closeRequested();
            }
        }
        onPressAndHold: {
            if(!model.active)
                return;
            if (model.settingsCommand) {
                plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                root.closeRequested();
            } else if (model.toggleFunction) {
                root[model.toggleFunction]();
            }
        }
    }

    Image {
        id: imgIcon

        anchors.centerIn: parent
        sourceSize.width: parent.height / 2;
        sourceSize.height: parent.height / 2;

        visible: false
        smooth: true
        antialiasing: true
        source: "file:///usr/share/icons/jing/jing/settings/" + stateDelegateRoot.icon_source + ".svg"
    }

    ColorOverlay {
        anchors.fill: imgIcon
        source: imgIcon
        color: root.isDarkScheme? "white":"#000000"
        opacity: model.active ? 0.8 : 0.3
        antialiasing: true
    }

    Connections {
        target: root
        onClosed: {
            stateRectangle.opacity = 0
        }
    }
}
