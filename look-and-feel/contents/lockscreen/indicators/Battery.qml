/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *  Copyright 2021 Rui Wang <wangrui@jingos.com>
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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW


RowLayout {
    visible: pmSource.data["Battery"]["Has Cumulative"]

    PlasmaComponents.Label {
        id: batteryLabel
        text: i18nd("plasma-phone-components", "%1%", pmSource.data["Battery"]["Percent"])
        Layout.alignment: Qt.AlignVCenter

        color: PlasmaCore.ColorScope.textColor
        // font.pixelSize: parent.height / 2
        font.pointSize: 9
    }

    Item{
        id: battery
        width: 14
        height: 8

        Image{
            id: batteryImg
            width: 14
            height: 8
            source: "file:///usr/share/icons/jing/jing/settings/Battery_rect_white.svg"
        }



        Rectangle{
            id: batteryVolumeRect
            property int maxWidth: 11
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 1

            width:maxWidth * pmSource.data["Battery"]["Percent"]/100
            height:6
            color: isPlugInsert() ? "#6DD400" :"white"
        }



        Image{
            id:batteryCharging
            anchors.centerIn: parent
            width:3
            height:6

            source:"file:///usr/share/icons/jing/jing/settings/Battery_charge_white.svg"
            visible: isPlugInsert()
        }





    }


    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }

    function isPlugInsert()
    {
        if(!pmSource.data["AC Adapter"])
            return fase;
        return pmSource.data["AC Adapter"]["Plugged in"];
    }
}


