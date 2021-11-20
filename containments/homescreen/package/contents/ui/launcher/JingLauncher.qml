/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Wang Rui <wangrui@jingos.com>
 *
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.10 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.phone.homescreen 1.0
import QtGraphicalEffects 1.6
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import jingos.display 1.0

Item {
    id: root
    anchors.fill: parent

    signal launched

    property var rootBgImageHandle
    property alias scrollAnimHandle: scrollAnim
    property int dragIconPageIndex
    property string fileIcon
    property string fileName
    property string photoIcon
    property string photoName
    property var appsInfo:{
        "photo":{"exec_name":"jinggallery","icon":""},
        "chrom":{"exec_name":"chromium-browser-stable","icon":""},
        "file":{"exec_name":"index","icon":""},
        "wps":{"exec_name":"wps","icon":""},
        "jingnote":{"exec_name":"com.asa.jingnote","icon":""}
    }

    property double marginValue: root.width / 51
    property double iconWidth: ((listView.width - marginValue * 2) / 6 - 6) * 0.35

    Image {
        id: rootBgImage
        anchors.fill: parent
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        smooth: true
        source: Wallpaper.Wallpaper.launcherWallpaper

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.06
        }
    }

    Timer {
        id: runAppTimer

        interval: 1000
        running: false
    }

    Timer {
        id: scrollTimer

        property bool isMoveNext: false

        interval: 100

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
        property bool isMoving: false
        anchors.fill: parent
        anchors.bottomMargin: footItem.height

        model: plasmoid.nativeInterface.listModelManager.launcherPageModel
        delegate: listDelegate
        focus: true
    
        z: 100

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        highlightMoveDuration: 9000
        highlightMoveVelocity: 9000
        maximumFlickVelocity: 10000

        preferredHighlightBegin: 0
        preferredHighlightEnd: 0
        highlightRangeMode: contentX < 0 ? ListView.NoHighlightRange : ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        cacheBuffer: listView.width * listView.count
        boundsBehavior: Flickable.DragOverBounds
        clip: false

        onMovementStarted: {
            isMoving = true
        }

        onMovementEnded: {
            isMoving = false
        }

        Component.onCompleted: {
          contentX = 0
        }

        // header: NegativeView {
        //     id: listViewHead
        //     height: listView.height
        //     width: listView.width
        //     visible: listView.highlightRangeMode === ListView.NoHighlightRange
        // }
        //end

        //add by huan lele
        //当前正在拖拽代理(DropArea)
        property Item dragItemParent: null
        //当前的占位符代理(DropArea)
        property Item placeHolderItem: null
        //end by huan lele
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
            
            duration: 400
            easing.type: Easing.OutQuint
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
            anchors.top: listView.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            
            visible: listView.count < 2 ? false : true

            Repeater {
                model: listView.count

                Item {
                    id: indexItem
                    width: root.iconWidth / 10 * 3
                    height: width

                    MouseArea {
                        id: mouseAreaHandle
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            if(index === listView.currentIndex) {
                                return;
                            }
                            else if(index === listView.currentIndex + 1 || index === listView.currentIndex - 1)
                            {
                                listView.currentIndex = index;
                            }
                            else if(index < listView.currentIndex)
                            {
                                listView.currentIndex = listView.currentIndex - 1;
                            }
                            else if(index > listView.currentIndex)
                            {
                                listView.currentIndex = listView.currentIndex + 1;
                            }
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
                        width: root.iconWidth / 10
                        height: width
                        radius: width / 2

                        color: "#ffffff"
                        opacity: index == listView.currentIndex ? 1 : 0.3

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
        
        Item {
            id: delegateRootItem
            width: listView.width
            height: listView.height

            Flow {
                id: launcherGrid

                anchors.top: parent.top
                anchors.topMargin: root.height / 10.1
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: root.marginValue
                anchors.right: parent.right
                anchors.rightMargin: root.marginValue

                move: Transition {
                    NumberAnimation {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                        properties: "x,y"
                    }
                }

                Repeater {
                    id: repeaterHandle
                    model: modelData //plasmoid.nativeInterface.listModelManager.getMdoelFromPage(index)

                    delegate: itemDelegate
                }
            }
        }

    }

    Component {
        id: itemDelegate

        DropArea {
            id: delegate
            width: model.modelData.location == 1 ? root.iconWidth - 1 : (listView.width - marginValue * 2) / 6 - 1   //root.cellWidth
            height: model.modelData.location == 1 ? root.iconWidth - 1  : (listView.height - root.height  / 10.1) / 4 - 1  //root.cellHeight

            opacity: 1

            signal launch(int x, int y, var source, string title)

            property alias iconItem: icon

            property int visualIndex: index
            property int visualAppInPageIndex: model.modelData.pageIndex

            property var modelData: typeof model !== "undefined" ? model : null
            property var modelExecName: model.modelData.execName

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

            onModelExecNameChanged: {
                if(model.modelData.execName === appsInfo["photo"]["exec_name"]){
                    photoIcon = model.modelData.icon
                    photoName = model.modelData.name
                    appsInfo["photo"]["icon"] = model.modelData.icon
                    appsInfo["photo"]["name"] = model.modelData.name
                    appsInfo["photo"]["storageId"] = model.modelData.storageId
                 }
                if(model.modelData.execName === appsInfo["jingnote"]["exec_name"]){
                    appsInfo["jingnote"]["icon"] = model.modelData.icon
                    appsInfo["jingnote"]["name"] = model.modelData.name
                }
                if (model.modelData.execName === appsInfo["chrom"]["exec_name"]) {
                    appsInfo["chrom"]["icon"] = model.modelData.icon
                    appsInfo["chrom"]["name"] = model.modelData.name
                    appsInfo["chrom"]["storageId"] = model.modelData.storageId
                }
                console.log(" [zhg] exec_name:" + model.modelData.execName)
                if (model.modelData.execName === appsInfo["file"]["exec_name"]) {
                    fileIcon = model.modelData.icon
                    fileName = model.modelData.name
                    appsInfo["file"]["storageId"] = model.modelData.storageId
                }
                if(model.modelData.execName === appsInfo["wps"]["exec_name"]) {
                    appsInfo["wps"]["icon"] = model.modelData.icon
                    appsInfo["wps"]["name"] = model.modelData.name
                    appsInfo["wps"]["storageId"] = model.modelData.storageId
                }
            }

            Component.onCompleted: {
                model.modelData.itemIndex = index
                iconRootHandle.visualIndex = index
                //add by huan lele
                //记录下新创建的占位符控件
                if(model.modelData.type === 0){
                    listView.placeHolderItem = delegate;
                }
                //end by huan lele
            }

            //add by huan lele
            //控件销毁时，判断下是否是记录的正在拖拽的控件的父(DropArea)或者占位符，如果是，设置为null
            Component.onDestruction: {
                console.log("destruction   " + delegate)
                if(listView.dragItemParent == delegate){
                    listView.dragItemParent = null;
                }
                if(listView.placeHolderItem == delegate){
                    listView.placeHolderItem = null;
                }
            }
            //end by huan lele

            onVisualIndexChanged: {
                if(model.modelData)
                    model.modelData.itemIndex = index
            }
            
            onContainsDragChanged: {
                if(!scrollAnim.canDropFlag)
                    return

                if(drag.source === null || scrollAnim.running || scrollTimer.running)
                    return

                if(listView.interactive)
                    return

                if(drag.source.visualIndex === undefined || delegate.visualIndex === undefined)
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
            
            Item {
                id: iconRootHandle
                //modify by huan lele
                //要实现拖拽动画，改为x y坐标，不使用锚
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.top: parent.top
                x:(delegate.width - width) / 2
                y:0
                //end by huan lele
                width: root.iconWidth
                height: root.iconWidth

                property int visualIndex: index
                property int visualAppInPageIndex: model.modelData.pageIndex

                clip: false

                //addb by huan lele
                //记录拖拽松手后需要回到的位置
                property int originX: 0
                property int originY: 0
                //end by huan lele
                Drag.active: mouseAreaHandle.drag.active
                //Drag.source: iconRootHandle
                Drag.hotSpot.x: iconRootHandle.width / 2
                Drag.hotSpot.y: iconRootHandle.height / 2

                Drag.onActiveChanged: {
                    icon.opacity = 1

                    if(Drag.active) {
                        plasmoid.nativeInterface.listModelManager.addLauncherPage(listView.count);
                    } else {
                        plasmoid.nativeInterface.listModelManager.refreshPageModel();
                        icon.scale = 1
                    }
                }

                //add by huan lele
                SequentialAnimation{
                    id:resetAni
                    ParallelAnimation{
                        PropertyAnimation{
                            target: iconRootHandle
                            properties: "x"
                            to: iconRootHandle.originX
                            duration: 150
                        }
                        PropertyAnimation{
                            target: iconRootHandle
                            properties: "y"
                            to: iconRootHandle.originY
                            duration: 150
                        }
                    }
                    ScriptAction{
                        script: {
                            listView.placeHolderItem = null;
                            iconRootHandle.parent = listView.placeHolderItem ? listView.placeHolderItem : listView.dragItemParent;
                            iconRootHandle.x = (delegate.width - iconRootHandle.width) / 2;
                            iconRootHandle.y = 0;
                            label.showText = true;

                            if(model.modelData.pageIndex === plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() || plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() < -1) {
                                //console.log("mouse released  2222222222222222 remove placeholder item and refresh location")
                                plasmoid.nativeInterface.listModelManager.removePlaceholderItem();
                                plasmoid.nativeInterface.listModelManager.refreshLocation(model.modelData.pageIndex);
                            } else {
                                //console.log("mouse released   replace place holder item to app item")
                                plasmoid.nativeInterface.listModelManager.replacePlaceholderItemToAppItem(model.modelData)
                            }

                        }
                    }
                }
                // end by huan lele

                MouseArea {
                    id: mouseAreaHandle
                    anchors.fill: parent
                    hoverEnabled: true
                    pressAndHoldInterval: 300
                    // drag.target: iconRootHandle
                    // drag.active: mouseAreaHandle.pressed;                                    

                    onPositionChanged: {
                        if(mouseAreaHandle.drag.target === null)
                            return

                        if(scrollAnim.running || scrollTimer.running)
                            return

                        if(listView.interactive)
                            return

                        if(mapToItem(listView, mouse.x, mouse.y).x < listView.width / 60) {
                            listView.setCurrentIndex(false)
                        } else if ( mapToItem(listView, mouse.x, mouse.y).x > (listView.width - listView.width / 60) ){
                            listView.setCurrentIndex(true)
                        } else {
                            scrollTimer.stop()
                        }

                        if(root.dragIconPageIndex !== model.modelData.pageIndex)
                            return

                        if(mapToGlobal(mouse.x, mouse.y).y > listView.height) {
                            if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() !== -1) {
                                plasmoid.nativeInterface.listModelManager.removePlaceholderItem()
                            } else if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() !== -10000) {
                                return
                            }

                            if(root.dragIconPageIndex !== -1) {
                                if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() === -1) {
                                    return
                                }

                                if(mapToGlobal(mouse.x, mouse.y).x < listView.width / 2)
                                    plasmoid.nativeInterface.listModelManager.addPlaceholderItem(-1, false);
                                else
                                    plasmoid.nativeInterface.listModelManager.addPlaceholderItem(-1);
                            }
                        } else {
                            if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() === -1) {
                                plasmoid.nativeInterface.listModelManager.removePlaceholderItem()
                            } else if(plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() !== -10000) {
                                return
                            }

                            if(root.dragIconPageIndex === -1) {
                                plasmoid.nativeInterface.listModelManager.addPlaceholderItem(listView.currentIndex);
                            }
                        }
                    }

                    onPressed: {
                        if(runAppTimer.running)
                            return

                        listView.interactive = false
                        scrollTimer.stop()
                        icon.scale = 0.8
                        icon.opacity = 0.4
                    }

                    onReleased: {
                        icon.opacity = 1
                        icon.scale = 1
            
                        if(runAppTimer.running)
                            return

                        listView.interactive = true
                        //remove by huan lele
                        //挪到拖拽结束后的动画中
//                        if(model.modelData.pageIndex === plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() || plasmoid.nativeInterface.listModelManager.getPlaceholderPosition() < -1) {
//                            console.log("mouse released   remove placeholder item and refresh location")
//                            plasmoid.nativeInterface.listModelManager.removePlaceholderItem();
//                            plasmoid.nativeInterface.listModelManager.refreshLocation(model.modelData.pageIndex);
//                        } else {
//                            plasmoid.nativeInterface.listModelManager.replacePlaceholderItemToAppItem(model.modelData)
//                        }
                        //end by huan lele
                        mouseAreaHandle.drag.target = null;
                        mouseAreaHandle.Drag.active = false;
                    }

                    onCanceled: {
                        icon.initState()
                    }

                    onClicked: {
                        if(runAppTimer.running)
                            return
                        runAppTimer.restart()

                        if(!plasmoid.nativeInterface.listModelManager.isAndroidApp(model.modelData.categories)) {
                            if (model.modelData.applicationRunning) {
                                delegate.toLaunch(0, 0, "", model.modelData.name);
                            } else {
                                delegate.toLaunch(delegate.x + (units.smallSpacing * 2), delegate.y + (units.smallSpacing * 2), icon.source, model.modelData.name);
                            }
                        }

                        plasmoid.nativeInterface.listModelManager.runApplication(model.modelData.storageId);
                        icon.initState()
                    }


                    onContainsMouseChanged: {
                        if(containsMouse){
                            if(runAppTimer.running)
                                return

                            icon.scale = 1.2
                            scrollTimer.stop()
                        } else {
                            icon.opacity = 1
                            icon.scale = 1
                        }
                    }
                    
                    onPressAndHold:  {
                        listView.interactive = false

                        if (iconRootHandle.Drag.active === false) {
                            root.dragIconPageIndex = model.modelData.pageIndex

                            mouseAreaHandle.drag.target = iconRootHandle;
                            mouseAreaHandle.Drag.active = true;                                    
                        }

                        icon.opacity = 1
                        icon.scale = 1
                    }

                    //add by huan lele
                    drag.onActiveChanged: {
                        if(drag.active){
                            listView.placeHolderItem = null;
                            //拖拽的时候将该控件的父设置为listview，
                            var originPos = iconRootHandle.mapToItem(listView, 0, 0);
                            iconRootHandle.parent = listView;
                            iconRootHandle.x = originPos.x;
                            iconRootHandle.y = originPos.y;
                            listView.dragItemParent = delegate
                            label.showText = false;
                        } else {
                            //停止拖拽时，首先判断是否创建了新的占位符，如果有，则松手后挪动到占位符上，否则挪动到原来的拖拽位置
                            if(listView.placeHolderItem){
                                var pos = listView.placeHolderItem.mapToItem(listView, (listView.placeHolderItem.width - iconRootHandle.width) / 2, 0);
                                iconRootHandle.originX = pos.x;
                                iconRootHandle.originY = pos.y;
                            } else if(listView.dragItemParent){
                                var pos1 = listView.dragItemParent.mapToItem(listView, (listView.dragItemParent.width - iconRootHandle.width) / 2, 0);
                                iconRootHandle.originX = pos1.x;
                                iconRootHandle.originY = pos1.y;
                            }
                            resetAni.restart();
                        }
                    }
                    //end by  huan lele
                }

                PlasmaCore.IconItem {
                    id: iconBgIcon
                    anchors.centerIn: icon

                    width: root.iconWidth
                    height: width

                    usesPlasmaTheme: false

                    source:  "file:///usr/share/icons/jing/iconBg.svg"
                    visible: !model.modelData.isSystemApp && icon.visible && !model.modelData.icon.startsWith('file:///')? true : false
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
                    anchors.centerIn: parent

                    width: iconBgIcon.visible ? iconBgIcon.width * 0.8 : iconBgIcon.width
                    height: width

                    usesPlasmaTheme: false
                    source: model.modelData ? model.modelData.icon : "file:///usr/share/icons/jing/defult.png"
                    // source: "file:///usr/share/icons/jing/"+ model.modelData.name +".svg"
                    //type === 0 占位符
                    visible: model.modelData.type === 0 ? false : true

                    z: iconBgIcon.z + 1

                    function initState() {
                        mouseAreaHandle.drag.target = null;
                        mouseAreaHandle.Drag.active = false;   
                        root.dragIconPageIndex =  -10000
                        listView.interactive = true
                        root.dragIconPageIndex = null
                        scrollTimer.stop()
                        icon.opacity = 1
                        icon.scale = 1
                    }

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
                    visible: icon.scale !== 1 || mouseAreaHandle.drag.active ? false : true
                }
            }

            Text {
                id: label
                anchors.top: iconRootHandle.bottom
                anchors.topMargin: icon.width / 8
                anchors.left: parent.left
                anchors.leftMargin: parent.width / 9
                anchors.right: parent.right
                anchors.rightMargin: parent.width / 9
                anchors.bottom: parent.bottom
                anchors.bottomMargin: icon.height / 20
                visible: text.length > 0 && icon.visible && model.modelData.location !== 1
                //add by huan lele
                property bool showText: true
                //end by huan lele
                // Layout.fillWidth: true

                // anchors.horizontalCenter: icon.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 3
                elide: Text.ElideRight
                wrapMode: Text.WordWrap

                text: model.modelData.name
                //modify by huan lele
                //opacity: mouseAreaHandle.drag.active === true || label.showText === false ? 0 : 1
                opacity: label.showText === false ? 0 : 1
                //end by huan lele

                //FIXME: export smallestReadableFont
                font.pixelSize:  JDisplay.sp(11)
                color: "#ffffff"//model.applicationLocation == ApplicationListModel.Desktop ? "white" : theme.textColor

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }
            DropShadow {
                anchors.fill: label
                //visible: mouseAreaHandle.drag.active ? false : true
                visible: label.opacity === 1.0
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4.0
                samples: 17
                cached: true
                color: Qt.rgba(0,0,0,0.2)
                source: label
            }
        }
    }

    Item {
        id: footItem
        anchors.bottom: parent.bottom
        width: root.width
        height: root.iconWidth  * 2
        property bool initFinished: false
        Component.onCompleted: {
            delayTimer.start();
        }

        Timer{
            id:delayTimer
            interval: 300
            running: false
            onTriggered: {
                footItem.initFinished = true;
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            x:(parent.width - width) / 2
            width: dockRepeater.count < 3 ? (root.iconWidth * 3 + favoriteAppRow.spacing * 4)  : favoriteAppRow.implicitWidth + favoriteAppRow.spacing * 2
            height: root.iconWidth * 1.35
            clip: true

            Behavior on width {
                enabled:footItem.initFinished
                NumberAnimation { duration: 100 }
            }
            Kirigami215.JBlurBackground{
                anchors.fill: parent
				radius: JDisplay.dp(20)
                backgroundOpacity: 0.3
                sourceItem: rootBgImage
            }

            Row {
                id: favoriteAppRow
                anchors.verticalCenter: parent.verticalCenter
                x: favoriteAppRow.spacing
                spacing: root.iconWidth * 0.25

                Repeater {
                    id: dockRepeater
                    model:plasmoid.nativeInterface.listModelManager.getFavoriteAppMdoel()

                    z: 50
                    delegate: itemDelegate
                }
            }
        }


//        ShaderEffectSource {
//            id: effectSource
//            //anchors.centerIn: parent
//            anchors.verticalCenter: parent.verticalCenter
//            x:(parent.width - width) / 2
//            width: dockRepeater.count < 3 ? (root.iconWidth * 3 + favoriteAppRow.spacing * 4)  : favoriteAppRow.implicitWidth + favoriteAppRow.spacing * 2
//            height: root.iconWidth * 1.35

//            sourceItem: rootBgImage
//            sourceRect: Qt.rect(x,
//                                rootBgImage.height - effectSource.height - (footItem.height - effectSource.height) / 2,
//                                effectSource.width,
//                                effectSource.height)
//            visible: false

////             Behavior on width {
////                 NumberAnimation { duration: 2000 }
////             }
//        }

//        FastBlur {
//            id: fastBlur
//            anchors.fill: effectSource
//            source: effectSource
//            radius: 50
//            visible: false
//        }

//        OpacityMask {
//            id: mask
//            anchors.fill: fastBlur
//            source: fastBlur
//            maskSource: dockBgRectangle
//            visible: true
//        }

//        Rectangle {
//            id: dockBgRectangle
//            anchors.fill: effectSource

//            color: "#ffffff"
//            opacity: 0.3
//            radius: height / 3
//            visible: true
//            clip: true
//        }

//        Row {
//            id: favoriteAppRow
//            anchors.centerIn: dockBgRectangle
//            spacing: root.iconWidth * 0.25

//            Repeater {
//                id: dockRepeater
//                model:plasmoid.nativeInterface.listModelManager.getFavoriteAppMdoel()

//                z: 50
//                delegate: itemDelegate
//            }
//        }
    }
}
