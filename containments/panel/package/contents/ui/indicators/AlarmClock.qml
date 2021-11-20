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
import jingos.display 1.0



Image{
    property bool isShowWhite: root.showColorWhite//!MobileShell.HomeScreenControls.isSystemApp
    Layout.alignment: Qt.AlignVCenter

    source: !isShowWhite ? "file:///usr/share/icons/jing/jing/settings/AlarmClock.svg" : "file:///usr/share/icons/jing/jing/settings/AlarmClock_white.svg"
    sourceSize.width: JDisplay.dp(11)
    sourceSize.height: JDisplay.dp(11)
    antialiasing: true
}


