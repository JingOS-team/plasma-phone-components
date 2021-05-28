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
 
import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.phone.jingos.mediamanager 1.0
import QtGraphicalEffects 1.6

Rectangle {
    anchors.fill: parent
    color: "#f0f0f0"
    radius: height / 9

    property bool toggled: model.enabled
    signal closeRequested
    signal panelClosed

    MediaManager {
        id: mediaManager

        onMediaInfoChanged: {
            albumImage.source = imagePath
            titleText.text = title
            artistText.text = artist
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
                source: "file:///usr/share/icons/jing/album.png"
                antialiasing:true

                onStatusChanged: {
                    if (albumImage.status == Image.Null || albumImage.status == Image.Error) {
                        albumImage.source = "file:///usr/share/icons/jing/album.png"
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 6

            Text {
                id: titleText
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter

                font.pixelSize: parent.height / 3
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: i18nd("plasma-phone-components", "No audio playback")
                opacity: 0.8
            } 
        }

        Item {
            Layout.preferredWidth: mediaplayDelegateRoot.width
            Layout.preferredHeight: mediaplayDelegateRoot.height / 7

            Text {
                id: artistText

                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignTop

                font.pixelSize: parent.height / 3.5
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: i18nd("plasma-phone-components", "No audio playback")
                opacity: 0.8
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
                        color: "#000000"
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
                            if(!mediaManager.dbusConnect)
                                return;
                            previousStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            previousStateRectangle.opacity = 0
                        }

                        onPressed: {
                            if(!mediaManager.dbusConnect)
                                return;
                            previousStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            previousStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            previousStateRectangle.opacity = 0
                        }

                        onClicked: {
                            if(!mediaManager.dbusConnect)
                                return;
                            mediaManager.previous();
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
                        source: mediaManager.playState === 0 ? "file:///usr/share/icons/jing/jing/settings/play.svg" : "file:///usr/share/icons/jing/jing/settings/stop.svg"
                        antialiasing:true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: playImage
                        source: playImage
                        color: "#000000"
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
                            if(!mediaManager.dbusConnect)
                                return;
                            playStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            playStateRectangle.opacity = 0
                        }

                        onPressed: {
                            if(!mediaManager.dbusConnect)
                                return;
                            playStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            playStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            playStateRectangle.opacity = 0
                        }

                        onClicked: {
                            if(!mediaManager.dbusConnect)
                                return;
                            mediaManager.playAndPause();
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
                        color: "#000000"
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
                            if(!mediaManager.dbusConnect)
                                return;
                            nextStateRectangle.opacity = 0.2
                        }

                        onExited: {
                            nextStateRectangle.opacity = 0
                        }

                        onPressed: {
                            if(!mediaManager.dbusConnect)
                                return;
                            nextStateRectangle.opacity = 0.4
                        }
                        onReleased: {
                            nextStateRectangle.opacity = 0
                        }
                        onCanceled: {
                            nextStateRectangle.opacity = 0
                        }

                        onClicked: {
                            if(!mediaManager.dbusConnect)
                                return;
                            mediaManager.next();
                        }
                    }
                }
            }
        }
    }
}



