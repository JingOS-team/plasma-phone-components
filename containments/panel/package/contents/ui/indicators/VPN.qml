/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import jingos.display 1.0

Image {
    property bool isShowWhite: root.showColorWhite
    property bool isVpnConnected: false
    Layout.alignment: Qt.AlignVCenter

    sourceSize.width: JDisplay.dp(15)
    sourceSize.height: JDisplay.dp(11)
    antialiasing: true
    visible: isVpnConnected

    source: !isShowWhite ? "file:///usr/share/icons/jing/jing/settings/Vpn.svg" : "file:///usr/share/icons/jing/jing/settings/Vpn_white.svg"

    PlasmaNM.VpnProxyModel {
        id: vpnProxyModel

        sourceModel: connectionModel

        onConnectedNameChanged: {
            isVpnConnected = name != "" ? true : false
        }
    }

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }
}
