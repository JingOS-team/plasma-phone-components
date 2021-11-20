/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.2
import QtGraphicalEffects 1.6
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import jingos.display 1.0

Item{
    Layout.alignment: Qt.AlignVCenter
    property bool isShowWhite: true
    width: JDisplay.dp(11)
    height: JDisplay.dp(11)

    Image {
        id:imgIcon
        Layout.alignment: Qt.AlignVCenter

        source: "file:///usr/share/icons/jing/jing/settings/FlightMode.svg"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        antialiasing: true
        opacity:1.0

        visible: !isShowWhite
    }

    ColorOverlay {
        anchors.fill: imgIcon
        source: imgIcon
        color: !isShowWhite ?  "#000000" : "#ffffff"
        antialiasing: true
        opacity:1.0
    }
}

