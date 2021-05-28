/*
Copyright (C) 2021 Bob Wu <pengbo.wu@jingos.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQml 2.12
import QtGraphicalEffects 1.12
import QtQuick.Window 2.12
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: chargedroot

    property real appWidthRatio: 1920 / Screen.width
    property real appHeightRatio: 1415 / Screen.height
    anchors.fill: parent

    opacity: 1
    // Image {
    //      id:bgImage
    //      anchors.fill: parent
    //      source: "file:///usr/share/icons/jing/lockscreen_bg.png"
    // }

    FastBlur {
       id: chargedrootblur

       anchors.fill: parent
       source: lockScreen

       cached: true
       visible: true
       radius: 90
       opacity: 0
    }

    Rectangle {
        id: backageRectangle

        anchors.fill: parent

        color: Qt.rgba(0, 0, 0)
        opacity: 0
    }

    PropertyAnimation {
        id: maskAnimationOpacity

        target: backageRectangle
        property: "opacity"
        running: false
        to: 0.7
        duration: 100
    }

    Charged {
        id:chargedComponent

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 470 / appHeightRatio

        imageUrl: "file:///usr/share/icons/jing/lightning.svg"
        circleDia: 298 / appWidthRatio
        progress: pmSource.data["Battery"]["Percent"] / 100 * 360
        arcWidth: 18 / appWidthRatio
        arcColor: "#52FB6E"
        arcBackgroundColor: Qt.rgba(255, 255, 255, 0.15)

        PlasmaCore.DataSource {
            id: pmSource

            engine: "powermanagement"
            connectedSources: ["Battery", "AC Adapter"]
        }
    }

    Text {
        id: chargedPercent

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: chargedComponent.bottom
        anchors.topMargin: 85 / appHeightRatio

        opacity: 0
        lineHeight: 47 / appHeightRatio
        color: "#ffffff"
        font.pixelSize: 40 / appHeightRatio
        font.letterSpacing: 0
        font.weight: Font.Light
        font.family: "Gilroy, Gilroy-Regular"
        text: i18nd("plasma-phone-components", "%1% Charged", pmSource.data["Battery"]["Percent"])
    }

    Component.onCompleted: {
        animationTimer.start()
    }

    Timer {
        id: animationTimer

        interval: 100
        repeat: false
        onTriggered: {
            maskAnimationOpacity.running = true
        }
    }
}