/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *  Copyright 2021 Wang Rui <wangrui@jingos.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as QQC2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.12 as Kirigami
import QtGraphicalEffects 1.6

QQC2.Control {
    id: root
    leftPadding: 1// units.smallSpacing
    topPadding: 1//units.smallSpacing 
    rightPadding: 1// units.smallSpacing
    bottomPadding: 1//units.smallSpacing

    background: Item {
        MouseArea {
            anchors.fill: parent
        }
        
        Rectangle {
            id: container
            color: "#ffffff" // Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.backgroundColor, {"alpha": 255})
            anchors {
                fill: parent
                leftMargin: 1//PlasmaCore.Units.smallSpacing
                rightMargin: 1//PlasmaCore.Units.smallSpacing
                topMargin: 1//PlasmaCore.Units.smallSpacing
                bottomMargin: 1//PlasmaCore.Units.smallSpacing
            }
            radius: PlasmaCore.Units.smallSpacing * 7
        }

        DropShadow {
            anchors.fill: container
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12.0
            samples: 16
            cached: true
            color: Qt.rgba(0, 0, 0, 0.1)
            source: container
            visible: true
        }
    }
}
