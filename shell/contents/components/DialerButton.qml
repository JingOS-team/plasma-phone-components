/***************************************************************************
 *   Copyright (C) 2021 by Bangguo Liu <liubangguo@jingos.com>             *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Text {
    width: parent.width / parent.columns
    height: parent.buttonHeight
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    color: dialer.textColor
    font.pixelSize: Math.floor((width - (units.largeSpacing)) / 2)
    property alias sub: longHold.text
    property var callback

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (callback) {
                callback();
            } else {
                addNumber(parent.text);
            }
        }

        onPressAndHold: {
            if (longHold.visible) {
                addNumber(longHold.text);
            } else {
                addNumber(parent.text);
            }
        }
    }

    Text {
        id: longHold
        anchors {
            top: parent.top
            right: parent.right
        }
        height: parent.height
        width: parent.width / 3
        verticalAlignment: Qt.AlignVCenter
        visible: text.length > 0
        opacity: 0.7

        font.pixelSize: parent.pixelSize * .8
        color: parent.color
    }
}
