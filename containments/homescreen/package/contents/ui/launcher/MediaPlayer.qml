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
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.private.volume 0.1

Rectangle {
//    anchors.fill: parent
//    color: root.isDarkScheme? Qt.rgba(142,142,147,0.2): "#f0f0f0"
//    radius: height / 9

    property bool toggled: model.enabled
    property int imageWidth: JDisplay.dp(72)
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
     }
     
    Row {
        id: mediaplayDelegateRoot
        anchors{
//         horizontalCenter: parent.horizontalCenter
         centerIn: parent
//         top: parent.top
//         topMargin: JDisplay.dp(11)
        }
        width: parent.width - JDisplay.dp(22)
        height: imageWidth
        spacing: JDisplay.dp(9)

        Image {
            id: albumImage
            width: imageWidth
            height: width
            source: mediaControl.albumArt? mediaControl.albumArt:"file:///usr/share/icons/jing/album.png"
            antialiasing:true
        }
        Column{
            width: parent.width - albumImage.width - JDisplay.dp(9)
            height: imageWidth
            spacing: JDisplay.dp(8)
            Item {
                width: parent.width
                height: artistText.text !== "" ? JDisplay.dp(17) : JDisplay.dp(30)
                Text {
                    id: titleText
                    anchors.fill: parent
                    anchors.leftMargin: JDisplay.dp(2)
                    anchors.rightMargin: JDisplay.dp(10)

                    horizontalAlignment : Text.AlignLeft
                    verticalAlignment : Text.AlignBottom

                    font.pixelSize: JDisplay.sp(14)
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: mediaControl.track? mediaControl.track : i18nd("plasma-phone-components", "No audio")
                    opacity: 0.8
                    color: "white"
                }
            }

            Item {
                width: parent.width
                height: artistText.text !== "" ? artistText.contentHeight + JDisplay.dp(4) : 0
//                color: "#40ff0000"
                Text {
                    id: artistText

                    anchors.fill: parent
                    anchors.leftMargin: JDisplay.dp(2)
                    anchors.rightMargin: JDisplay.dp(10)

                    horizontalAlignment : Text.AlignLeft
                    verticalAlignment : Text.AlignTop

                    font.pixelSize: JDisplay.sp(10)
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: mediaControl.artist //? mediaControl.artist : i18nd("plasma-phone-components", "No audio playback")
                    opacity: 0.8
                    color: "white"
                }
            }

            Item {
                id: buttonItem
                width: parent.width- JDisplay.dp(20)
                height: JDisplay.dp(25)
                Row {
                    anchors.fill: parent
                    Item {
                        width: buttonItem.width / 3
                        height: buttonItem.height
//                         color: "#40ff0000"

                        Image {
                            id:previousImage
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: buttonItem.width / 5;
                            height: width
                            source: "file:///usr/share/icons/jing/jing/settings/previous.svg"
                            antialiasing:true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: previousImage
                            source: previousImage
                            color: "white"
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
                            anchors.left: parent.left
                            width: buttonItem.width / 4;
                            height: width
                            //source: mediaManager.playState === 0 ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                            source: mediaControl.state != "playing" ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                            antialiasing:true
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: playImage
                            source: playImage
                            color: "white"
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
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: buttonItem.width / 5;
                            height: width
                            source: "file:///usr/share/icons/jing/jing/settings/next.svg"
                            antialiasing:true
                            visible: false
                        }

                        ColorOverlay {
                            anchors.fill: nextImage
                            source: nextImage
                            color: "white"
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
}



