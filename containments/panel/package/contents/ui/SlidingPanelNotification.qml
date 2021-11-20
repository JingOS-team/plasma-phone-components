/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
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
    id: windowNotification

    // property bool blockFlickable
    property int offset: 0
    property int openThreshold
    property bool userInteracting: false
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    property int drawerWidth:  wideScreen ? width / 3 : width
    property int drawerHeight
    property int drawerX: JDisplay.dp(8)
    property int drawerY: 0
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable
    property bool notificationPanelOpen: false
    property alias contentItem: contentArea.contentItem
    property int headerHeight
    property bool hasShown: false
    property bool animateRunning: false
    property int direction: SlidingPanelNotification.MovementDirection.None

    signal closed()
    signal contentHeightFinished()

    color: "transparent"

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }

    function init() {
        windowNotification.offset = 0
        notificationPanelOpen = false
        windowNotification.animateRunning = false;
        windowNotification.visible = false;
        windowNotification.closed();
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
        windowNotification.showFullScreen();
        openAnim.restart();
    }

    function close() {
        closeAnim.restart();
    }

    onActiveChanged: {
        if (!active) {
            if(windowNotification.visible)
                close();
        }
    }

    onOffsetChanged: {
        mainFlickable.contentY = contentArea.height - offset
    }

    SequentialAnimation {
        id: closeAnim

        ParallelAnimation {
            PropertyAnimation {
                target: windowNotification
                duration: root.animationTime
                easing.type: Easing.OutSine
                properties: "offset"
                from: contentArea.height - mainFlickable.contentY//windowNotification.offset
                to: 0//-headerHeight * 2
            }
            PropertyAnimation {
                target: mainScope
                duration: root.animationTime
                easing.type: Easing.OutSine
                properties: "opacity"
                from: 1
                to: 0
            }
        }

        ScriptAction {
            script: {
                windowNotification.init()
            }
        }
        onStarted: {
            notificationPanelOpen = false
            animateRunning = true
            setBlur(Qt.rect(0, 0, 1, 1), 1, 1);
        }

        onFinished: {
            hasShown = false
            animateRunning = false
        }
    }

    ParallelAnimation {
        id: openAnim

        PropertyAnimation {
            target: windowNotification
            duration: root.animationTime
            easing.type: Easing.OutSine
            properties: "offset"
            from: contentArea.height - mainFlickable.contentY
            to: contentArea.height
        }

        PropertyAnimation {
            target: mainScope
            duration: root.animationTime
            easing.type: Easing.OutSine
            properties: "opacity"
            from: 0
            to: 1
        }
        onStarted: {
            notificationPanelOpen = true
            animateRunning = true
            setBlur(Qt.rect(0, 0, 1, 1), 1, 1);
        }

        onFinished: {
            hasShown = true
            animateRunning = false
            setBlur(Qt.rect(drawerX , offset - notifyQuickSettingsParent.height + headerHeight,
                        notifyQuickSettingsParent.width, notifyQuickSettingsParent.height), notifyQuickSettingsParent.width / 12, notifyQuickSettingsParent.width / 12);
            if (mainScope.opacity !== 1) {
                mainScope.opacity = 1
            }
        }
    }

    PlasmaCore.ColorScope {
        id: mainScope

        anchors.fill: parent

        Flickable {
            id: mainFlickable

            property bool handlePanel: false

            anchors {
                fill: parent
                topMargin: headerHeight
            }

            property real oldContentY
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: windowNotification.width
            contentHeight: windowNotification.height * 2
            bottomMargin: windowNotification.height
            flickableDirection: Flickable.VerticalFlick
            interactive: false

            MouseArea {
                id: dismissArea

                width: parent.width
                height: mainFlickable.contentHeight
                z: 2
                enabled: !animateRunning || !userInteracting

                onClicked: {
                    windowNotification.close();
                }
                PlasmaComponents.Control {
                    id: contentArea

                    z: 1
                    x: drawerX
                    y: drawerY
                    width: drawerWidth
                    height: windowNotification.drawerHeight

                    Behavior on height {
                        SequentialAnimation {
                            NumberAnimation {
                                target: contentArea
                                properties: "height"
                                duration: nofifySlidingPanel.animationTime
                                easing.type: Easing.OutSine
                            }
                            ScriptAction {
                                script: {
                                    contentHeightFinished()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: contentArea
        onHeightChanged: {
            if (notificationPanelOpen) {
                mainFlickable.contentY = 0
                offset = contentArea.height
                setBlur(Qt.rect(drawerX , offset - notifyQuickSettingsParent.height + headerHeight,
                        notifyQuickSettingsParent.width, notifyQuickSettingsParent.height), notifyQuickSettingsParent.width / 12, notifyQuickSettingsParent.width / 12);
            }
        }
    }
}
