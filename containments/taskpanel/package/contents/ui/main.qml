/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

PlasmaCore.ColorScope {
    id: root
    width: 600
    height: 480
    colorGroup: showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Rectangle {
        id: taskHandle
        anchors.centerIn: parent

        width: parent.width / 6
        height: parent.height / 2
        color: "#d8d8d8"
        radius:  height / 2
        z: 255
        visible: !MobileShell.HomeScreenControls.homeScreenVisible

        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton

            onClicked: {
                if(mouse.button == Qt.LeftButton) {
                    minimizeAll();
                }
            }

            onEntered: {
                taskHandle.scale = 1.2          
            }

            onExited: {
                taskHandle.scale = 1
            }

            onCanceled: {
                taskHandle.scale = 1
            }
        }
    }

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : PlasmaCore.ColorScope.backgroundColor
    readonly property bool showingApp: !plasmoid.nativeInterface.allMinimized

    readonly property bool hasTasks: tasksModel.count > 0

    // property QtObject taskSwitcher: taskSwitcherLoader.item ? taskSwitcherLoader.item : null

    // Loader {
    //     id: taskSwitcherLoader
    //     onLoaded: {
    //         // taskSwitcher.offset = -taskSwitcher.height;
    //     }
    // }

    Connections {
        target: plasmoid.nativeInterface

        onAllMinimizedChanged: {
            MobileShell.HomeScreenControls.activeWindowDesktopName = plasmoid.nativeInterface.activeWindowDesktopName
            MobileShell.HomeScreenControls.homeScreenVisible = plasmoid.nativeInterface.allMinimized
        }
    }

    // Timer {
    //     running: true
    //     interval: 200
    //     onTriggered: {
    //         taskSwitcherLoader.setSource(Qt.resolvedUrl("TaskSwitcher.qml"), {"model": tasksModel});
    //     }
    // }

    function minimizeAll() {
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.makeModelIndex(i);
            if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }

    function restoreAll() {
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.makeModelIndex(i);
            if (tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        sortMode: TaskManager.TasksModel.SortAlpha

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        Component.onCompleted: tasksModel.countChanged();
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }
}
