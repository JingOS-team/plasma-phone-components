/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.6
import jingos.display 1.0

Rectangle {
    anchors.fill: parent
    color: root.isDarkScheme ? Qt.rgba(142 / 255,142 / 255,147 / 255,0.2): Qt.rgba(248 / 255,248 / 255,248 / 255,0.7)
    radius: height / 6
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

                    sourceSize.width: parent.height / 2;
                    sourceSize.height: parent.height / 2;

                    visible: false
                    source: "file:///usr/share/icons/jing/jing/settings/quicksettings/" + model.icon + ".svg"
                    antialiasing:true
                }

                ColorOverlay {
                    anchors.fill: imgIcon
                    source: imgIcon
                    color: root.isDarkScheme? "white":"#000000"
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
                    anchors.leftMargin: JDisplay.dp(10)

                    text: model.text
                    font.pixelSize: JDisplay.sp(14)//parent.height / 5
                    color: root.isDarkScheme? "white":"#000000"
                    opacity: 0.8
                }
            }
        }

        Item {
            id: sliderItem

            width: parent.width
            height: parent.height / 2
            property bool isBrightness: model.icon.indexOf("bright") != -1
            property double value: bgRectangle.currentValue / bgRectangle.moverRatio <= bgRectangle.maxWidth ? bgRectangle.currentValue / bgRectangle.moverRatio : bgRectangle.maxWidth

            Rectangle {
                id: bgRectangle
                anchors.fill: parent
                anchors.leftMargin: parent.height / 4
                anchors.rightMargin: parent.height / 4
                //anchors.topMargin: parent.top
                anchors.bottomMargin: parent.height / 3

                property int currentValue: sliderItem.isBrightness ? (root.screenBrightness) : volumeHandle.currentVolume
                property int maxnumValue: sliderItem.isBrightness ? (root.maximumScreenBrightness) : volumeHandle.maxVolumeValue
                property double maxWidth: bgRectangle.width
                property double moverRatio:  sliderItem.isBrightness ? (bgRectangle.maxnumValue-8) / bgRectangle.maxWidth :(bgRectangle.maxnumValue) / bgRectangle.maxWidth
                property int radiusValue:  bgRectangle.height / 4
                property bool mousePressed: false

                color: root.isDarkScheme? Qt.rgba(159,159,170,0.3):"#d1d1d1"
                radius: bgRectangle.radiusValue
                clip: true

                Rectangle {
                    id: sliderHandel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: bgRectangle.left
                    radius: bgRectangle.radiusValue
                    width: sliderItem.value
                    height: sliderItem.value < bgRectangle.radiusValue ?  bgRectangle.height - (bgRectangle.radiusValue  - sliderItem.value) : bgRectangle.height + 2
                    color: "#ffffff"
                }

                onMaxWidthChanged: {
                    sliderItem.value = bgRectangle.currentValue / bgRectangle.moverRatio <= bgRectangle.maxWidth ? bgRectangle.currentValue / bgRectangle.moverRatio : bgRectangle.maxWidth;
                    //sliderItem.value = maxnumValue ? currentValue*maxWidth / maxnumValue : 0
                }

                onCurrentValueChanged: {
                    if(bgRectangle.mousePressed == true)
                        return;
                    sliderItem.value = bgRectangle.currentValue / bgRectangle.moverRatio <= bgRectangle.maxWidth ? bgRectangle.currentValue / bgRectangle.moverRatio : bgRectangle.maxWidth;

                    if(sliderItem.isBrightness)
                        sliderItem.value = (bgRectangle.currentValue-8) / bgRectangle.moverRatio <= bgRectangle.maxWidth ? (bgRectangle.currentValue-8) / bgRectangle.moverRatio : bgRectangle.maxWidth;

                    //sliderItem.value = maxnumValue ? bgRectangle.currentValue*maxWidth / maxnumValue : 0
                }
            }

            MouseArea {
                id: sliderMouseArea
                //anchors.fill: parent
                anchors.left: bgRectangle.left
                anchors.top: bgRectangle.top
                anchors.bottom: bgRectangle.bottom
                width: bgRectangle.width+20 //当手指在外面时，也要支持滑动

                    pressAndHoldInterval:100

                    property double tmpValue: 0.0

                    //[liubangguo]根据新需求，点击滑动条不响应，只在滑动的时候起作用
                    onPressAndHold: {
                        root.childFocus(true)
                        bgRectangle.mousePressed = true
                        mouseEventTimer.start()
                    }

                    onReleased: {
                        root.childFocus(false)
                        bgRectangle.mousePressed = false
                    }


                    onPositionChanged: {
                        if(bgRectangle.mousePressed == false)
                            return;
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

                        mouseEventTimer.restart()

                    }
                    function mouseEventTimerOut(x,y) {
                        if (model.toggleFunction) {
                            var tmpSliderValue = sliderItem.value * bgRectangle.moverRatio
                            if(sliderItem.isBrightness)
                                tmpSliderValue = sliderItem.value * bgRectangle.moverRatio + 8
                            if(sliderItem.value * bgRectangle.moverRatio <=  bgRectangle.maxnumValue)
                                root[model.toggleFunction](tmpSliderValue);
                            else
                                root[model.toggleFunction]( bgRectangle.maxnumValue);
                        }
                    }

                    Timer {
                        id: mouseEventTimer
                        interval: 100
                        running: false
                        repeat: false
                        onTriggered: sliderMouseArea.mouseEventTimerOut(sliderMouseArea.x,sliderMouseArea.y);
                    }
                }
        }
    }
}



