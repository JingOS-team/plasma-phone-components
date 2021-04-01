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
import QtGraphicalEffects 1.6

Rectangle {
    anchors.fill: parent
    color: "#f0f0f0"
    radius: 30
    property bool toggled: model.enabled
    signal closeRequested
    signal panelCloseded

    Column {
        anchors.fill: parent

        Row {
            width: parent.width
            height: parent.height / 2

            Item {
                width: parent.width / 3
                height: parent.height

                Image {
                    id: imgIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10

                    visible: false
                    source: "file:///usr/share/icons/jing/jing/settings/" + model.icon + ".svg" 
                    antialiasing:true
                }

                ColorOverlay {
                    anchors.fill: imgIcon
                    source: imgIcon
                    color: "#000000"
                    opacity: 0.8
                    antialiasing:true
                }
            }

            Item {
                width: (parent.width / 3) * 2
                height: parent.height

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20

                    text: model.text
                    font.pointSize: parent.height / 5
                    color: "#000000"
                    opacity: 0.8
                }       
            }
        }

        Item {
            id: sliderItem
            
            width: parent.width
            height: parent.height / 2
            property double value: bgRectangle.currentValue / bgRectangle.moverRatio <= bgRectangle.maxWidth ? bgRectangle.currentValue / bgRectangle.moverRatio : bgRectangle.maxWidth 

            Rectangle {
                id: bgRectangle
                anchors.fill: parent
                anchors.leftMargin: parent.height / 5
                anchors.rightMargin: parent.height / 5
                anchors.topMargin: parent.top
                anchors.bottomMargin: parent.height / 3

                property int currentValue: model.icon == "bright" ? root.screenBrightness : volumeHandle.currentVolume
                property int maxnumValue: model.icon == "bright" ? root.maximumScreenBrightness : volumeHandle.maxVolumeValue    
                property double maxWidth: bgRectangle.width
                property int moverRatio:  bgRectangle.maxnumValue / bgRectangle.maxWidth
                property int radiusValue: 20

                color: "#d1d1d1"
                radius: bgRectangle.radiusValue
                clip: true

                MouseArea {
                    anchors.fill: parent
                    property double tmpValue: 0.0
                    
                    onPressed: {
                        tmpValue = mapToItem(bgRectangle, mouse.x, mouse.y).x

                        if(tmpValue === sliderItem.value)
                            return;

                        if(tmpValue <= 0) {
                            tmpValue = 0;
                            sliderItem.value = tmpValue
                        } else if( tmpValue <= bgRectangle.maxWidth ) {
                            sliderItem.value = tmpValue
                        } else {
                            tmpValue = bgRectangle.maxWidth;
                            sliderItem.value = tmpValue
                        }

                        if (model.toggleFunction) {
                            var tmpSliderValue = tmpValue * bgRectangle.moverRatio

                            if(tmpValue * bgRectangle.moverRatio <=  bgRectangle.maxnumValue) 
                                root[model.toggleFunction](tmpSliderValue);
                            else 
                                root[model.toggleFunction]( bgRectangle.maxnumValue);
                        }
                    }

                    onPositionChanged: {
                        tmpValue = mapToItem(bgRectangle, mouse.x, mouse.x).x

                        if(tmpValue === sliderItem.value)
                            return;

                        if(tmpValue <= 0) {
                            tmpValue = 0;
                            sliderItem.value = tmpValue
                        } else if( tmpValue <= bgRectangle.maxWidth ) {
                            sliderItem.value = tmpValue
                        } else {
                            tmpValue = bgRectangle.maxWidth;
                            sliderItem.value = tmpValue
                        }

                        if (model.toggleFunction) {
                            var tmpSliderValue = tmpValue * bgRectangle.moverRatio

                            if(tmpValue * bgRectangle.moverRatio <=  bgRectangle.maxnumValue) 
                                root[model.toggleFunction](tmpSliderValue);
                            else 
                                root[model.toggleFunction]( bgRectangle.maxnumValue);
                        }
                    }
                }

                Rectangle {
                    id: sliderHandel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: bgRectangle.left
                    radius: bgRectangle.radiusValue
                    width: sliderItem.value
                    height: sliderItem.value < 20 ?  bgRectangle.height - (bgRectangle.radiusValue  - sliderItem.value) : bgRectangle.height + 2
                    color: "#ffffff"
                }
            }
        }
    }
}



