/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import jingos.display 1.0
import org.kde.plasma.plasmoid 2.0

Rectangle {
    id: imgItem
    property var url
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredWidth: Layout.columnSpan
    Layout.preferredHeight: Layout.rowSpan
    color: url !== "" ? "transparent" : "#CCCBCBCB"
    radius: JDisplay.dp(5)
    Image {
        id: bigImageView
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        source: url
        visible: false
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        antialiasing:true
    }

    Rectangle {
        id: maskRect
        anchors.fill: bigImageView
        visible: false
        clip: true
        radius: JDisplay.dp(5)
    }

    OpacityMask {
        id: mask
//        anchors.fill: maskRect
        width: maskRect.width - JDisplay.dp(2)
        height: maskRect.height - JDisplay.dp(2)
        anchors.centerIn: maskRect
        source: bigImageView
        maskSource: maskRect
        antialiasing:true
    }

    HoverRectangle {
        anchors.fill: parent
        rectRadius: JDisplay.dp(5)
        onRectClicked: {
            var mapItem = mapToItem(root, mouse.x, mouse.x)
            console.log(" [zhg] mapItem.x :" + mapItem.x + " mapItem.y:" + mapItem.y)
            toLaunch(mapItem.x,mapItem.y,appsInfo["photo"]["icon"],appsInfo["photo"]["name"],appsInfo["photo"]["storageId"])
            plasmoid.nativeInterface.listModelManager.runApplication(appsInfo["photo"]["storageId"]);
        }
    }
    
}
