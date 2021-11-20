/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
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
import jingos.display 1.0

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

    activeFocusOnTab: true
    radius: root.height*0.2

    color: activeFocus || containsMouse ?Qt.rgba(0.623,0.623,0.667,0.2):Qt.rgba(1.0,1.0,1.0,0.2)
    Behavior on opacity {
        PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Item {
        anchors.centerIn: root
        width:  icon.width + parent.height*0.32 + label.implicitWidth
        height:  parent.height

        Rectangle {
            id: iconCircle
            anchors.centerIn: icon
            width: icon.width
            height: width
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
            width: iconCircle.width
            height: width
            radius: width / 2
            scale: mouseArea.containsPress ? 1 : 0
            color: PlasmaCore.ColorScope.textColor
            opacity: 0.15
            Behavior on scale {
                PropertyAnimation {
                    duration: units.shortDuration
                    easing.type: Easing.InOutQuart
                }
            }
        }

        Image {
            id:icon
            width: parent.height*0.429
            height: parent.height*0.429
            anchors {
                left:parent.left
                verticalCenter: parent.verticalCenter
            }
        }

        ShaderEffect {
            anchors.fill: icon
            property variant src: icon
            property color color: "white"
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
            font.pixelSize: JDisplay.sp(15)//parent.height*0.25
//            font.family:"PingFangSC"
            anchors.left: icon.right
            anchors.leftMargin:parent.height*0.32
            anchors.verticalCenter: icon.verticalCenter

            style: softwareRendering ? Text.Outline : Text.Normal
            styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            font.underline: root.activeFocus
            color:"#ffffff"
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
