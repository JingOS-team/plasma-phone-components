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
import org.kde.phone.jingos.mediamanager 1.0
import QtGraphicalEffects 1.6
import jingos.display 1.0
import org.kde.plasma.private.volume 0.1

Rectangle {
    anchors.fill: parent
    color: root.isDarkScheme? Qt.rgba(142 / 255,142 / 255,147 / 255,0.2): Qt.rgba(248 / 255,248 / 255,248 / 255,0.7)
    radius: height / 9

    property bool toggled: model.enabled
    signal closeRequested
    signal panelClosed

    /*
    MediaManager {
        id: mediaManager

        onMediaInfoChanged: {
            albumImage.source = imagePath
            titleText.text = title
            artistText.text = artist
        }
    }
    */
    MediaControl {
        id: mediaControl
    }

    GlobalActionCollection {
        name: "kmix"
        displayName: "kmix"//root.displayName

        GlobalAction {
            objectName: "previous_music"
            text: i18nd("plasma-phone-components", "Previous Music")
            shortcut: Qt.MetaModifier + Qt.Key_Left
            onTriggered: mediaControl.action_previous();
        }
        GlobalAction {
            objectName: "next_music"
            text: i18nd("plasma-phone-components", "Next Music")
            shortcut: Qt.MetaModifier + Qt.Key_Right
            onTriggered: mediaControl.action_next();
        }
        GlobalAction {
            objectName: "previous music"
            text: i18nd("plasma-phone-components", "Previous Music")
            shortcut: Qt.Key_MediaPrevious
            onTriggered: mediaControl.action_previous();
        }
        GlobalAction {
            objectName: "next music"
            text: i18nd("plasma-phone-components", "Next Music")
            shortcut: Qt.Key_MediaNext
            onTriggered: mediaControl.action_next();
        }
        GlobalAction {
            objectName: "switch music status"
            text: i18nd("plasma-phone-components", "switch Music Status")
            shortcut: Qt.Key_MediaTogglePlayPause
            onTriggered: mediaControl.action_playPause();
        }
     }

    ColumnLayout {
        id: mediaplayDelegateRoot
        anchors.fill:parent

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 16
        }

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 4

            Image {
                id: albumImage
                anchors.centerIn: parent
                width: height
                height: parent.height
                source: mediaControl.albumArt? mediaControl.albumArt:"file:///usr/share/icons/jing/album.png"
                antialiasing:true

//                onStatusChanged: {
//                    if (albumImage.status == Image.Null || albumImage.status == Image.Error) {
//                        albumImage.source = "file:///usr/share/icons/jing/album.png"
//                    }
//                }
            }
        }

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 6

            Text {
                id: titleText
                anchors.fill: parent
                anchors.leftMargin: JDisplay.dp(10)
                anchors.rightMargin: JDisplay.dp(10)

                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter

                font.pixelSize: JDisplay.sp(14)
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: mediaControl.track? mediaControl.track : i18nd("plasma-phone-components", "No audio")
                opacity: 0.8
                color: root.isDarkScheme? "white":"#000000"
            }
        }

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 7

            Text {
                id: artistText

                anchors.fill: parent
                anchors.leftMargin: JDisplay.dp(10)
                anchors.rightMargin: JDisplay.dp(10)

                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignTop

                font.pixelSize: JDisplay.sp(10)
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: mediaControl.artist//i18nd("plasma-phone-components", "No audio playback")
                opacity: 0.8
                color: root.isDarkScheme? "white":"#000000"
            }
        }

        Item {
            id: buttonItem
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.preferredWidth: mediaplayDelegateRoot.width

            Row {
                Item {
                    width: buttonItem.width / 3
                    height: buttonItem.height

                    Image {
                        id:previousImage
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: buttonItem.width / 6;
                        height: width
                        source: "file:///usr/share/icons/jing/jing/settings/previous.svg"
                        antialiasing:true
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: previousImage
                        source: previousImage
                        color: root.isDarkScheme? "white":"#000000"
                        opacity: 0.8
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
                            //if(!mediaManager.dbusConnect)
                            //    return;
                            previousStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            previousStateRectangle.opacity = 0
                        }

                        onPressed: {
                          //  if(!mediaManager.dbusConnect)
                          //      return;
                            previousStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            previousStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            previousStateRectangle.opacity = 0
                        }

                        onClicked: {
                          //  if(!mediaManager.dbusConnect)
                          //      return;
                          //  mediaManager.previous();
                            mediaControl.action_previous();
                        }
                    }
                }

                Item {
                    width: buttonItem.width / 3
                    height: buttonItem.height

                    Image {
                        id: playImage
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: buttonItem.width / 6;
                        height: width
                        //source: mediaManager.playState === 0 ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                        source: mediaControl.state != "playing" ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                        antialiasing:true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: playImage
                        source: playImage
                        color: root.isDarkScheme? "white":"#000000"
                        opacity: 0.8
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
                         //   if(!mediaManager.dbusConnect)
                         //       return;
                            playStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            playStateRectangle.opacity = 0
                        }

                        onPressed: {
                         //   if(!mediaManager.dbusConnect)
                         //       return;
                            playStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            playStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            playStateRectangle.opacity = 0
                        }

                        onClicked: {
                        //    if(!mediaManager.dbusConnect)
                        //        return;
                        //    mediaManager.playAndPause();
                            mediaControl.action_playPause();
                        }
                    }
                }

                Item {
                    width: buttonItem.width / 3
                    height: buttonItem.height

                    Image {
                        id: nextImage
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: buttonItem.width / 6;
                        height: width
                        source: "file:///usr/share/icons/jing/jing/settings/next.svg"
                        antialiasing:true
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: nextImage
                        source: nextImage
                        color: root.isDarkScheme? "white":"#000000"
                        opacity: 0.8
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
                         //   if(!mediaManager.dbusConnect)
                         //       return;
                            nextStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            nextStateRectangle.opacity = 0
                        }

                        onPressed: {
                         //   if(!mediaManager.dbusConnect)
                         //       return;
                            nextStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            nextStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            nextStateRectangle.opacity = 0
                        }

                        onClicked: {
                         //   if(!mediaManager.dbusConnect)
                         //       return;
                         //   mediaManager.next();
                            mediaControl.action_next();
                        }
                    }
                }
            }
        }
    }
}



