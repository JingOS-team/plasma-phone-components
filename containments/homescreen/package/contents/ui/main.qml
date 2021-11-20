/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *  Copyright 2021 Wang Rui <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import "launcher" as Launcher

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager

import org.kde.phone.homescreen 1.0

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    width: 640
    height: 400

    property Item toolBox
    property bool componentComplete: false

    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged:recalculateMaxFavoriteCount()

    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }
    }

    Component.onCompleted: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
        componentComplete = true;
        recalculateMaxFavoriteCount()
    }

    Plasmoid.onScreenChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }
    
    Window.onWindowChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }
    
    Connections {
        target: MobileShell.HomeScreenControls
        onActiveWindowDesktopNameChanged: {
            MobileShell.HomeScreenControls.isSystemApp = plasmoid.nativeInterface.listModelManager.getPanelBehavorState(MobileShell.HomeScreenControls.activeWindowDesktopName);
        }
    }

    Launcher.JingLauncher {
        id: launcher
        anchors.fill: parent
    }
}