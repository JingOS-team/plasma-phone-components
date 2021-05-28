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

import org.kde.kirigami 2.15
import "jingos" as Jingos

Item {
    id: root

    signal closeRequested
    signal closed

    property bool screenshotRequested: false
    property bool deviceConnected : false 

    property real listViewContentHeight: listView.contentHeight
    property real listViewCount: listView.count

    signal cleanAll();
    signal backAll();
    signal backOther(int closeIndex);

    function requestScreenshot() {
        root.closeRequested();
    }

    Item {
        id: headerItem
        anchors.top: parent.top
        anchors.left: parent.left
        width: listView.width
        height: 60

        Text {
            id: notificationTitle

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 19
            text: i18nd("plasma-phone-components", "Notification Center")
            font.pixelSize: 20
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        JIconButton {
            id: closeAllButton

            width:  appWidthRatio * 54 
            height: appWidthRatio * 54
            anchors.right: parent.right
            anchors.rightMargin: appWidthRatio * 40
            anchors.verticalCenter: notificationTitle.verticalCenter
            visible: listView.count !== 0
            
            source: "file:///usr/share/icons/jing/cleaningAll.svg"
            backgroundColor : "transparent"
            
            onClicked: {
                cleanAll()
                cleanTimer.restart()
            }
        }

        Timer {
            id: cleanTimer
            running: false
            repeat: false

            interval: 150
            onTriggered :{
                notifyModel.clearExpired()
                root.requestScreenshot()
            }
        }
    }

    ListView {
        id: listView

        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: PlasmaCore.Units.smallSpacing * 3
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4
        clip: true
        model: notifyModel
        highlightFollowsCurrentItem: true

        Text {
            anchors.centerIn: listView
            text: i18nd("plasma-phone-components", "No Notifications")
            font.pixelSize: 14
            color: Qt.rgba(0, 0, 0, 0.5)
            visible : listView.count > 0 ? false : true
        }
        
        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400 }
        }

        removeDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400 }
        }

        delegate: Item {

            id: itemHandle

            property bool isOpen: false

            width: listView.width
            height: rectangleBg.height + 3

            property bool isEnterMouse: false
            
            Connections {
                target: root

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

                height: column.implicitHeight + 10
                width: parent.width - 20
                x: 10
                color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.4)
                radius: 8
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                    mouse.accepted = true
                    // itemCloseAnim.restart()
                    }
                }
                RowLayout {
                    width: parent.width / 3
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    Label {
                        // Layout.alignment: Qt.AlignRight
                        Layout.fillWidth: true
                        text: i18nd("plasma-phone-components", "Delete")
                        color: Qt.rgba(0, 0, 0, 0.3)
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.Bold
                        MouseArea {
                            id: deleteBgMouse
                            anchors.fill: parent
                            enabled: isOpen
                            onClicked: {
                                mouse.accepted = true
                                itemCloseAnim.restart()
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: rectangleBg
                anchors.top: parent.top

                height: column.implicitHeight + 10
                width: parent.width - 20
                x: 10
                color: Qt.rgba(248 / 255, 248 / 255, 248 / 255, 1)
                clip: true

                radius: 8

                Column {
                    id: column
                    spacing: 3

                    Item {
                        width: rectangleBg.width
                        height:  titleText.implicitHeight > iconItem.height ? titleText.implicitHeight + 10 : iconItem.height + 10

                        PlasmaCore.IconItem {
                            id: iconItem
                            anchors.top:parent.top
                            anchors.topMargin: 10
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            height: 25
                            width: 25

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
                            anchors.leftMargin: 6
                            anchors.right: timeText.left
                            anchors.rightMargin: 6
                            text: model.applicationName
                            elide: Text.ElideRight
                            font.pixelSize: 13
                            opacity: 0.6
                            color: "#000000"
                        }

                        Text {
                            id: timeText
                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            visible: !isEnterMouse
                            font.pixelSize: 11
                            opacity: 0.6
                            color: "#000000"

                            Component.onCompleted:  {
                                timeText.text = getLocalTimeString(model.created)
                                // Qt.formatDateTime(model.created, "hh:mm:ss")
                            }
                        }

                        Image {
                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            visible: isEnterMouse
                            width: 22
                            height: 22
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
                        width: rectangleBg.width
                        height: summaryText.implicitHeight

                        Text {
                            id: summaryText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            text: model.summary
                            font.pixelSize: 14
                            color: "#000000"            
                            font.bold: true
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: bodyItem
                        width: rectangleBg.width
                        height: bodyText.implicitHeight
                        Text {
                            id: bodyText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            text: model.body
                            font.pixelSize: 14
                            color: "#000000"
                            wrapMode: Text.WrapAnywhere
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: dismissSwipe

                    anchors.fill: parent
                    drag.axis: Drag.XAxis
                    drag.target: rectangleBg
                    drag.minimumX: -parent.width
                    drag.maximumX: 10
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
                    
                    NumberAnimation {
                        id: openAnim
                        target: rectangleBg
                        property: "x"
                        to: -rectangleBg.width / 3
                        duration: 300
                        easing.type: "OutBack"
                    }
                    NumberAnimation {
                        id: closeAnim
                        target: rectangleBg
                        property: "x"
                        to: 10
                        duration: 300
                        easing.type: "OutBack"
                    }
                }

                ParallelAnimation {
                    id: itemCloseAnim

                    PropertyAnimation {
                        target: rectangleBg
                        duration: 150
                        easing.type: Easing.InOutQuad
                        properties: "x"
                        from: rectangleBg.x
                        to: -rectangleBg.width
                    }
                    PropertyAnimation {
                         target: deleteBg
                         duration: 150
                         easing.type: Easing.InOutQuad
                         properties: "x"
                         from: deleteBg.x
                         to: -deleteBg.width
                     }
                    onFinished: {
                        notifyModel.close(model.notificationId);
                    }
                }
            }
        }
    }

    DC.TimeZoneFilterProxy{
        id:timezoneProxy
    }

    function getLocalTimeString(timeFormat){
        var timeStr = String(timeFormat);
        var isChinaLocal = (timeStr.indexOf("GMT+0800") != -1)
        timeStr = Qt.formatTime(timeFormat, timezoneProxy.isSystem24HourFormat ? "h:mm:ss" : "h:mm:ss AP");
        if(isChinaLocal){
            if(timeStr.search("AM") != -1)
                timeStr = timeStr.replace("AM","上午");
            if(timeStr.search("PM") != -1)
                timeStr = timeStr.replace("PM","下午");
        } else {
            if(timeStr.search("上午") != -1)
                timeStr = timeStr.replace("上午","AM");
            if(timeStr.search("下午") != -1)
                timeStr = timeStr.replace("下午","PM");
        }

        return timeStr;
    }
}
