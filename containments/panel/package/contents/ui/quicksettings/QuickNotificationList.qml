/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.14
import QtQml 2.12
import QtQuick.Window 2.14
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.kquickcontrolsaddons 2.0 as KQCAddons
import org.kde.plasma.private.digitalclock 1.0 as DC

import org.kde.kirigami 2.15
import org.kde.plasma.plasmoid 2.0

import jingos.display 1.0
import "jingos" as Jingos

Item {
    id: notificationList

    signal closeRequested
    signal closed
    signal updataTime

    property bool screenshotRequested: false
    property bool deviceConnected : false
    property real listViewContentHeight: listView.contentHeight
    property real listViewCount: listView.count
    property bool isPressed : false
    property alias cleanButton : cleanButton

    property alias cleanTimer: cleanTimer
    property bool timeFormat : timezoneProxy.isSystem24HourFormat

    property real maxContentHeight: JDisplay.dp(505)
    property int pageNum: 1

    property int currentPage: listViewCount ? pageNum : 1
    property int totalPage: listView.contentHeight > maxContentHeight ? (listView.contentHeight % maxContentHeight === 0 ? (listView.contentHeight / maxContentHeight) : (listView.contentHeight / maxContentHeight + 1)) : 1

    property bool couldSlider: true
    signal cleanAll();
    signal backAll();
    signal backOther(int closeIndex);

    onCouldSliderChanged: {
        if (!couldSlider) {
            pageTimer.restart()
        }
    }

    function formatTimeString(formatTime) {
        var timeStr

        var currentTime = new Date()
        var parameterTime = new Date(formatTime.getTime());
        var timeInterval = currentTime.getTime() - parameterTime.getTime()

        if (timeInterval < 0) {
            if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd AP hh:mm");
            } else {
                timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd hh:mm AP");
            }
            return timeStr
        }

        parameterTime.setHours(0)
        parameterTime.setMinutes(0)
        parameterTime.setSeconds(0)
        parameterTime.setMilliseconds(0)

        currentTime.setHours(0)
        currentTime.setMinutes(0)
        currentTime.setSeconds(0)
        currentTime.setMilliseconds(0)

        timeInterval = currentTime.getTime() - parameterTime.getTime()

        if (timeInterval < 1000 * 60 * 60 * 24 * 8) {
            if (timeInterval === 0) {
                if(timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "hh:mm" : "AP hh:mm");
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "hh:mm" : "hh:mm AP");
                }
            } else if (timeInterval === 1000 * 60 * 60 * 24) {
                if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "hh:mm" : "AP hh:mm");
                    timeStr = "昨天 " + timeStr
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "hh:mm" : "hh:mm AP");
                    timeStr = "yesterday " + timeStr
                }
            } else {
                if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "dddd hh:mm" : "dddd AP hh:mm");
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "dddd hh:mm" : "dddd hh:mm AP");
                }
            }
        } else {
            if (currentTime.getFullYear() === parameterTime.getFullYear()) {
                if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "MM-dd hh:mm" : "MM-dd AP hh:mm");
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "MM-dd hh:mm" : "MM-dd hh:mm AP");
                }
            } else if (currentTime.getFullYear() < parameterTime.getFullYear()) {
                if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd AP hh:mm");
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd hh:mm AP");
                }
            } else {
                if (timezoneProxy.getRegionTimeFormat() === "zh_") {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd AP hh:mm");
                } else {
                    timeStr = Qt.formatDateTime(formatTime, timezoneProxy.isSystem24HourFormat ? "yyyy-MM-dd hh:mm" : "yyyy-MM-dd hh:mm AP");
                }
            }
        }
        return timeStr;
    }

    Timer {
        id: updateTimer

        interval: 1000
        repeat : true
        running: true
        onTriggered: updataTime()
    }

    DC.TimeZoneFilterProxy {
        id: timezoneProxy
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    MouseArea {
        id: allMouseArea

        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            isPressed = true
        }
        onReleased: {
            isPressed = false
        }
        onClicked: {
            cleanButton.reset()
            mouse.accepted = true
        }
    }

    Item {
        id: headerItem

        anchors.top: parent.top
        anchors.left: parent.left
        width: listView.width
        height: JDisplay.dp(60)

        Text {
            id: notificationTitle

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: JDisplay.dp(19)

            text: i18nd("plasma-phone-components", "Notification Center")
            font.pixelSize: JDisplay.sp(18)
            color: plasmoid.nativeInterface.isDarkColorScheme ? "#F7F7F7" : Qt.rgba(0, 0, 0, 0.7)
        }

        JSwitchButton {
            id: cleanButton

            width:  JDisplay.dp(33)
            height: JDisplay.dp(33)
            anchors.right: parent.right
            anchors.rightMargin: JDisplay.dp(20)
            anchors.verticalCenter: notificationTitle.verticalCenter
            visible: listView.count !== 0

            source: "file:///usr/share/icons/jing/cleaningAll.svg"
            text: i18nd("plasma-phone-components", "Clear")
            backgroundColor: "transparent"
            labelBackgroundColor: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba(142 / 255, 142/ 255, 147/ 255, 0.20) : Qt.rgba(248 / 255, 248/ 255, 248/255, 0.70)
            radius: JDisplay.dp(9)

            onClicked: {
                pageNum = 1
                cleanAll()
                cleanTimer.restart()
                cleanButton.reset()
            }
            onIsIconChanged: {
                if (!isIcon) {
                    cleanButton.anchors.rightMargin = JDisplay.dp(11)
                } else {
                    cleanButton.anchors.rightMargin = JDisplay.dp(20)
                }
            }
        }
    }

    Timer {
        id: cleanTimer

        running: false
        repeat: false
        interval: nofifySlidingPanel.animationTime
        onTriggered: {
            notifyModel.clearExpired()
        }
    }

    ListView {
        id: listView

        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: JDisplay.dp(10)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: JDisplay.dp(5)
        clip: true
        model: notifyModel

        function setPageNum()
        {
            if (listViewCount > 0) {
                if ((listView.contentHeight - nextContentHeight()) > maxContentHeight) {
                    return  ((listView.contentHeight - nextContentHeight()) % maxContentHeight)  === 0 ?  (listView.contentHeight - nextContentHeight()) / maxContentHeight : (listView.contentHeight - nextContentHeight()) / maxContentHeight + 1
                } else {
                    return 1
                }
            } else {
                return 0
            }
        }

        function previousHeight(){
            return  contentY - originY
        }

        function goPreviousPage()
        {
            if (!couldSlider) {
                rerurn
            }

            if (previousHeight() > 0) {
                if (previousHeight() > maxContentHeight) {
                    listView.contentY = listView.contentY - maxContentHeight
                } else {
                    listView.contentY = listView.contentY - previousHeight()
                }
                pageNum = setPageNum()
            }
        }

        function nextContentHeight() {

            if (listView.contentHeight > maxContentHeight + previousHeight()) {
                return listView.contentHeight - maxContentHeight -  previousHeight()
            } else {
                return 0
            }
        }

        function goNextPage()
        {
            if (!couldSlider) {
                rerurn
            }
            if (listView.contentHeight > maxContentHeight + previousHeight()) {
                if (nextContentHeight() > 0) {
                    if (nextContentHeight() > maxContentHeight) {
                        listView.contentY = listView.contentY + maxContentHeight
                    } else {
                        listView.contentY = listView.contentY + nextContentHeight()
                    }
                    pageNum = setPageNum()
                }
            }
        }

        onContentHeightChanged: {
            pageNum = setPageNum()
        }

        onMovementStarted: {
            backAll();
        }

        Behavior on contentY {
            SequentialAnimation {
                ScriptAction { script:
                couldSlider = false; }
                NumberAnimation { id: animate; duration: 300 ;easing.type: Easing.OutSine}
                ScriptAction { script: couldSlider = true; }
            }
        }

        Text {
            anchors.centerIn: listView
            text: i18nd("plasma-phone-components", "No Notifications")
            font.pixelSize: JDisplay.sp(14)
            color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba( 247 / 255, 247 / 255, 247 / 255, 0.3) : Qt.rgba(0, 0, 0, 0.5)
            visible : listView.count > 0 ? false : true
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
                NumberAnimation { properties: "y"; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
            }
        }

        remove: Transition {
            NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
            NumberAnimation { properties: "y"; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
        }

        removeDisplaced : Transition {
            NumberAnimation { properties: "y"; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
        }

        addDisplaced : Transition {
            NumberAnimation { properties: "y"; duration: nofifySlidingPanel.animationTime ;easing.type: Easing.OutSine}
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            property real oldMouseY: 0

            hoverEnabled: true
            propagateComposedEvents: true

            onPressed: {
                if (couldSlider) {
                    oldMouseY = mouse.y
                }
                mouse.accepted = true
                preventStealing = true
            }

            onReleased: {
                if (couldSlider && (Math.abs(mouse.y - oldMouseY) > 25)) {
                    if ((mouse.y - oldMouseY) > 0) {
                        listView.goPreviousPage()
                    } else {
                        listView.goNextPage()
                    }
                }
                mouse.accepted = true
                preventStealing = true
            }
        }

        delegate: notificationDelegate

        Rectangle {
            id: page

            width: JDisplay.dp(35)
            height: JDisplay.dp(18)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: JDisplay.dp(7)

            visible: true
            opacity: 1
            radius: JDisplay.dp(9)
            color: Qt.rgba(113 / 255, 113 / 255, 124 / 255, 0.95)
            state: "close"

            Label {
                anchors.centerIn: parent
                text: currentPage + "/" + totalPage
                color: "white"
            }

            states: [
                State {
                    name: "show"

                    PropertyChanges {
                        target: page
                        opacity: 1
                    }
                }, State {
                    name: "close"

                    PropertyChanges {
                        target: page
                        opacity: 0
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation {
                    property: "opacity"
                    duration: 150
                }
            }

            Timer {
                id: pageTimer

                repeat: false
                running: false
                interval: 1500

                onRunningChanged: {
                    if (running) {
                        page.state = "show"
                    } else {
                        page.state = "close"
                    }
                }
            }
        }
    }

    Component {
        id: notificationDelegate

        Item {
            id: itemHandle

            property bool isOpen: false
            property bool isEnterMouse: false
            property int iIndex: index

            width: listView.width
            height: rectangleBg.height
            Connections {
                target: notificationList

                onCleanAll: {
                    itemCloseAnim.restart()
                }

                onBackOther: {
                    if(closeIndex !== index) {
                        if(isOpen) {
                            closeAnim.restart()
                        }
                    }
                }
                onBackAll: {
                    closeAnim.restart()
                }
            }

            Rectangle {
                id: deleteBg

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: JDisplay.dp(10)
                height: rectangleBg.height
                width: -rectangleBg.x
                x: JDisplay.dp(0)

                clip: true

                color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba( 142 / 255, 142 / 255, 147 / 255, 0.1) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.4)
                radius: JDisplay.dp(9)

                opacity: {
                    if (deleteBg.width > deleteLabel.contentWidth) {
                        if (deleteBg.width > rectangleBg.width / 3) {
                            return 1
                        } else {
                            return (deleteBg.width - deleteLabel.contentWidth) / ((rectangleBg.width / 3) - deleteLabel.width)
                        }
                    } else {
                        return 0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = true
                    }
                }

                RowLayout {
                    width: parent.width
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    Label {
                        id: deleteLabel

                        Layout.fillWidth: true
                        text: i18nd("plasma-phone-components", "Delete")
                        color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba( 247 / 255, 247 / 255, 247 / 255, 0.55) : Qt.rgba(0, 0, 0, 0.3)

                        font.pixelSize: JDisplay.sp(14)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.Medium
                        clip: true
                    }

                    MouseArea {
                        id: deleteBgMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: isOpen

                        onClicked: {
                            mouse.accepted = true
                            itemCloseAnim.restart()
                        }
                        onPressed: {
                            preventStealing = true
                        }
                    }
                }
            }

            Rectangle {
                id: rectangleBg

                anchors.top: parent.top
                height: column.implicitHeight
                width: parent.width - JDisplay.dp(20)
                x: JDisplay.dp(10)

                color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba(142 / 255, 142 / 255, 147 / 255 ,0.20) : Qt.rgba(248 / 255, 248 / 255, 248 / 255, 0.7)
                clip: true
                radius: JDisplay.dp(9)
                anchors.verticalCenter: parent.verticalCenter
                Column {
                    id: column

                    anchors.fill: parent
                    spacing: JDisplay.dp(3)
                    padding: JDisplay.dp(10)

                    RowLayout {
                        width: parent.width - parent.padding * 2
                        height: titleText.implicitHeight > iconItem.height ? titleText.implicitHeight : iconItem.height
                        spacing: JDisplay.dp(8)

                        PlasmaCore.IconItem {
                            id: iconItem

                            Layout.maximumWidth: JDisplay.dp(15)
                            Layout.minimumWidth: JDisplay.dp(15)
                            Layout.maximumHeight: JDisplay.dp(15)
                            Layout.minimumHeight: JDisplay.dp(15)

                            Layout.fillWidth: true
                            smooth: true
                            visible: model.iconName !== ""
                            source: model.iconName
                        }

                        Text {
                            id: titleText

                            Layout.fillWidth: true
                            Layout.minimumWidth: contentWidth
                            Layout.minimumHeight: contentHeight

                            text: model.applicationName
                            elide: Text.ElideRight
                            font.pixelSize: JDisplay.sp(11)

                            color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba(247 / 255,247 / 255, 247 / 255, 0.55) : Qt.rgba(0, 0, 0, 0.6)
                            font.weight: Font.Medium
                        }

                        Text {
                            id: timeText

                            property var modelCreatedTime
                            Layout.alignment: Qt.AlignRight
                            Layout.fillWidth: false

                            Layout.minimumWidth: contentWidth
                            Layout.minimumHeight: contentHeight

                            visible: !isEnterMouse
                            font.pixelSize: JDisplay.sp(10)
                            color: plasmoid.nativeInterface.isDarkColorScheme ?  Qt.rgba(247 / 255, 247 / 255 ,247 / 255 ,0.55): Qt.rgba(0,0,0,0.60)

                            Component.onCompleted: {
                                timeText.modelCreatedTime = model.created
                                text = formatTimeString(modelCreatedTime)
                            }

                            Connections {
                                target: notificationList

                                onTimeFormatChanged: {
                                    timeText.text = notificationList.formatTimeString(timeText.modelCreatedTime)
                                }
                                onUpdataTime: {
                                    timeText.text = notificationList.formatTimeString(timeText.modelCreatedTime)
                                }
                            }
                        }
                    }

                    Item {
                        id: summaryItem

                        width: parent.width - parent.padding * 2
                        height: summaryText.implicitHeight

                        Text {
                            id: summaryText

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: model.summary
                            font.pixelSize: JDisplay.sp(11)
                            color: plasmoid.nativeInterface.isDarkColorScheme ? "#f7f7f7": "#000000"
                            font.weight: Font.Bold
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: bodyItem

                        width: parent.width - parent.padding * 2
                        height: bodyText.implicitHeight
                        Text {
                            id: bodyText

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            maximumLineCount: 4

                            text: model.body
                            font.pixelSize: JDisplay.sp(11)
                            color: plasmoid.nativeInterface.isDarkColorScheme ? "#f7f7f7" : "#000000"
                            wrapMode: Text.WrapAnywhere
                            elide: Text.ElideRight
                            font.weight: Font.Medium
                        }
                    }
                }

                MouseArea {
                    id: dismissSwipe

                    anchors.fill: parent

                    drag.axis: Drag.XAxis
                    drag.target: rectangleBg
                    drag.minimumX: -parent.width
                    drag.maximumX: JDisplay.dp(10)
                    drag.threshold: 3
                    hoverEnabled: true

                    onEntered: {
                        isEnterMouse = true
                    }

                    onPressed: {
                        isPressed = true
                        if (mouse.source !== Qt.MouseEventNotSynthesized) {
                            isEnterMouse = false
                        }
                    }

                    onExited: {
                        isPressed = false
                        isEnterMouse = false
                    }

                    onCanceled: {
                        isPressed = false
                        isEnterMouse = false
                    }

                    onReleased: {

                        isPressed = false
                        if (rectangleBg.x < -rectangleBg.width / 2) {
                            itemCloseAnim.restart()
                        } else if (rectangleBg.x < -rectangleBg.width / 4) {
                            openAnim.restart();
                            backOther(index)
                            isOpen = true
                        } else {
                           closeAnim.restart();
                           isOpen = false
                        }
                    }

                    onPositionChanged: {
                        backOther(index)
                        mouse.accepted = true
                    }

                    NumberAnimation {
                        id: openAnim

                        target: rectangleBg
                        property: "x"
                        to: -rectangleBg.width / 3
                        duration: nofifySlidingPanel.animationTime
                        easing.type: Easing.OutSine
                    }

                    NumberAnimation {
                        id: closeAnim

                        target: rectangleBg
                        property: "x"
                        to: JDisplay.dp(10)
                        duration: nofifySlidingPanel.animationTime
                        easing.type: Easing.OutSine
                    }
                }

                Image {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: JDisplay.dp(10)
                    anchors.rightMargin: JDisplay.dp(10)
                    width: JDisplay.dp(22)
                    height: JDisplay.dp(22)

                    visible: isEnterMouse
                    source: "file:///usr/share/icons/jing/close.svg"

                    MouseArea {
                        id: closeNotification

                        anchors.centerIn: parent
                        width: parent.width * 3
                        height: parent.height * 3
                        hoverEnabled: true

                        onClicked: {
                            itemCloseAnim.restart()
                            mouse.accepted = true
                        }
                        onPressed: {
                            preventStealing = true
                        }
                        onPositionChanged: {
                            mouse.accepted = true
                        }
                        onEntered: {
                            isEnterMouse = true
                        }
                        onExited: {
                            isEnterMouse = false
                        }
                    }
                }

                ParallelAnimation {
                    id: itemCloseAnim

                    PropertyAnimation {
                        target: rectangleBg
                        duration: nofifySlidingPanel.animationTime
                        easing.type: Easing.OutSine
                        properties: "x"
                        from: rectangleBg.x
                        to: -rectangleBg.width
                    }
                    onFinished: {
                        hotkeysManager.closeNotificationId(model.notificationId);
                        notifyModel.close(model.notificationId);
                    }
                }
            }
        }
    }
}
