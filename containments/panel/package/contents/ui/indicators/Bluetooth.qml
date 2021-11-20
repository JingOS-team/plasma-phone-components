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
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.private.bluetooth 1.0
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import jingos.display 1.0


Item{
    Layout.alignment: Qt.AlignVCenter
    width:JDisplay.dp(8)
    height:JDisplay.dp(11)
    property bool isShowWhite: root.showColorWhite //!MobileShell.HomeScreenControls.isSystemApp
    visible:devicesProxyModel.connectedName!=""

    Image {
        id:imgIcon

        source: "file:///usr/share/icons/jing/jing/settings/Bluetooth.svg"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        antialiasing: true

        visible:BluezQt.Manager.bluetoothOperational && !isShowWhite
    }

    ColorOverlay {
        anchors.fill: imgIcon
        source: imgIcon
        color: !isShowWhite ?  "#000000" : "#ffffff"
        antialiasing: true
        visible: BluezQt.Manager.bluetoothOperational
        opacity:1.0
    }

    DevicesProxyModel {
        id: devicesProxyModel
        sourceModel: devicesModel

        // onConnectedNameChanged: {
        // }
    }

    BluezQt.DevicesModel {
        id:devicesModel
    }
}

