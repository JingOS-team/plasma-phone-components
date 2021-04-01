/***************************************************************************
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>                      *
 *                                                                         *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.phone.homescreen 1.0
import QtGraphicalEffects 1.6
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    anchors.fill: parent

    signal launched

    property var rootBgImageHandle
    property alias scrollAnimHandle: scrollAnim
    property int dragIconPageIndex

    Image {
        id: rootBgImage
        anchors.fill: parent
        smooth: true
        source: "file:///usr/share/icons/jing/bg.png"
    }


    Timer {
        id: scrollTimer

        property bool isMoveNext: false

        interval: 1000

        onTriggered: {
            if (scrollAnim.running)
                return;
            if (isMoveNext && listView.currentIndex < listView.count - 1) {
                listView.scrollNextPage();
            } else if (!isMoveNext && listView.currentIndex > 0) {
                listView.scrollPreviousPage();
            } else {
                scrollTimer.stop();
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.topMargin: parent.height / 10.1
        anchors.bottomMargin: footItem.height
        anchors.leftMargin: root.width / 51
        anchors.rightMargin: root.width / 51

        model: plasmoid.nativeInterface.listModelManager.launcherPageModel
        delegate: listDelegate
        focus: true
        
        z: 100
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        maximumFlickVelocity: 10000
        highlightMoveDuration: 100

        preferredHighlightBegin: 0
        preferredHighlightEnd: 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        cacheBuffer: listView.width * listView.count
        boundsBehavior: Flickable.DragOverBounds
        clip: false

        displaced: Transition {
            SpringAnimation {
                property: "y"
                spring: 3
                damping: 0.1
                epsilon: 0.25
                duration: 1000
            }
        }

        NumberAnimation on contentX {
            id: scrollAnim
            
            duration: 1000
            property bool canDropFlag: true

            onStopped: {
                //! fix current index
                var index = listView.indexAt(listView.contentX+listView.width/2, listView.contentY+listView.height/2);
                if (index === -1) 
                    listView.currentIndex = 0;
                else {
                    listView.currentIndex = index;
                }
                scrollAnim.canDropFlag = true;
            }
        }

        function setCurrentIndex(isNext) {
            scrollTimer.isMoveNext = isNext
            scrollTimer.restart()
        }

        function scrollNextPage() {
            if (currentIndex < count-1) {
                scrollAnim.canDropFlag = false;
                plasmoid.nativeInterface.listModelManager.removePlaceholderItem()
                plasmoid.nativeInterface.listModelManager.addPlaceholderItem(listView.currentIndex + 1);
                scrollAnim.to = listView.currentItem.x + listView.width;
                scrollAnim.restart();
            }
        }

        function scrollPreviousPage() {
            if (currentIndex > 0) {
                scrollAnim.canDropFlag = false
                plasmoid.nativeInterface.listModelManager.removePlaceholderItem()
                plasmoid.nativeInterface.listModelManager.addPlaceholderItem(listView.currentIndex - 1);
                scrollAnim.to = listView.currentItem.x - listView.width;
                scrollAnim.restart();
            }
        }

        Row {
            anchors.bottom: listView.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            
            visible: listView.count < 2 ? false : true

            Repeater {
                model: listView.count

                Item {
                    id: indexItem
                    width: 30
                    height: width

                    MouseArea {
                        id: mouseAreaHandle
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            listView.currentIndex = index
                        }

                        onReleased: {
                            indexRectangle.scale = 1
                        }

                        onCanceled: {
                            indexRectangle.scale = 1
                        }

                        onEntered: {
                            indexRectangle.scale = 1.2
                        }

                        onExited: {
                            indexRectangle.scale = 1
                        }
                    }

                    Rectangle {
                        id: indexRectangle
                        anchors.centerIn: parent
                        width: 10
                        height: width
                        radius: width / 2

                        color: index == listView.currentIndex ? "#ffffff" : "grey"

                        opacity: index == listView.currentIndex ? 1 : 0.5

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 300 }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: listDelegate

        Flow {
            id: launcherGrid

            width: listView.width
            height: listView.height

            move: Transition {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                    properties: "x,y"
                }
            }

            Repeater {
                id: repeaterHandle
                model: plasmoid.nativeInterface.listModelManager.getMdoelFromPage(index)

                delegate:  itemDelegate
            }
        }
    }

    Component {
        id: itemDelegate

        DropArea {
            id: delegate
            width: model.modelData.location == 1 ? footItem.iconWidthAndHeight : listView.width / 6  //root.cellWidth
            height: model.modelData.location == 1 ? footItem.iconWidthAndHeight : listView.height / 4  //root.cellHeight

            opacity: 1

            signal launch(int x, int y, var source, string title)

            property alias iconItem: icon

            property int visualIndex: index
            property int visualAppInPageIndex: model.modelData.pageIndex

            property var modelData: typeof model !== "undefined" ? model : null

            readonly property int reservedSpaceForLabel: metrics.height
            property int availableCellHeight: units.iconSizes.huge + reservedSpaceForLabel

            Binding { target: iconRootHandle; property: "visualIndex"; value: visualIndex }
            Binding { target: iconRootHandle; property: "visualAppInPageIndex"; value: visualAppInPageIndex }

            function toLaunch(x, y, icon, title) {
                if (icon !== "") {
                    NanoShell.StartupFeedback.open(
                                icon,
                                title,
                                delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                                delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                                Math.min(delegate.iconItem.width, delegate.iconItem.height));
                }
                root.launched();
            }

            Component.onCompleted: {
                model.modelData.itemIndex = index
                iconRootHandle.visualIndex = index
            }

            onContainsDragChanged: {
                if(!scrollAnim.canDropFlag)
                    return

                if(drag.source === null || scrollAnim.running)
                    return
                    
                if(!scrollAnim.canDropFlag)
                    return

                if(drag.source.visualIndex === delegate.visualIndex || drag.source.visualIndex === undefined || delegate.visualIndex === undefined)
                    return;

                if(model.modelData.location == 1 ) {
                    if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() < -1 && root.dragIconPageIndex !== -1)
                        plasmoid.nativeInterface.listModelManager.addPlaceholderItem(-1);                                          

                    if( root.dragIconPageIndex === -1 ) {
                        plasmoid.nativeInterface.listModelManager.moveItem(drag.source.visualIndex, delegate.visualIndex, root.dragIconPageIndex);
                    } else {
                        plasmoid.nativeInterface.listModelManager.movePlaceholderItem(delegate.visualIndex)
                    }
                } else {
                    if( listView.currentIndex === root.dragIconPageIndex) {
                        plasmoid.nativeInterface.listModelManager.moveItem(drag.source.visualIndex, delegate.visualIndex, root.dragIconPageIndex);
                    } else {
                        if(root.dragIconPageIndex !==  model.modelData.pageIndex) {
                            plasmoid.nativeInterface.listModelManager.addPlaceholderItem(listView.currentIndex);
                        }
                        plasmoid.nativeInterface.listModelManager.movePlaceholderItem(delegate.visualIndex)
                    }
                }
            }

            onVisualIndexChanged: {
                model.modelData.itemIndex = index
            }

            Behavior on x {
                NumberAnimation { duration: 1000 }
            }
            Behavior on y {
                NumberAnimation { duration: 1000 }
            }

            Controls.Label {
                id: metrics
                text: "M\nM"
                visible: false
                font.pointSize: theme.defaultFont.pointSize * 1
            }
            
            Item {
                id: iconRootHandle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                width: icon.iconWidth
                height: icon.iconWidth

                property int visualIndex: index
                property int visualAppInPageIndex: model.modelData.pageIndex

                clip: false

                Drag.active: mouseAreaHandle.drag.active
                Drag.source: iconRootHandle
                Drag.hotSpot.x: iconRootHandle.width / 2
                Drag.hotSpot.y: iconRootHandle.height / 2

                Drag.onActiveChanged: {
                    if(Drag.active) {
                        plasmoid.nativeInterface.listModelManager.addLauncherPage(listView.count);
                    } else {
                        plasmoid.nativeInterface.listModelManager.refreshPageModel();
                    }
                }

                states: [
                    State {
                        when: iconRootHandle.Drag.active
                        ParentChange {
                            target: iconRootHandle
                            parent: listView
                        }

                        AnchorChanges {
                            target: iconRootHandle
                            anchors.horizontalCenter: undefined
                            anchors.top: undefined
                        }
                    }
                ]

                MouseArea {
                    id: mouseAreaHandle
                    anchors.fill: parent
                    hoverEnabled: true
                    // drag.target: iconRootHandle

                    onPositionChanged:  {
                        if(scrollAnim.running)
                            return

                        if(mapToItem(listView, mouse.x, mouse.y).x < listView.width / 60) {
                            listView.setCurrentIndex(false)
                        } else if ( mapToItem(listView, mouse.x, mouse.y).x > (listView.width - listView.width / 60) ){
                            listView.setCurrentIndex(true)
                        } else {
                            scrollTimer.stop()
                        }

                        if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() >= -1)
                            return;

                        if(model.modelData.location == 1 ) {
                            if(mapToItem(listView, mouse.x, mouse.y).y < listView.height) {
                                if(root.dragIconPageIndex === model.modelData.pageIndex && listView.interactive)
                                    plasmoid.nativeInterface.listModelManager.addPlaceholderItem(listView.currentIndex);
                            }
                        } else {
                            if(mapToItem(footItem, mouse.x, mouse.y).y > 0) {
                                if(root.dragIconPageIndex === model.modelData.pageIndex && listView.interactive)
                                    plasmoid.nativeInterface.listModelManager.addPlaceholderItem(-1);
                            }
                        }
                    }

                    onPressed: {
                        scrollTimer.stop()
                        icon.opacity = 0.4
                    }

                    onReleased: {
                        icon.opacity = 1
                        scrollTimer.stop()
                        listView.interactive = true

                        if(model.modelData.pageIndex === plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() || plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() < -1) {
                            plasmoid.nativeInterface.listModelManager.removePlaceholderItem();
                            plasmoid.nativeInterface.listModelManager.refreshLocation(model.modelData.pageIndex);
                        } else {
                            plasmoid.nativeInterface.listModelManager.replacePlaceholderItemToAppItem(model.modelData)
                        }
                    }

                    onCanceled: {
                        scrollTimer.stop()
                        icon.opacity = 1
                        icon.scale = 1
                        listView.interactive = true
                    }

                    onClicked: {
                        if (model.modelData.applicationRunning) {
                            delegate.toLaunch(0, 0, "", model.modelData.name);
                        } else {
                            delegate.toLaunch(delegate.x + (units.smallSpacing * 2), delegate.y + (units.smallSpacing * 2), icon.source, model.modelData.name);
                        }

                        plasmoid.nativeInterface.listModelManager.runApplication(model.modelData.storageId, model.modelData.window);
                    }

                    onEntered: {
                        icon.scale = 1.2
                        scrollTimer.stop()
                    }

                    onExited: {
                        icon.scale = 1
                        icon.opacity = 1
                        scrollTimer.stop()
                    }

                    onPressAndHold:  {
                        if (iconRootHandle.Drag.active === false) {
                            root.dragIconPageIndex = model.modelData.pageIndex

                            mouseAreaHandle.drag.target = iconRootHandle;
                            mouseAreaHandle.Drag.active = true;                                    
                        }

                        icon.opacity = 1
                        icon.scale = 1
                        // listView.interactive = false
                    }
                }

                PlasmaCore.IconItem {
                    id: iconBgIcon

                    anchors.fill: parent
                    
                    usesPlasmaTheme: false
                    source:  "file:///usr/share/icons/jing/iconBg.svg"
                    visible: !model.modelData.isSystemApp && icon.visible ? true : false
                    scale: icon.scale
                    opacity: icon.opacity
                }

                DropShadow {
                    anchors.fill: iconBgIcon
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 10.0
                    samples: 16
                    cached: true
                    color: Qt.rgba(0, 0, 0, 0.2)
                    source: iconBgIcon
                    visible:  iconBgIcon.visible && icon.scale === 1 && !mouseAreaHandle.drag.active ? true : false 
                }

                PlasmaCore.IconItem {
                    id: icon

                    width: iconBgIcon.visible ? icon.iconWidth * 0.8 : icon.iconWidth
                    height: iconBgIcon.visible ? icon.iconWidth * 0.8 : icon.iconWidth

                    anchors.centerIn: parent

                    property int iconWidth: listView.width / 24

                    usesPlasmaTheme: false
                    source: model.modelData ? model.modelData.icon : "file:///usr/share/icons/jing/defult.png"
                    // source: "file:///usr/share/icons/jing/"+ model.modelData.name +".svg"

                    scale: 1

                    visible: model.modelData.type === 0 ? false : true
                    z: iconBgIcon.z + 1

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }

                    onStatusChanged:  {
                        if(status === Image.Error) {
                            icon.source = "file:///usr/share/icons/jing/defult.svg"
                        }
                    }
                }

                DropShadow {
                    anchors.fill: icon
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 10.0
                    samples: 16
                    cached: true
                    color: Qt.rgba(0, 0, 0, 0.2)
                    source: icon
                    visible: icon.scale > 1 || mouseAreaHandle.drag.active ? false : true
                }
            }

            PlasmaComponents.Label {
                id: label
                visible: text.length > 0 && icon.visible
                anchors.top: iconRootHandle.bottom
                anchors.topMargin: units.smallSpacing * 2
                anchors.left: parent.left
                anchors.leftMargin: units.smallSpacing * 2
                anchors.right: parent.right
                anchors.rightMargin: units.smallSpacing * 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: units.smallSpacing * 2

                Layout.fillWidth: true
                // Layout.preferredHeight: delegate.reservedSpaceForLabel * 3
                        
                wrapMode: Text.WordWrap
                // anchors.horizontalCenter: icon.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 2
                elide: Text.ElideRight

                text: model.modelData.name
                opacity: mouseAreaHandle.drag.active ? 0 : 1

                //FIXME: export smallestReadableFont
                font.pointSize: theme.defaultFont.pointSize - 2
                color: "white"//model.applicationLocation == ApplicationListModel.Desktop ? "white" : theme.textColor

                layer.enabled: true//model.applicationLocation == ApplicationListModel.Desktop
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 10.0
                    samples: 16
                    cached: true
                    color: Qt.rgba(0, 0, 0, 0.4)
                }

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }
        }
    }

    Item {
        id: footItem
        anchors.bottom: parent.bottom
        width: root.width
        height: footItem.iconWidthAndHeight  * 2

        property int iconWidthAndHeight: listView.width / 24

        ShaderEffectSource {
            id: effectSource
            anchors.top: footItem.top
            anchors.bottom: footItem.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: footItem.horizontalCenter
            
            property point mapPoint: effectSource.mapToItem(rootBgImage, effectSource.x, effectSource.y)

            width: dockRepeater.count < 3 ? (footItem.iconWidthAndHeight * 3 + 140)  : favoriteAppRow.implicitWidth + 60

            sourceItem: rootBgImage
            sourceRect: Qt.rect(x,
                                mapPoint.y, 
                                effectSource.width, 
                                effectSource.height)
            visible: false

                        
            // Behavior on width {
            //     NumberAnimation { duration: 300 }
            // }
        }

        FastBlur {
            id: fastBlur
            anchors.fill: effectSource
            source: effectSource
            radius: 50
            visible: false
        }

        OpacityMask {
            id: mask
            anchors.fill: fastBlur
            source: fastBlur
            maskSource: dockBgRectangle
            visible: true
        }

        Rectangle {
            id: dockBgRectangle
            anchors.fill: effectSource

            color: "#ffffff"
            opacity: 0.3
            radius: height / 3
            visible: true
            clip: true
        }

        Row {
            id: favoriteAppRow
            anchors.centerIn: dockBgRectangle
            spacing: 40

            Repeater {
                id: dockRepeater
                model:plasmoid.nativeInterface.listModelManager.getFavoriteAppMdoel()

                z: 50
                delegate:  itemDelegate
            }
        }
    }
}
