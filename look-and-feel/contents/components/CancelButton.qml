/*
 *   Copyright 2021 Bangguo Liu <liubangguo@jingos.com>
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

import QtQuick 2.8

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Rectangle {
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

    width:  icon.implicitWidth + parent.height*0.47 + label.implicitWidth
    height:  parent.height
    color: Qt.rgba(1.0,1.0,1.0,0)

    Behavior on opacity {
        PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: iconCircle
        activeFocusOnTab: true
        anchors.centerIn: icon
        width: parent.height
        height: width
        radius: width / 2
        color: activeFocus || containsMouse ?  Qt.rgba(0.623,0.623,0.667,0.3):Qt.rgba(1.0,1.0,1.0,0.3)

        Behavior on opacity {
            PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

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
        width: 30
        height: 30
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
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

    PlasmaComponents3.Label {
        id: label
        font.pixelSize: root.height*0.25
        anchors {
            top: icon.bottom
            topMargin: root.height*0.46
            left: parent.left
            right: parent.right
        }
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        font.underline: iconCircle.activeFocus
        color:"white"
    }
}

