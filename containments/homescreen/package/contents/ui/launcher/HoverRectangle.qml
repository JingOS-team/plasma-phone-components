/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
import QtQuick 2.15
import QtQuick.Layouts 1.3
import jingos.display 1.0
 Rectangle {
    id: hoverRect
    property int rectRadius: JDisplay.dp(19)
    signal rectClicked(var mouse)
    signal rectPressed(var mouse)

    anchors.fill: parent
    radius: rectRadius
    opacity: 0
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: "#1E1E1E" }
        GradientStop { position: 1.0; color: "#000000"; }
    }
    MouseArea{
            anchors.fill: parent
            enabled: hoverRect.visible
            hoverEnabled: true
            onEntered: {
                hoverRect.opacity = 0.2
            }

            onExited: {
                hoverRect.opacity = 0
            }

            onPressed: {
                hoverRect.opacity = 0.4
                rectPressed(mouse)
            }
            onReleased: {
                hoverRect.opacity = 0
            }
            onCanceled: {
                hoverRect.opacity = 0
            }
            onClicked: {
                rectClicked(mouse)
            }
        }
}
