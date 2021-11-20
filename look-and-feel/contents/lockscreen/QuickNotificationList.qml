/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.14
import QtQml 2.12
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt

import org.kde.notificationmanager 1.1 as Notifications
import org.kde.kquickcontrolsaddons 2.0 as KQCAddons
import org.kde.plasma.private.digitalclock 1.0 as DC

import QtQuick.Controls 2.14 as Controls
import QtQuick.Window 2.14
import jingos.display 1.0
import org.kde.kirigami 2.15

Item {
    id: notificationList

    signal closeRequested
    signal closed
    signal updataTime

    property bool screenshotRequested: false
    property bool deviceConnected : false
    property real listViewContentHeight: listView.contentHeight
    property real listViewCount: listView.count
    property bool keypadisvisible : false
    property real notificationListY: 0
    property real distanceY: 0
    property bool notificationListIsCanMove: true
    property real hearderItemHeight: JDisplay.dp(82)
    property real pullDistance: JDisplay.dp(0)
    readonly property real notificationListInitPos: JDisplay.dp(40)

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

    //    onWindowChanged: {
    //    // console.log("JDialog   window changed to " + window)
    //     if(window){
    //         notificationList.windowContentItem = window.contentItem;
    //     } else {
    //         notificationList.windowContentItem = null;
    //     }
    //}

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    property bool timeFormat : timezoneProxy.isSystem24HourFormat
//    visible : !keypadisvisible ? true : false

    signal cleanAll();
    signal backAll();
    signal backOther(int closeIndex);

    function closeAllButtonReset() {
        closeAllButton.reset();
    }

    function requestScreenshot() {
        notificationList.closeRequested();
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

    MouseArea {
        anchors.fill:parent
        hoverEnabled: true
        onExited: {
            closeAllButton.reset();
        }
    }

    Item{
        id: headerItem
//        visible : listView.count > 0 && !keypadisvisible ? true : false
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: JDisplay.dp(9)
        width: parent.width
        height: hearderItemHeight

        Text {
            id: notificationTitle
            anchors.top: parent.top
            anchors.topMargin: JDisplay.dp(40)
            anchors.left: parent.left
            width:parent.width
            height: JDisplay.dp(24)
            text: i18nd("plasma-phone-components", "Notification Center")
            font.pixelSize: JDisplay.sp(20)
            color: Qt.rgba(255 / 255,255 / 255,255 / 255,1)//!isDarkTheme ? Qt.rgba(255 / 255,255 / 255,255 / 255,1) : Qt.rgba(0, 0, 0, 0.7)
        }

        JSwitchButton {
            id: closeAllButton
            width:  JDisplay.dp(31)
            height: JDisplay.dp(31)
            anchors.right: parent.right
            anchors.rightMargin: JDisplay.dp(10)
            anchors.verticalCenter: notificationTitle.verticalCenter
            visible: listView.count !== 0
            source: "file:///usr/share/icons/jing/cleaningAll.svg"
            text: i18nd("plasma-phone-components", "Clear")
            backgroundColor : "transparent"
            color: Qt.rgba(255 / 255,255 / 255,255 / 255,1)
            fontColor: Qt.rgba(255 / 255,255 / 255,255 / 255,1)
            radius: JDisplay.dp(9)
            onClicked: {
                cleanAll()
                cleanTimer.restart()
            }
            onReleased:{
                cleanAll()
                cleanTimer.restart()
            }
        }
    }

    Timer {
        id: cleanTimer

        running: false
        repeat: false
        interval: 150
        onTriggered: {
            notifyModel.clearExpired()
            notificationList.requestScreenshot()
            closeAllButton.reset();
        }
    }

    ListView {
        id: listView
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: JDisplay.dp(4)
        clip: true
        model: notifyModel
        highlightFollowsCurrentItem: true

        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400 }
        }

        removeDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400 }
        }

        onContentYChanged: {
            if(listView.count <=0 )
            {
                return
            }
            if(!notificationListIsCanMove)
            {
                return
            }
            if(contentY > 0)
            {
                return
            }
            if(distanceY < pullDistance /*- notificationListInitPos*/)
            {
                notificationList.y  = notificationList.y - contentY
                distanceY = notificationList.y - notificationListY
            }
            else{
                notificationListIsCanMove = false
            }
        }

        onMovementStarted:{
            notificationListY = notificationList.y
        }

        onMovementEnded: {
            if(!notificationListIsCanMove)
            {
                return
            }
            if(distanceY >= pullDistance / 2 /*- notificationListInitPos*/){
                notificationList.y = notificationListY + pullDistance /*- notificationListInitPos*/
                notificationListIsCanMove = false
            }
            else{
                notificationList.y = notificationListY
            }
        }

        delegate: Item {
            id: itemHandle
            property bool isOpen: false
            width: listView.width
            height: background.height + JDisplay.dp(3)
            anchors.left: parent.left
            property bool isEnterMouse: false

            // JBlurBackground{
            //     id: bkground
            //     anchors.fill: parent
            //     backgroundColor:JTheme.floatBackground
            //     radius: 6
            //     showBgCover: false
            //     sourceItem:  notificationList.windowContentItem
            // }
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
                height: background.height//column.implicitHeight + 10
                // width: parent.width - 20
                width: -background.x
                clip: true
                color: isDarkTheme ? Qt.rgba( 142 / 255, 142 / 255, 147 / 255, 0.1) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.4)
                radius: JDisplay.dp(8)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = true
                        // itemCloseAnim.restart()
                    }
                }

                RowLayout {
                    width: parent.width
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    visible:true
                    Label {
                        // Layout.alignment: Qt.AlignRight
                        Layout.fillWidth: true
                        text: i18nd("plasma-phone-components", "Delete")
                        color: isDarkTheme ? Qt.rgba( 247 / 255, 247 / 255, 247 / 255, 0.55) : Qt.rgba(0, 0, 0, 0.3)

                        font.pixelSize: JDisplay.sp(14)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.Bold
                        clip: true
                    }

                    MouseArea {
                        id: deleteBgMouse

                        // width: parent.width
                        // height: parent.height * 2
                        // anchors.centerIn: parent

                        anchors.fill: parent

                        enabled: isOpen
                        onClicked: {
                            mouse.accepted = true
                            itemCloseAnim.restart()
                        }
                    }
                }
            }

            Rectangle{
                id: background
                anchors.top: parent.top
                height: column.implicitHeight + JDisplay.dp(20)//JDisplay.dp(96)
                width: parent.width //- JDisplay.dp(20)
                color: isDarkTheme ? Qt.rgba(38 / 255,38 / 255,38 / 255,1) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1)
                radius: JDisplay.dp(9)
            }

            Rectangle {
                id: rectangleBg
                anchors.fill: background
                visible: true
                color: isDarkTheme ? Qt.rgba( 142 / 255, 142 / 255, 147 / 255, 0.1) : Qt.rgba(248 / 255, 248 / 255, 248 / 255, 0.7)
                clip: true
                radius: JDisplay.dp(9)

                Column {
                    id: column
                    spacing: 3
                    Item {
                        width: background.width
                        height:  titleText.implicitHeight > iconItem.height ? titleText.implicitHeight + JDisplay.dp(10) : iconItem.height + JDisplay.dp(10)

                        PlasmaCore.IconItem {
                            id: iconItem

                            anchors.top:parent.top
                            anchors.topMargin: JDisplay.dp(10)
                            anchors.left: parent.left
                            anchors.leftMargin: JDisplay.dp(10)
                            height: JDisplay.dp(25)
                            width: JDisplay.dp(25)
                            readonly property bool active: valid && source != model.applicationIconSource
                            usesPlasmaTheme: false
                            smooth: true
                            visible: active

                            source: {
                                var icon = model.iconName;
                                if (typeof icon !== "string") { // displayed by QImageItem below
                                    return "";
                                }
                                if (icon === "dialog-information") {
                                    return "";
                                }
                                return icon;
                            }
                        }

                        KQCAddons.QImageItem {
                            id: imageItem

                            readonly property bool active: !null && nativeWidth > 0
                            anchors.fill: iconItem
                            smooth: true
                            fillMode: KQCAddons.QImageItem.PreserveAspectFit
                            visible: active
                            image: typeof model.iconName === "object" ? model.iconName : undefined
                        }

                        Text {
                            id: titleText

                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.left: iconItem.right
                            anchors.leftMargin: JDisplay.dp(6)
                            anchors.right: timeText.left
                            anchors.rightMargin: JDisplay.dp(6)

                            text: model.applicationName
                            elide: Text.ElideRight
                            font.pixelSize: JDisplay.sp(13)
                            opacity: 0.6
                            color: isDarkTheme ? Qt.rgba(247 / 255,247 / 255,247 / 255,0.55) : Qt.rgba(0 / 255,0 / 255,0 / 255,0.6)
                        }

                        Text {
                            id: timeText

                            property var modelCreatedTime
                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10

                            visible: !isEnterMouse
                            font.pixelSize: JDisplay.sp(11)
                            opacity: 0.6
                            color: isDarkTheme ? Qt.rgba(247 / 255,247 / 255,247 / 255,0.55) : Qt.rgba(0 / 255,0 / 255,0 / 255,0.6)

                            Component.onCompleted:  {
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
                        Image {
                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: JDisplay.dp(10)
                            width: JDisplay.dp(22)
                            height: JDisplay.dp(22)

                            visible: isEnterMouse

                            source: "file:///usr/share/icons/jing/close.svg"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    itemCloseAnim.restart()
                                    mouse.accepted = true
                                }
                            }
                        }
                    }

                    Item {
                        id: summaryItem

                        width: background.width
                        height: summaryText.implicitHeight
                        Text {
                            id: summaryText

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: JDisplay.dp(10)
                            anchors.right: parent.right
                            anchors.rightMargin: JDisplay.dp(10)

                            text: model.summary
                            font.pixelSize: JDisplay.sp(14)
                            color: isDarkTheme ? Qt.rgba(247 / 255,247 / 255,247 / 255,1) : Qt.rgba(0 / 255,0 / 255,0 / 255,1)
                            font.bold: true
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: bodyItem

                        width: background.width
                        height: bodyText.implicitHeight
                        Text {
                            id: bodyText

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: JDisplay.dp(10)
                            anchors.right: parent.right
                            anchors.rightMargin: JDisplay.dp(10)

                            text: model.body
                            font.pixelSize: JDisplay.sp(14)
                            color: isDarkTheme ? Qt.rgba(247 / 255,247 / 255,247 / 255,1) : Qt.rgba(0 / 255,0 / 255,0 / 255,1)
                            wrapMode: Text.WrapAnywhere
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: dismissSwipe

                    anchors.fill: parent

                    drag.axis: Drag.XAxis
                    drag.target: background
                    drag.minimumX: -parent.width
                    drag.maximumX: JDisplay.dp(10)
                    propagateComposedEvents: true
                    hoverEnabled: true

                    onClicked: {
                        mouse.accepted = false
                    }

                    onEntered: {
                        isEnterMouse = true
                    }

                    onExited: {
                        isEnterMouse = false
                    }

                    onReleased: {
                        if (background.x < -background.width / 2) {
                            itemCloseAnim.restart()
                        } else if (background.x < -background.width / 4) {
                            openAnim.restart();
                            backOther(index)
                            isOpen = true
                        } else {
                           closeAnim.restart();
                           isOpen = false
                        }
                    }

                    NumberAnimation {
                        id: openAnim

                        target: background
                        property: "x"
                        to: -background.width / 3
                        duration: 300
                        easing.type: Easing.OutSine
                    }

                    NumberAnimation {
                        id: closeAnim

                        target: background
                        property: "x"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutSine
                    }
                }

                ParallelAnimation {
                    id: itemCloseAnim
                    PropertyAnimation {
                        target: background
                        duration: 150
                        easing.type: Easing.OutSine
                        properties: "x"
                        from: background.x
                        to: -background.width
                    }

                    onFinished: {
                        authenticator.closelockScreeNotificationId(model.notificationId);
                        notifyModel.close(model.notificationId);
                    }
                }
            }
        }
    }

    onListViewCountChanged: {
        console.log("mengdexiang-------------------------->" + listViewCount)
        if (listViewCount === 0) {
            requestScreenshot()
            cleanAll()
        }
    }
}
