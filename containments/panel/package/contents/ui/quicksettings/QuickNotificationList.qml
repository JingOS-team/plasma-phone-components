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
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt

import org.kde.notificationmanager 1.1 as Notifications
import org.kde.kquickcontrolsaddons 2.0 as KQCAddons

Item {
    id: root

    signal closeRequested
    signal closed

    property bool screenshotRequested: false
    property bool deviceConnected : false 

    function requestScreenshot() {
        root.closeRequested();
    }

    Notifications.WatchedNotificationsModel {
        id: notifyModel
    }

    Item {
        id: headerItem
        anchors.top: parent.top
        anchors.left: parent.left
        width: listView.width
        height: 100

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 30
            text: "Notification Center"
            font.pointSize: theme.defaultFont.pointSize + 11
            color: "#000000"
        }
    }

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: PlasmaCore.Units.smallSpacing * 4
        anchors.top: headerItem.bottom

        spacing: 8
        clip: true
        model: notifyModel

        Text {
            anchors.centerIn: listView
            text: "No Notifications"
            font.pointSize: theme.defaultFont.pointSize
            color: "#000000"
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
            width: listView.width
            height: rectangleBg.height + 4
            clip: true

            Rectangle {
                id: rectangleBg
                anchors.top: parent.top

                height: column.implicitHeight
                width: parent.width - 24
                x: 12
                color: "#f0f0f0"
                clip: true

                radius: 20
                
                Column {
                    id: column
                    spacing: 8

                    Item {
                        width: rectangleBg.width
                        height:  titleText.implicitHeight > iconItem.height ? titleText.implicitHeight + 20 : iconItem.height + 20

                        PlasmaCore.IconItem {
                            id: iconItem
                            anchors.top:parent.top
                            anchors.topMargin: 20
                            anchors.left: parent.left
                            anchors.leftMargin: 20

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
                            anchors.leftMargin: 12
                            anchors.right: timeText.left
                            anchors.rightMargin: 12
                            text: model.applicationName
                            elide: Text.ElideRight
                            font.pointSize: 20
                            opacity: 0.6
                            color: "#000000"
                        }

                        Text {
                            id: timeText
                            anchors.verticalCenter: iconItem.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            
                            font.pointSize: 17
                            opacity: 0.6
                            color: "#000000"

                            Component.onCompleted:  {
                                timeText.text = Qt.formatDateTime(model.created, "hh:mm:ss")
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
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            text: model.summary
                            font.pointSize: 22
                            color: "#000000"            
                            font.bold: true
                            wrapMode:Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: bodyItem
                        width: rectangleBg.width
                        height: bodyText.implicitHeight + 22

                        Text {
                            id: bodyText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            text: model.body
                            font.pointSize: 21
                            color: "#000000"
                            wrapMode:Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }
                }
                
                MouseArea {
                    id: dismissSwipe
                    anchors.fill: parent
                    drag.axis: Drag.XAxis
                    drag.target: rectangleBg

                    onReleased: {
                        if (Math.abs(rectangleBg.x) > width / 4) {
                            notifyModel.close(model.notificationId);
                        } else {
                            slideAnim.restart();
                        }
                    }

                    NumberAnimation {
                        id: slideAnim
                        target: rectangleBg
                        property: "x"
                        to: 12
                        duration: 300
                    }                       
                }
            }
        }
    }
}
