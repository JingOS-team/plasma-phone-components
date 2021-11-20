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

import org.kde.phone.jingos.hotkeysmanager 1.0
import org.kde.plasma.private.digitalclock 1.0 as DC

import jingos.display 1.0
import "LayoutManager.js" as LayoutManager

import "quicksettings"
import "indicators" as Indicators

Item {
    id: root
    width: JDisplay.dp(480)
    height: JDisplay.dp(30)

    property int animationTime: 75

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property bool blockFlickable
    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property bool flightMode: stSource.data["StatusPanel"]["flight mode"]
    property var layoutManager: LayoutManager

    property var uint: [];
    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : icons.backgroundColor
    property bool showColorWhite: showColorLight()//!MobileShell.HomeScreenControls.homeScreenVisible

    readonly property bool hasTasks: tasksModel.count > 0

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    Connections {
        target: plasmoid.nativeInterface

        onSetToDefaultVolume: {
            volumeHandle.toBeDefault = true
        }
    }

    function addApplet(applet, x, y) {
        //去掉KDE自带的图标
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

    Notifications.WatchedNotificationsModel {
        id: notifyModel
    }

    function getLocalTimeString() {
        var timeStr = timeSource.data["Local"]["DateTime"].toLocaleTimeString(Qt.locale(),timezoneProxy.isSystem24HourFormat ?
                                 "hh:mm" : (timezoneProxy.getRegionTimeFormat() === "zh_"? "AP hh:mm" : "hh:mm AP"));
        if(timezoneProxy.getRegionTimeFormat() === "zh_"){
            if(timeStr.search("AM") !== -1)
                timeStr = timeStr.replace("AM","上午");
            if(timeStr.search("PM") !== -1)
                timeStr = timeStr.replace("PM","下午");

        }else{
            if(timeStr.search("上午") !== -1)
                timeStr = timeStr.replace("上午","AM");
            if(timeStr.search("下午") !== -1)
                timeStr = timeStr.replace("下午","PM");
        }
        return timeStr;
    }

    function showColorLight() {
        if(plasmoid.nativeInterface.allMinimized)
            return true;
        if(plasmoid.nativeInterface.isDarkColorScheme)
            return true;
        return false;
    }

    DC.TimeZoneFilterProxy {
        id:timezoneProxy
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
	plasmoid.nativeInterface.initializeConfigData();
    }

    HotkeysManager {
        id: hotkeysManager

        onShowNotificationCenter: {
            nofifySlidingPanel.toggle()
        }

        onShowControlCenter: {
            slidingPanel.toggle()
        }

        onMouseOnTopLeftConer: {
            nofifySlidingPanel.toggle()
        }

        onMouseOnTopRightConer: {
            slidingPanel.toggle()
        }
        onCloseLockScreeNotificationId:{
            notifyModel.close(id);
        }
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
        Layout.minimumHeight: JDisplay.dp(Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height))
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
        interval: 1000
    }

    DropShadow {
        anchors.fill: icons
        visible: showColorWhite
        horizontalOffset: 0
        verticalOffset: 1
        radius: JDisplay.dp(4.0)
        samples: JDisplay.dp(17)
        cached: true
        color: Qt.rgba(0,0,0,0.8)
        source: icons
    }

    PlasmaCore.ColorScope {
        id: icons
        z: 1
        property int margin: JDisplay.dp(3)
        colorGroup: !showColorWhite ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        //parent: slidingPanel.visible && !slidingPanel.wideScreen ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin:margin
        }
        height: root.height-margin

        PlasmaComponents.Label {
            id: clock
            property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
            anchors.left: parent.left
            anchors.leftMargin: height / 2 + JDisplay.dp(2)
            height: parent.height
            text:  getLocalTimeString()

            color: showColorWhite ? "white" : "black"//PlasmaCore.ColorScope.textColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: JDisplay.sp(12)
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
            //anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: JDisplay.dp(11)//units.smallSpacing
            anchors.verticalCenter: parent

            height: parent.height
            spacing: JDisplay.dp(5)

            Indicators.Headset{
                visible:stSource.data["StatusPanel"]["sound insert"]
            }

            Indicators.Udisk {
                visible:stSource.data["StatusPanel"]["udisk insert"]
            }
            Indicators.Location {}
            //Indicators.Rotate{}

            Indicators.VPN {}

            Indicators.Volume {
                id: volumeHandle
            }

            Indicators.AlarmClock {
                visible:stSource.data["StatusPanel"]["alarm active"]
            }

            Indicators.Battery {}
        }

        RowLayout{
            id:wirelessIndicatorsLayout

            //anchors.bottom: parent.bottom
            anchors.left: clock.right
            anchors.leftMargin: JDisplay.dp(6)//units.smallSpacing
            anchors.verticalCenter: parent

            height: parent.height
            spacing: JDisplay.dp(6)

            Indicators.SignalStrength{
            }
            Indicators.Wifi {}
            Indicators.Bluetooth {}
            Indicators.FlightMode {
                visible:stSource.data["StatusPanel"]["flight mode"]
            }
        }

        PlasmaCore.DataSource {
            id: stSource
            engine: "statuspanel"
            connectedSources: ["StatusPanel"]
        }
    }

    MouseArea {
        id: mouseAreaHandle

        z: 99
        anchors.fill: parent

        onPressed: {
            if(slidingPanel.visible || slidingPanel.animateRunning || nofifySlidingPanel.visible || nofifySlidingPanel.animateRunning)
                return;

            if(mouse.x < parent.width / 2) {
                nofifySlidingPanel.fixedArea.opacity = 1
                nofifySlidingPanel.offset = 0
                nofifySlidingPanel.open()
            } else {
                slidingPanel.fixedArea.opacity = 1
                slidingPanel.offset = 0
                slidingPanel.open();
            }
        }
    }

    SlidingPanel {
        id: slidingPanel

        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        openThreshold: JDisplay.dp(30)
        headerHeight: root.height + JDisplay.dp(4)

        offset: quickSettingsParent.height / 10
        drawerHeight: panelContents.width

        onClosed: {
            nofifySlidingPanel.init()
            quickSettings.closed()
        }

        contentItem: GridLayout {
            id: panelContents
            anchors.fill: parent

            DrawerBackground {
                id: quickSettingsParent
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: panelContents.width
                Layout.preferredHeight: panelContents.width//*5/6
                z: 4

                contentItem: QuickSettings {
                    id: quickSettings
                    onCloseRequested: {
                        slidingPanel.close()
                    }
                }
            }
        }
    }

    SlidingPanelNotification {
        id: nofifySlidingPanel

        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        openThreshold: JDisplay.dp(16)
        headerHeight: root.height + JDisplay.dp(4)
        drawerHeight: JDisplay.dp(155)
        direction: nofifySlidingPanel.MovementDirection.Down

        property int animationTime: root.animationTime

        Connections {
            target: notifications

            onListViewContentHeightChanged: {
                if (notifications.listViewCount === 0 ) {
                    nofifySlidingPanel.drawerHeight = JDisplay.dp(155)
                } else {
                    if ((JDisplay.dp(60) + notifications.listViewContentHeight) + JDisplay.dp(10) > JDisplay.dp(1150 / 2) + JDisplay.dp(1)) {
                        nofifySlidingPanel.drawerHeight = JDisplay.dp(1150 / 2)  + JDisplay.dp(1)
                    } else {
                        nofifySlidingPanel.drawerHeight =  notifications.listViewContentHeight + JDisplay.dp(10) + JDisplay.dp(60)  + JDisplay.dp(1)
                    }
                }
            }
        }

        onContentHeightFinished: {
            if (notifications.listViewCount === 0) {
                closeTimer.restart()
            }
        }

        Timer {
            id: closeTimer

            running: false
            repeat: false
            interval: 0
            onTriggered: {
                notifications.closeRequested()
            }
        }

        onClosed: {
            slidingPanel.init()
            notifications.backAll()
            notifications.cleanButton.reset()
        }

        contentItem: GridLayout {
            id: notifyPanelContents

            anchors.fill: parent
            DrawerBackground {
                id: notifyQuickSettingsParent
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: notifyPanelContents.width * 0.9
                Layout.preferredHeight: notifyPanelContents.height
                z: 4

                contentItem: QuickNotificationList {
                    id: notifications

                    onCloseRequested: {
                        nofifySlidingPanel.close()
                    }
                }
            }
        }
    }
}
