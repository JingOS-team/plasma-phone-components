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
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import jingos.display 1.0

Item{
    id: wifi_root
    Layout.alignment: Qt.AlignVCenter
    property bool isShowWhite: root.showColorWhite
    property string wifi_icon : wifiIcon()
    property string currentConnectionIcon : stSource.data["StatusPanel"]["currentConnectionIcon"]

    width:JDisplay.dp(13)
    height:JDisplay.dp(11)
    visible: false

    function wifiIcon() {
        var icon = "file:///usr/share/icons/jing/jing/settings/wifi_disconnected.svg";

        wifi_root.visible = true;
        if(currentConnectionIcon.indexOf("network-wireless") != -1) {
            var prefix = "network-wireless-";
            var volume = parseInt(currentConnectionIcon.substring(prefix.length));
            if(volume > 75)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_100.svg";
            else if(volume > 50)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_75.svg";
            else if(volume > 25)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_50.svg";
            else if(volume > 0)
                icon = "file:///usr/share/icons/jing/jing/settings/wifi_volume_25.svg";
            else{
                //[liubangguo]WIFI未连接时，不显示图标
                wifi_root.visible = false
            }
        } else if(currentConnectionIcon.indexOf("network-wired-activated") != -1) {
            icon = "file:///usr/share/icons/jing/jing/settings/network_wired.svg";
        } else {
            //icon = "file:///usr/share/icons/jing/jing/settings/wifi_closed.svg";
            wifi_root.visible = false
        }
        return icon;
    }

    onCurrentConnectionIconChanged: {
        wifi_icon = wifiIcon();
    }

    Image {
        id:imgIcon

        source: wifi_root.wifi_icon
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        antialiasing: true
        opacity:1.0

        visible: !isShowWhite
    }

    ColorOverlay {
        anchors.fill: imgIcon
        source: imgIcon
        color: !isShowWhite ?  "#000000" : "#ffffff"
        antialiasing: true
        opacity:1.0
    }

}
