/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as QQC2

//import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.12 as Kirigami
import QtGraphicalEffects 1.6

import QtGraphicalEffects 1.12
import jingos.display 1.0

QQC2.Control {
    id: root
    leftPadding: JDisplay.dp(1)// units.smallSpacing
    topPadding: JDisplay.dp(1)//units.smallSpacing 
    rightPadding: JDisplay.dp(1)// units.smallSpacing
    bottomPadding: JDisplay.dp(1)//units.smallSpacing

    background: Item {
        MouseArea {
            anchors.fill: parent
        }
        
        Rectangle {
            id: container

            //[liubangguo]for multi scheme color
            //color: plasmoid.nativeInterface.isDarkColorScheme ? Qt.rgba(38 / 255, 38 / 255, 42 / 255,1): Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1)
            color: Qt.rgba(38 / 255, 38 / 255, 42 / 255,1)

            anchors {
                fill: parent
                leftMargin: 0//PlasmaCore.Units.smallSpacing
                rightMargin: 0//PlasmaCore.Units.smallSpacing
                topMargin: 0//PlasmaCore.Units.smallSpacing
                bottomMargin: 0//PlasmaCore.Units.smallSpacing
            }
            radius: 19
        }

        DropShadow {
            anchors.fill: container
            horizontalOffset: 0
            verticalOffset: JDisplay.dp(4)
            radius: 12.0
            samples: 16
            cached: true
            color: Qt.rgba(0, 0, 0, 0.1)
            source: container
            visible: true
        }
    }
}
