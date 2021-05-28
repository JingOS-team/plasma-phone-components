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

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import QtQuick.Window 2.14

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.notificationmanager 1.1 as Notifications

import org.kde.phone.jingos.mediamanager 1.0

import "LayoutManager.js" as LayoutManager

import "quicksettings"
import "indicators" as Indicators


Item {
    id: root
    width: 480
    height: 30

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    property var uint: [];
    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : icons.backgroundColor
    property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible //: !MobileShell.HomeScreenControls.isSystemApp //

    readonly property bool hasTasks: tasksModel.count > 0

    property real appWidthRatio: Screen.width / 1920
    property real appHeightRatio: Screen.height / 1200

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        if(applet.id === 4) //通知图标不加入
            return;
        var compactContainer = compactContainerComponent.createObject(appletIconsRow)
        print("======Applet added: " + applet + " " + applet.title+ " id:"+applet.id)

        applet.parent = compactContainer;
        compactContainer.applet = applet;
        applet.anchors.fill = compactContainer;
        applet.visible = true;

        applet.expanded = true
        applet.expanded = false

        var fullContainer = null;
    }

    MediaManager {
        onMouseOnTopLeftConer: {
            nofifySlidingPanel.toggle()
        }
        onMouseOnTopRightConer: {
            slidingPanel.toggle()
        }
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly
        Component.onCompleted: tasksModel.countChanged();
    }

    PlasmaCore.DataSource {
        id: statusNotifierSource
        engine: "statusnotifieritem"
        interval: 0
        onSourceAdded: {
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }

    RowLayout {
        id: appletsLayout
        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
    }

    Component {
        id: compactContainerComponent
        Item {
            property Item applet
            visible: applet && (applet.status != PlasmaCore.Types.HiddenStatus && applet.status != PlasmaCore.Types.PassiveStatus)
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, appletIconsRow.height) : appletIconsRow.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    Component {
        id: fullContainerComponent
        FullContainer {
        }
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    DropShadow {
        anchors.fill: icons
        visible: !showingApp
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4.0
        samples: 17
        color: Qt.rgba(255,255,255,0.2)
        source: icons
    }

    PlasmaCore.ColorScope {
        id: icons
        z: 1
        colorGroup: showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        //parent: slidingPanel.visible && !slidingPanel.wideScreen ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height
/*
        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                GradientStop {
                    position: 1.0
                    ColorAnimation on color {
                        id: topColorAnimation
                        to: showingApp ? root.backgroundColor : "transparent";
                        duration: 250

                        onToChanged: {
                            topColorAnimation.restart()
                        }
                    }
                    // color: showingApp ? root.backgroundColor : "transparent"
                }
                GradientStop {
                    position: 0.0
                    ColorAnimation on color {
                        id: bottomColorAnimation

                        to: showingApp ? root.backgroundColor : Qt.rgba(0, 0, 0, 0.1);
                        duration: 250

                        onToChanged: {
                            bottomColorAnimation.restart()
                        }
                    }
                    // color: showingApp ? root.backgroundColor : Qt.rgba(0, 0, 0, 0.1)
                }
            }

        }
        */
        PlasmaComponents.Label {
            id: clock
            property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
            anchors.left: parent.left
            anchors.leftMargin: height / 2
            height: parent.height
            text:  getLocalTimeString()//Qt.formatTime(timeSource.data["Local"]["DateTime"], is24HourTime ? "h:mm" : "h:mm AP")

            color: PlasmaCore.ColorScope.textColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: 9//height - height / 3
        }

        RowLayout {
            id: appletIconsRow
            anchors {
                bottom: parent.bottom
                right: simpleIndicatorsLayout.left
            }
            anchors.rightMargin: units.smallSpacing
            height: parent.height
        }

        //[liubangguo][20210513]change panel items position
        RowLayout {
            id: simpleIndicatorsLayout
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: units.smallSpacing
            anchors.verticalCenter: parent

            height: parent.height
            spacing: 5

            //Indicators.Headset{}
            Indicators.Udisk{
                visible:plasmoid.nativeInterface.udiskInserted
            }
            //Indicators.Location{}
            //Indicators.Rotate{}

            Indicators.Volume {
                id: volumeHandle
            }

            Indicators.AlarmClock{
                visible:plasmoid.nativeInterface.alarmVisible
            }


            Indicators.Battery {}
        }

        RowLayout{
            id:wirelessIndicatorsLayout

            anchors.bottom: parent.bottom
            anchors.left: clock.right
            anchors.leftMargin: 6//units.smallSpacing

            height: parent.height
            spacing: 6

            Indicators.Wifi {}
            Indicators.Bluetooth {}

        }

    }
    
    MouseArea {
        id: mouseAreaHandle
        z: 99
        property int oldMouseY: 0
        property bool slidingPanelActive: true
        anchors.fill: parent

        onPressed: {
            slidingPanel.stopAnim()
            nofifySlidingPanel.stopAnim()

            if(mouse.x < parent.width / 2) {

                if (nofifySlidingPanel.isNotificationPanelOpen) {
                    return
                }
                slidingPanel.close()
                mouseAreaHandle.slidingPanelActive = false
                // nofifySlidingPanel.drawerX = 16// nofifySlidingPanel.drawerWidth / 20//Math.min(Math.max(0, mouse.x - slidingPanel.drawerWidth/2), slidingPanel.width - slidingPanel.drawerWidth)
                nofifySlidingPanel.userInteracting = true;
                oldMouseY = mouse.y;
                nofifySlidingPanel.offset = 0//units.gridUnit * 2;
                nofifySlidingPanel.showFullScreen();
            } else {
                if (slidingPanel.slidingPanelIsOpen) {
                    return
                }
                nofifySlidingPanel.close()
                mouseAreaHandle.slidingPanelActive = true
                // slidingPanel.drawerX = slidingPanel.width - slidingPanel.drawerWidth - 16 //slidingPanel.drawerWidth / 20//Math.min(Math.max(0, mouse.x - slidingPanel.drawerWidth/2), slidingPanel.width - slidingPanel.drawerWidth)
                slidingPanel.userInteracting = true;
                oldMouseY = mouse.y;
                slidingPanel.offset = 0//units.gridUnit * 2;
                slidingPanel.showFullScreen();
            }
        }

        onPositionChanged: {
            
            if(!mouseAreaHandle.slidingPanelActive) {
                if (nofifySlidingPanel.isNotificationPanelOpen) {
                    return
                }
                nofifySlidingPanel.offset = Math.min(nofifySlidingPanel.contentItem.height, nofifySlidingPanel.offset + (mouse.y - oldMouseY));
                oldMouseY = mouse.y;
            } else {
                if (slidingPanel.slidingPanelIsOpen) {
                    return
                }
                slidingPanel.offset = Math.min(slidingPanel.contentItem.height, slidingPanel.offset + (mouse.y - oldMouseY));
                oldMouseY = mouse.y;
            }
        }

        onReleased: {
            if(!mouseAreaHandle.slidingPanelActive) {
                nofifySlidingPanel.userInteracting = false;
                nofifySlidingPanel.updateState();
            } else {
                slidingPanel.userInteracting = false;
                slidingPanel.updateState();
            }
        }
    }

    SlidingPanel {
        id: slidingPanel
        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        openThreshold: units.gridUnit * 2
        headerHeight: root.height

        offset: quickSettingsParent.height / 10
        drawerHeight: panelContents.width
        onClosed: quickSettings.closed()

        contentItem: GridLayout {
            id: panelContents
            anchors.fill: parent

            DrawerBackground {
                id: quickSettingsParent
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: panelContents.width
                Layout.preferredHeight: panelContents.width
                z: 4

                contentItem: QuickSettings {
                    id: quickSettings
                    onCloseRequested: {
                        slidingPanel.hide()
                    }
                }
            }
        }
    }

    SlidingPanelNotification {
        id: nofifySlidingPanel
        
        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        openThreshold: units.gridUnit * 2
        headerHeight: root.height
        drawerHeight: 155

        Connections {
            target: notifications
            onListViewContentHeightChanged: {
                if (notifications.listViewCount === 0 ) {
                    nofifySlidingPanel.drawerHeight = 155
                } else {
                    if ((appHeightRatio * 80 + notifications.listViewContentHeight) + PlasmaCore.Units.smallSpacing * 5 > appHeightRatio * 1124) {
                        nofifySlidingPanel.drawerHeight = appHeightRatio * 1124

                    } else {
                        nofifySlidingPanel.drawerHeight =  notifications.listViewContentHeight + 70
                    }
                }
            }
        }
        
        offset: notifyQuickSettingsParent.height / 10

        onClosed: notifications.backAll()

        contentItem: GridLayout {
            id: notifyPanelContents
            anchors.fill: parent

            DrawerBackground {
                id: notifyQuickSettingsParent
                // anchors.fill: parent
                Layout.alignment: Qt.AlignTop
                // Layout.preferredWidth: slidingPanel.wideScreen ? Math.min(slidingPanel.width/2, units.gridUnit * 25) : panelContents.width
                Layout.preferredWidth: notifyPanelContents.width * 0.9
                Layout.preferredHeight: notifyPanelContents.height
                z: 4

                contentItem: QuickNotificationList {
                    id: notifications

                    onCloseRequested: {
                        // nofifySlidingPanel.hide()
                        nofifySlidingPanel.close()

                    }
                }
            }
        }
    }

    Notifications.WatchedNotificationsModel {
        id: notifyModel
    }

    function getLocalTimeString(){
        var timeStr = String(timeSource.data["Local"]["DateTime"]);
        var isChinaLocal = (timeStr.indexOf("GMT+0800") != -1)
        timeStr = Qt.formatTime(timeSource.data["Local"]["DateTime"], plasmoid.nativeInterface.isSystem24HourFormat ? "h:mm" : "h:mm AP");
        if(isChinaLocal){
            if(timeStr.search("AM") != -1)
                timeStr = timeStr.replace("AM","上午");
            if(timeStr.search("PM") != -1)
                timeStr = timeStr.replace("PM","下午");
        }
        else{
            if(timeStr.search("上午") != -1)
                timeStr = timeStr.replace("上午","AM");
            if(timeStr.search("下午") != -1)
                timeStr = timeStr.replace("下午","PM");
        }
        return timeStr;
    }
}
