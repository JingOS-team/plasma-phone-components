/*
    Copyright 2019 MArco MArtni <mart@kde.org>
    Copyright 2013-2017 Jan Grulich <jgrulich@redhat.com>
    Copyright 2021 Bangguo Liu <liubangguo@jingos.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtGraphicalEffects 1.6
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item{
    Layout.alignment: Qt.AlignVCenter

    width:13
    height:10

    Image{
        property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible
        id:imgIcon

        source: wifiIcon()
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        antialiasing: true
        opacity:1.0

        visible: showingApp
    }

    ColorOverlay {
                anchors.fill: imgIcon
                source: imgIcon
                color: showingApp ?  "#000000" : "#ffffff"
                antialiasing: true
                opacity:1.0
    }

//    PlasmaComponents.BusyIndicator {
//        id: connectingIndicator

//        anchors.fill: parent
//        running: connectionIconProvider.connecting
//        visible: running
//    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }

    function wifiIcon()
    {
        var icon = "file:///usr/share/icons/jing/jing/settings/wifi_disconnected.svg";
        if(connectionIconProvider.connectionIcon.indexOf("network-wireless") != -1)
        {
            var prefix = "network-wireless-";
            var volume = parseInt(connectionIconProvider.connectionIcon.substring(prefix.length));
            if(volume > 75)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_100.svg";
            else if(volume > 50)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_75.svg";
            else if(volume > 25)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_25.svg";
            else
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_disconnected.svg";
        }
        else if(connectionIconProvider.connectionIcon.indexOf("network-wired-activated") != -1)
        {
            icon = "file:///usr/share/icons/jing/jing/settings/network_wired.svg";
        }

        else{
            icon = "file:///usr/share/icons/jing/jing/settings/wifi_closed.svg";
        }
        return icon;
    }

}
