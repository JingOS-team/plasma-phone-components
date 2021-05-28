/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import org.kde.kirigami 2.15

Rectangle{
    id: background

    property real moveX: 0
    property real moveY: 0
    property bool darkMode: false

    anchors.fill: parent

    radius: ConstValue.radius
    color: "transparent"

    Rectangle {
        id: press_item

        anchors.fill: parent
        
        color:darkMode ?  ConstValue.darkPressColor : ConstValue.pressColor
        visible: false
        radius: parent.radius
        opacity: background.darkMode ? 0.3 : 0.16
    }

    Rectangle {
        id: back_item

        color: darkMode ? ConstValue.darkHoverColor : ConstValue.hoverColor
        radius: parent.radius
        opacity: darkMode ? 0.18 : 0.12
        
        state: "hiden"
        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: back_item

                    x: 0
                    y: 0
                    width: background.width
                    height: background.height
                    
                    visible:true
                }

                PropertyChanges {
                    target: background.parent
                    scale: 1.1
                }
            },
            State {
                name: "hiden"
                PropertyChanges {

                    target: back_item

                    x: background.moveX
                    y: background.moveY
                    width:  0
                    height: 0

                    visible:false
                    scale: 1
                    
                }
                PropertyChanges {
                    target: background.parent

                    scale: 1
                }
            }
        ]

        transitions:[
            Transition {
                from:"hiden"; to:"shown"
                SequentialAnimation{
                    PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }

                    PropertyAnimation { target: back_item; properties: "x,y,width,height"; duration: 400; easing.type: Easing.OutQuart }
                }

                PropertyAnimation { target: background.parent; properties: "scale"; duration: 400; easing.type: Easing.OutQuart }
            },
            Transition {
                from:"shown"; to:"hiden"
                SequentialAnimation{
                    PropertyAnimation { target: back_item; properties: "x,y,width,height,"; duration: 200; easing.type: Easing.OutQuart }

                    PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }
                }

                PropertyAnimation { target: background.parent; properties: "scale"; duration: 200; easing.type: Easing.OutQuart }
            }
        ]
    }

    MouseArea {
        id:area

        anchors.fill:parent
        hoverEnabled: true

        onEntered: {
            cursorShape = Qt.BlankCursor

            back_item.x = mouseX
            back_item.y = mouseY
            back_item.state = "shown"
        }

        onExited: {
            cursorShape = Qt.ArrowCursor

            background.moveX = mouseX
            background.moveY = mouseY
            back_item.state = "hiden"
        }

        onClicked: {
            background.parent.clicked(mouse)
        }

        onPressed: {
            press_item.visible = true
            back_item.visible = false

            background.parent.pressed(mouse)
        }

        onReleased: {
            press_item.visible = false
            back_item.visible = true
            
            background.parent.released(mouse)
        }
    }
}