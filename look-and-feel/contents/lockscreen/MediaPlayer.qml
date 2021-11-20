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
import QtGraphicalEffects 1.6
import jingos.display 1.0

Rectangle {
    signal closeRequested
    signal panelClosed
    property real mediaControlWidth: mediaplayDelegateRoot.width - albumArt.width - anchors.leftMargin
    property bool keypadisvisible: false

    visible: keypadisvisible ? false : (mediaControl.track ? true : false)
    //opacity: mediaControl.track ? notifications.opacity : 0
    MediaControl {
        id: mediaControl
    }

    RowLayout {
        id: mediaplayDelegateRoot
        anchors.fill:parent
        //spacing: 11
        Item{
            id: albumArt
            height: JDisplay.dp(70)
            width: JDisplay.dp(70)
            anchors.left: parent.left
            anchors.leftMargin: JDisplay.dp(13)
            Image {
                id: albumImage
                anchors.fill: parent
                //fillMode: Image.PreserveAspectFit
                source: mediaControl.albumArt? mediaControl.albumArt:"file:///usr/share/icons/jing/album.png"
                antialiasing:true
            }
        }

        ColumnLayout{
            anchors.left: albumArt.right
            anchors.top: albumArt.top
            anchors.topMargin: albumArt.topMargin
            anchors.bottom: albumArt.bottom
            anchors.bottomMargin: albumArt.bottomMargin
            anchors.right: parent.right
            anchors.rightMargin: JDisplay.dp(23)
            anchors.leftMargin: JDisplay.dp(11)
            spacing: 5
            Item{
                Layout.preferredWidth: mediaControlWidth - JDisplay.dp(11)//mediaplayDelegateRoot.width
                Layout.preferredHeight: mediaplayDelegateRoot.height / 6
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: titleText
                    anchors.fill: parent

                    horizontalAlignment : Text.AlignLeft//Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter

                    font.pixelSize: JDisplay.sp(14)
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: mediaControl.track? mediaControl.track : i18nd("plasma-phone-components", "No audio")
                    opacity: 1
                    color: isDarkTheme? Qt.rgba(247,247,247,1):rgba(0,0,0,1)
                }
            }

            Item{
                Layout.preferredWidth: mediaControlWidth - JDisplay.dp(11)//mediaplayDelegateRoot.width
                Layout.preferredHeight: mediaplayDelegateRoot.height / 7
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: artistText
                    anchors.fill: parent
                    horizontalAlignment : Text.AlignLeft//Text.AlignHCenter
                    verticalAlignment : Text.AlignTop
                    font.pixelSize: JDisplay.sp(10)
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: mediaControl.artist//i18nd("plasma-phone-components", "No audio playback")
                    opacity: 1
                    color: isDarkTheme? Qt.rgba(247 / 255,247 / 255,247 / 255,0.55):Qt.rgba(0,0,0,0.6)
                }
            }

            Item {
                id: buttonItem
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.preferredWidth: mediaControlWidth - JDisplay.dp(11)
                Layout.topMargin: JDisplay.dp(14)
                anchors.left: parent.left
                anchors.right: parent.right

                Row {
                    anchors.fill: parent
                    spacing: JDisplay.dp(30)
                    Item {
                        width: JDisplay.dp(22)//buttonItem.width / 3
                        height: JDisplay.dp(22)//buttonItem.height
                        Image {
                            id:previousImage
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: JDisplay.dp(22)//buttonItem.width / 6;
                            height: width
                            source: "file:///usr/share/icons/jing/jing/settings/previous.svg"
                            antialiasing:true
                            visible: false
                        }

                        ColorOverlay {
                            anchors.fill: previousImage
                            source: previousImage
                            color: isDarkTheme? Qt.rgba(247 / 255,247 / 255,247 / 255,1):Qt.rgba(60 / 255,60 / 255,67 / 255,1)
                            opacity: 1
                            antialiasing:true
                        }

                        Rectangle {
                            id: previousStateRectangle
                            anchors.fill: previousImage
                            color: "#000000"
                            radius: 15
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                previousStateRectangle.opacity = 0.2
                            }

                            onExited: {
                                previousStateRectangle.opacity = 0
                            }

                            onPressed: {
                                previousStateRectangle.opacity = 0.4
                            }
                            onReleased: {
                                previousStateRectangle.opacity = 0
                            }
                            onCanceled: {
                                previousStateRectangle.opacity = 0
                            }

                            onClicked: {
                                mediaControl.action_previous();
                            }
                        }
                    }

                    Item {
                        width: JDisplay.dp(21)//buttonItem.width / 3
                        height: JDisplay.dp(21)//buttonItem.height
                        Image {
                            id: playImage
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: JDisplay.dp(21)//buttonItem.width / 6;
                            height: width
                            source: mediaControl.state != "playing" ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                            antialiasing:true
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: playImage
                            source: playImage
                           color: isDarkTheme? Qt.rgba(247 / 255,247 / 255,247 / 255,1):Qt.rgba(60 / 255,60 / 255,67 / 255,1)
                            opacity: 1
                            antialiasing:true
                        }

                        Rectangle {
                            id: playStateRectangle
                            anchors.fill: playImage
                            color: "#000000"
                            radius: 15
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                playStateRectangle.opacity = 0.2
                            }

                            onExited: {
                                playStateRectangle.opacity = 0
                            }

                            onPressed: {
                                playStateRectangle.opacity = 0.4
                            }
                            onReleased: {
                                playStateRectangle.opacity = 0
                            }
                            onCanceled: {
                                playStateRectangle.opacity = 0
                            }

                            onClicked: {
                                mediaControl.action_playPause();
                            }
                        }
                    }

                    Item {
                        width: JDisplay.dp(22)//buttonItem.width / 3
                        height: JDisplay.dp(22)//buttonItem.height
                        Image {
                            id: nextImage
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: JDisplay.dp(22)//buttonItem.width / 6;
                            height: width
                            source: "file:///usr/share/icons/jing/jing/settings/next.svg"
                            antialiasing:true
                            visible: false
                        }

                        ColorOverlay {
                            anchors.fill: nextImage
                            source: nextImage
                            color: isDarkTheme? Qt.rgba(247 / 255,247 / 255,247 / 255,1):Qt.rgba(60 / 255,60 / 255,67 / 255,1)
                            opacity: 1
                            antialiasing:true
                        }

                        Rectangle {
                            id: nextStateRectangle
                            anchors.fill: nextImage
                            color: "#000000"
                            radius: 15
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                nextStateRectangle.opacity = 0.2
                            }

                            onExited: {
                                nextStateRectangle.opacity = 0
                            }

                            onPressed: {
                                nextStateRectangle.opacity = 0.4
                            }
                            onReleased: {
                                nextStateRectangle.opacity = 0
                            }
                            onCanceled: {
                                nextStateRectangle.opacity = 0
                            }

                            onClicked: {
                                mediaControl.action_next();
                            }
                        }
                    }
                }
            }
        }
    }
}
