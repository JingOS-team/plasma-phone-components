/*
 *   Copyright 2014 Marco Martin <notmart@gmail.com>
 *   Copyright 2021 Wang Rui <wangrui@jingos.com>
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

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import QtGraphicalEffects 1.12
import QtQml 2.14
import jingos.display 1.0

NanoShell.FullScreenOverlay {
    id: window

    property int offset: 0
    property int fromOffset:0
    property int openThreshold
    property bool userInteracting: false
    property bool childFocus: false
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    property int drawerWidth:  wideScreen ? width / 3 : width
    property int drawerHeight
    property int drawerX: window.width - window.drawerWidth - JDisplay.dp(8)
    property int drawerY: 0
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable
    color: "transparent"
    property alias contentItem: contentArea.contentItem
    property int headerHeight
    property bool hasShown: false
    property bool slidingPanelIsOpen: false
    property bool animateRunning: false
    property int direction: SlidingPanel.MovementDirection.None

    signal closed

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }

    function init() {
        window.offset = 0
        animateRunning = false
        slidingPanelIsOpen = false
        window.visible = false;
        window.closed();
    }

    function toggle() {
        if (hasShown) {
            close();
        } else {
            open();
        }
    }

    function stopAnim() {
        openAnim.stop();
        closeAnim.stop();
    }

    function open() {
        window.showFullScreen();
        window.offset = contentArea.height
        openAnim.restart();
        hasShown = true;
    }

    function close() {
        closeAnim.restart();
        hasShown = false;
    }

    onActiveChanged: {
        if (!active) {
            if(window.visible)
                close();
        }
    }


    ParallelAnimation {
        id: closeAnim

        // PropertyAnimation {
        //     target: window
        //     duration: root.animationTime
        //     easing.type: Easing.OutSine
        //     properties: "offset"
        //     from: contentArea.height - mainFlickable.contentY//window.offset
        //     to: 0 //-headerHeight * 2
        // }

        PropertyAnimation {
            target: mainScope
            duration: root.animationTime
            easing.type: Easing.OutSine
            properties: "opacity"
            from: 1
            to: 0
        }

        onStarted: {
            animateRunning = true
            setBlur(Qt.rect(0, 0, 1, 1), 1, 1);
        }
        onFinished: {
            window.init()
        }
    }

    ParallelAnimation {
        id: openAnim

        // PropertyAnimation {
        //     target: window
        //     duration: root.animationTime
        //     easing.type: Easing.OutSine
        //     properties: "offset"
        //     from: 0// contentArea.height - mainFlickable.contentY//window.offset
        //     to: contentArea.height
        // }

        PropertyAnimation {
            target: mainScope
            duration: root.animationTime
            easing.type: Easing.OutSine
            properties: "opacity"
            from: 0
            to: 1
        }

        onStarted: {
            setBlur(Qt.rect(0, 0, 1, 1), 1, 1);
            animateRunning = true
        }
        onFinished: {
            animateRunning = false
            slidingPanelIsOpen = true
            setBlur(Qt.rect(drawerX , offset - panelContents.height + headerHeight,
                    panelContents.width, panelContents.height), panelContents.width / 12, panelContents.width / 12);
            if (mainScope.opacity !== 1) {
                mainScope.opacity = 1
            }
        }
    }

    onOffsetChanged: {
        mainFlickable.contentY = contentArea.height - offset
    }

    PlasmaCore.ColorScope {
        id: mainScope

        anchors.fill: parent

        Flickable {
            id: mainFlickable

            anchors {
                fill: parent
                topMargin: headerHeight
            }

            property real oldContentY
            boundsBehavior: Flickable.StopAtBounds

            contentWidth: window.width
            contentHeight: window.height
            bottomMargin: window.height
            interactive: false

            MouseArea {
                id: dismissArea

                z: 2
                width: parent.width
                height: mainFlickable.contentHeight

                onClicked: {
                    window.close();
                }

                PlasmaComponents.Control {
                    id: contentArea
                    z: 1
                    x: drawerX
                    y: drawerY
                    width: drawerWidth
                    height: window.drawerHeight
                }
            }
        }
    }
}
