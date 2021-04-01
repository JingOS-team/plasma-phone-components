/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *   Copyright 2021 Rui Wang <wangrui@jingos.com>
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
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

NanoShell.FullScreenOverlay {
    id: window

    visible: false
    width: Screen.width
    height: Screen.height
    property int offset: 0
    property int overShoot: units.gridUnit * 2
    property int tasksCount: window.model.count
    property int currentTaskIndex: -1
    property TaskManager.TasksModel model
    property alias taskListHandle: tasksView

    Component.onCompleted: plasmoid.nativeInterface.panel = window;

    onTasksCountChanged: {
        if (tasksCount == 0) {
            hide();
        }
    }

    color: "transparent"
    // More controllable than the color property
    Rectangle {
        id: bgRectangle
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6 // tasksView.opacity
        MouseArea {
            anchors.fill: parent

            onClicked: {
                hideAnimation.start()
            }
        } 
    }

    function show() {
        if (window.model.count === 0) {
            return;
        }
        window.showTaskFromLauncher()
        showAnimation.start()
    }

    function hide() {
        if (!window.visible) {
            return;
        }
        hideAnimation.start()
    }

    function taskMouseReleased() {
        if (!window.visible) {
            return;
        }
        window.hideTask()
    }

    function setSingleActiveWindow(id, delegate) {
        if (id < 0) {
            return;
        }
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = window.model.index(i, 0)
            if (i == id) {
                window.model.requestActivate(idx);
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
        activateAnim.delegate = delegate;
        activateAnim.restart();
    }

    function showTaskFromLauncher() {
        tasksView.lastPosition = Qt.point(0,0)
        tasksView.opacity = 1
        tasksView.visible = true
        window.visible = true
        tasksView.currentMargins = 0
        tasksView.lastMScale = 0.5

        minimizeAppsTimer.start();      
    }
    function showTask() {
        tasksView.currentMargins = 0
        tasksView.lastMScale = 1
        tasksView.mScale = 1
        tasksView.visible = true
        window.visible = true
        tasksView.x = 0
        tasksView.y = 0
        tasksView.contentX = 0
        minimizeAppsTimer.start();
    }

    function hideTask() {
        tasksView.showListLauncher = false
        tasksView.pressedPosition = Qt.point(0,0)
        tasksView.lastPosition = Qt.point(0,0)
        window.visible = false
        tasksView.visible = false
        tasksView.currentIndex = 0
        tasksView.currentMargins = 0
        tasksView.x = 0
        tasksView.y = 0
        tasksView.lastMScale = 1
        tasksView.mScale = 1
        window.visible = false
        tasksView.positionViewAtBeginning()
    }

    function showListTask() {
        tasksView.showListLauncher = true
        bgRectangle.opacity = 0.6
        tasksView.lastPosition = Qt.point(0,0)
        tasksView.x = 0
        tasksView.y = 0
        tasksView.opacity = 1
        tasksView.visible = true
        window.visible = true
        tasksView.currentMargins = 0

        tasksView.lastMScale = 0.5
        tasksView.mScale = 0.5
        tasksView.x = 0
        tasksView.y =  - tasksView.height / 2 + tasksView.height * 0.5 / 2
    }
    
    Timer {
        id: minimizeAppsTimer
        interval: 155
        running: false 
        repeat: false
        onTriggered: root.minimizeAll();
    }

    SequentialAnimation {
        id: activateAnim
        property Item delegate
        ScriptAction {
            script: {
                activateAnim.delegate.z = 2;
            }
        }
        ParallelAnimation {
            OpacityAnimator {
                target: window.contentItem
                from: 1
                to: 0
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScaleAnimator {
                target: activateAnim.delegate
                from: 1
                to: 2
                // To try tosync up with kwin animation
                duration: units.longDuration * 0.85
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                window.visible = false;
            }
        }
    }

    //    onOffsetChanged: tasksView.contentY = offset + grid.y
    onVisibleChanged: {
        if (!visible) {
            tasksView.contentY = 0;
            //            moveTransition.enabled = false;
            scrollAnim.running = false;
            activateAnim.running = false;
            window.contentItem.opacity = 1;
            if (activateAnim.delegate) {
                activateAnim.delegate.z = 0;
                activateAnim.delegate.scale = 1;
            }
        }
        MobileShell.HomeScreenControls.taskSwitcherVisible = visible;
    }

    SequentialAnimation {
        id: scrollAnim
        property alias to: internalAnim.to
        property alias from: internalAnim.from
        ScriptAction {
            script: window.showFullScreen();
        }
        NumberAnimation {
            id: internalAnim
            target: tasksView
            properties: "contentX"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: {
                if (tasksView.contentX <= 0 || tasksView.contentX >= tasksView.contentWidth - window.width) {
                    window.visible = false;
                    setSingleActiveWindow(currentTaskIndex);
                } else {
                    moveTransition.enabled = true;
                }
            }
        }
    }

    ParallelAnimation {
        id: showAnimation

        OpacityAnimator {
            target: bgRectangle
            from: 0
            to:0.6
            duration: tasksView.animationNum 
        }
        OpacityAnimator {
            target: tasksView
            from: 0
            to:1
            duration: tasksView.animationNum 
        }
        NumberAnimation {
            target: tasksView
            property: "mScale"; 
            from:0
            to:0.5
            // To try tosync up with kwin animation
            duration: tasksView.animationNum 
        }

        NumberAnimation { 
            target: tasksView; 
            property: "x"; 
            to: 0; 
            duration: tasksView.animationNum 

        }
        NumberAnimation { 
            target: tasksView; 
            property: "y"; 
            from: 0
            to: - tasksView.height / 2 + tasksView.height * 0.5 / 2
            duration: tasksView.animationNum 
        }
    }

    ParallelAnimation {
        id: hideAnimation

        onStopped:  {
            hideTask();
        }

        OpacityAnimator {
            target: bgRectangle
            to:0
            duration: tasksView.animationNum 
            easing.type: Easing.InOutQuad
        }
        NumberAnimation { 
            target: tasksView; 
            property: "x"; 
            to: 0; 
            duration: tasksView.animationNum 
        }
        NumberAnimation { 
            target: tasksView; 
            property: "y"; 
            to: - tasksView.height / 2 + tasksView.height * 0.3 / 2 ; 
            duration: tasksView.animationNum 
        }
        PropertyAnimation { 
            target: tasksView; 
            property: "scale"; 
            to: 0 ; 
            duration: tasksView.animationNum 
        }
        // PropertyAnimation { 
        //     target: tasksView; 
        //     property: "opacity"; 
        //     to: 0 ; 
        //     duration: tasksView.animationNum 
        // }
    }

    ListView {
        id: tasksView

        width: window.width
        height: window.height

        property real rotationScale: 0.3
        property real rotationScale_15 : rotationScale / 15
        property real mScale: 1
        property real lastMScale: 1
        property point pressedPosition: Qt.point(0,0)
        property point lastPosition: Qt.point(0,0)
        property int currentMargins: 0
        property int animationNum: units.longDuration * 1.3
        property bool startFromLauncher: true
        property bool showListLauncher: false

        displayMarginBeginning : window.width * count
        displayMarginEnd : window.width * count

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        cacheBuffer: window.width * 3
        transformOrigin: Item.Bottom
        preferredHighlightBegin: 0
        preferredHighlightEnd: 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        scale: tasksView.mScale
        clip: false
        spacing: window.width / 10
        // maximumFlickVelocity:9000

        model: window.model
        delegate: Task {
            id: task
            width: window.width
            height: window.height
            visible: hideAnimation.running && index !== tasksView.currentIndex ? false : true
        }
        
        signal updateCurrentScale(var currentScale)

        function listViewToHide() {
            hideAnimation.start()
        }

        NumberAnimation on contentX {
            id: contentXAnim
            duration: 300

            onStopped: {
                //! fix current index
                var index = tasksView.indexAt(tasksView.contentX+tasksView.width/2, tasksView.contentY+tasksView.height/2);
                if (index === -1)
                    tasksView.currentIndex = 0;
                else {
                    tasksView.currentIndex = index;
                }
            }
        }

        function scrollNextPage() {
            if (currentIndex <= count-1) {
                contentXAnim.to = -tasksView.width;
                contentXAnim.start();
            }
        }
    }
}
