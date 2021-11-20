/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.8

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import jingos.display 1.0

Item {
    id: root

    property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    property alias font: label.font
    property alias labelRendering: label.renderType
    property alias circleOpacity: iconCircle.opacity
    property alias circleVisiblity: iconCircle.visible
    property int fontSize: config.fontSize
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    signal clicked

    Behavior on opacity {
        PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle{
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        activeFocusOnTab: true
        color: activeFocus || containsMouse ?Qt.rgba(0.623,0.623,0.667,0.2):Qt.rgba(1.0,1.0,1.0,0.2)
        height: parent.height * 0.638
        width: height
        radius: width / 2

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            onClicked: root.clicked()
            anchors.fill: parent
        }

        Keys.onEnterPressed: clicked()
        Keys.onReturnPressed: clicked()
        Keys.onSpacePressed: clicked()

        Accessible.onPressAction: clicked()
        Accessible.role: Accessible.Button
        Accessible.name: label.text

        Rectangle {
            id: iconCircle
            anchors.centerIn: icon
            width: icon.height
            height: iconCircle.width
            radius: width / 2
            opacity: 0

            Behavior on opacity {
                PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            anchors.centerIn: iconCircle
            width: parent.height
            height: width
            radius: width / 2
            opacity: 0.15
            Behavior on scale {
                PropertyAnimation {
                    duration: units.shortDuration
                    easing.type: Easing.InOutQuart
                }
            }
        }

        Image {
            id: icon
            width: root.height * 0.319
            height: icon.width
            anchors.centerIn: parent
        }

        ShaderEffect {
            anchors.fill: icon
            property variant src: icon
            property color color: "white" //遮盖显示的颜色
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform highp vec4 color;
                uniform lowp float qt_Opacity;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    gl_FragColor = vec4(color.r * tex.a, color.g * tex.a, color.b * tex.a, tex.a) * qt_Opacity;
                }"
        }
    }

    PlasmaComponents3.Label {
        id: label
        font.pixelSize: JDisplay.sp(15)//root.height*0.25
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        font.underline: iconCircle.activeFocus
        color:"white"
    }
}

