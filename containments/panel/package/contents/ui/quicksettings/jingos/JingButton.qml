/*
 * Copyright 2021 Bob Wu <pengbo.wu@jingos.com>
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick 2.0
import QtQml 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick 2.0
import QtQml 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

Item {
    id: root

    property bool enable
    property color bgcolor : "#00000000"
    property alias text: text.text
    property real fontSize
    signal clicked()


    Rectangle {
        width: parent.width
        height: parent.height
        radius: 7
        clip: true

        color: bgcolor

        Control {
            anchors.fill: parent
            padding: 7
            RowLayout {
                height: parent.availableHeight
                width: parent.availableWidth
                anchors.centerIn: parent
                clip: true

                Label {
                    id: text
                    width: contentWidth
                    height: contentHeight
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    // verticalAlignment: Text.AlignCenter
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.clicked()
            }
            hoverEnabled: true

            onEntered: {
                hoverMask.visible = true
            }

            onExited: {
                hoverMask.visible = false
            }

            onPressed: {
                touchMask.visible = true
            }

            onReleased: {
                touchMask.visible = false
            }
        }
    }

    Rectangle {
        id: hoverMask
        visible: false
        width: parent.width
        height: parent.height
        radius: 7
        color: "#9F9FAA"
        opacity: 0.2
    }

    Rectangle {
        id: touchMask
        visible: false
        width: parent.width
        height: parent.height
        radius: 7
        color: "#9F9FAA"
        opacity: 0.3

        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
        }
    }

}

