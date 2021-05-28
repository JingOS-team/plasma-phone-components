
/*
 *   Copyright 2021 Bob Wu <pengbo.wu@jingos.com>
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

NanoShell.FullScreenOverlay {
    id: windowNotification

    property int offset: 0
    property int openThreshold
    property bool userInteracting: false
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    property int drawerWidth:  wideScreen ? width / 3 : width
    property int drawerHeight
    property int drawerX: 8
    property int drawerY: 0
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable

    property bool isNotificationPanelOpen: false

    color: "transparent"//Qt.rgba(0, 0, 0, 0.6 * Math.min(1, offset/contentArea.height))
    property alias contentItem: contentArea.contentItem
    property int headerHeight
    property bool hasShown: false

    signal closed

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }
    
    property int direction: SlidingPanel.MovementDirection.None

    function stopAnim() {
        openAnim.stop();
        closeAnim.stop();
    }

    function open() {
        slidingPanel.close()
        windowNotification.showFullScreen();
        openAnim.restart();
        hasShown = true;
    }

    function close() {
        closeAnim.restart();
        hasShown = false;
    }

    function toggle() {
        if (hasShown) {
            close();
        } else {
            open();
        }
    }

    function updateState() {
        if (windowNotification.direction === SlidingPanel.MovementDirection.None) {
            if (offset < openThreshold) {
                close();
            } else {
                openAnim.restart();
            }
        } else if (offset > openThreshold && windowNotification.direction === SlidingPanel.MovementDirection.Down) {
            openAnim.restart();
        } else if (mainFlickable.contentY > openThreshold) {
            close();
        } else {
            openAnim.restart();
        }
    }

    Timer {
        id: updateStateTimer
        interval: 0
        onTriggered: updateState()
    }

    onActiveChanged: {
        if (!active) {
            close();
        }
    }

    onBeforeSynchronizing: {
        setBlur(Qt.rect(drawerX , offset - notifyQuickSettingsParent.height + headerHeight,
                        notifyQuickSettingsParent.width, notifyQuickSettingsParent.height), notifyQuickSettingsParent.width / 12, notifyQuickSettingsParent.width / 12);
    }

    SequentialAnimation {
        id: closeAnim

        PropertyAnimation {
            target: windowNotification
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            properties: "offset"
            from: windowNotification.offset
            to: -headerHeight * 2
        }
        ScriptAction {
            script: {
                windowNotification.offset = -headerHeight * 2
                mainFlickable.oldContentY = -headerHeight * 2
                isNotificationPanelOpen = false
                windowNotification.visible = false;
                windowNotification.closed();
            }
        }
        onFinished: {
            isNotificationPanelOpen = false
        }
    }
    
    PropertyAnimation {
        id: openAnim
        target: windowNotification
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "offset"
        from: windowNotification.offset
        to: contentArea.height
        onFinished: {
            if (mainFlickable.contentY !== 0) {
                mainFlickable.contentY = 0
            }
            isNotificationPanelOpen = true
        }
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

            contentWidth: windowNotification.width
            contentHeight: windowNotification.height * 2
            bottomMargin: windowNotification.height

            Binding {
                id: bindingHandle

                target: mainFlickable
                property: "contentY"
                value: -windowNotification.offset + contentArea.height
                when: !mainFlickable.moving && !mainFlickable.dragging && !mainFlickable.flicking
                restoreMode: Binding.RestoreBindingOrValue
            }

            onContentYChanged: {
                if (contentY === oldContentY) {
                    windowNotification.direction = SlidingPanel.MovementDirection.None;
                } else {
                    windowNotification.direction = contentY > oldContentY ? SlidingPanel.MovementDirection.Up : SlidingPanel.MovementDirection.Down;
                }
                windowNotification.offset = -contentY + contentArea.height
                oldContentY = contentY;
            }

            onMovementStarted: windowNotification.userInteracting = true;
            onFlickStarted: windowNotification.userInteracting = true;

            onMovementEnded: {
                windowNotification.userInteracting = false;
                windowNotification.updateState();
            }
            MouseArea {
                id: dismissArea
                z: 2
                width: parent.width
                height: mainFlickable.contentHeight
                onClicked: windowNotification.close();
                PlasmaComponents.Control {
                    id: contentArea
                    z: 1
                    x: drawerX
                    y: drawerY
                    width: drawerWidth
                    height: windowNotification.drawerHeight

                    Behavior on height {
                        NumberAnimation{
                            duration: 150
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: contentArea
        onHeightChanged: {
            if (isNotificationPanelOpen) {
                mainFlickable.contentY = 0
            }
        }
    }
}
