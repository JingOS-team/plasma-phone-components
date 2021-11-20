/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
import QtQuick 2.15
import QtQuick.Layouts 1.3
import jingos.display 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.10 as Kirigami

Rectangle{
    id:negativeRect
    property var photoFetureDatas: plasmoid.nativeInterface.listModelManager.getFetureImages()
    property bool listViewMoving: listView.moving
    property bool isSwitchPage: true

    onListViewMovingChanged: {
        console.log(" [zhg] moving end: isSwitchPage:" + isSwitchPage + " listViewMoving:" + listViewMoving
                    +" visible:" + visible)
       if(!listViewMoving & visible & isSwitchPage){
           photoFetureDatas = plasmoid.nativeInterface.listModelManager.getFetureImages()
//           plasmoid.nativeInterface.negativeModel.loadNegativeData()
           plasmoid.nativeInterface.negativeModel.loadDocData()
           isSwitchPage = false
       }
    }

    onVisibleChanged: {
        if(!visible){
            isSwitchPage = true
        }
    }

    function toLaunch(x, y, icon, title,storageId) {
        var isRunning =plasmoid.nativeInterface.listModelManager.applicationRunning(storageId)
        console.log(" [zhg] storageId:" + storageId + " isRunning:" + isRunning + " icon" + icon)
        if (!isRunning && icon !== "") {
            NanoShell.StartupFeedback.open(
                        icon,
                        title,
                        x,
                        y,
                        iconWidth);
        }
        root.launched();
    }

    color: "#00000000"
    Clock{
        id: timeClock
        anchors{
            top: parent.top
            topMargin: root.height / 10.1
            left: parent.left
            leftMargin: JDisplay.dp(76)
        }
        width: JDisplay.dp(260)
        height: JDisplay.dp(111)
    }
    Row{
        id: negativeRow
        width: parent.width
        height: parent.height
        anchors{
            left: timeClock.left
            top: timeClock.bottom
            topMargin: JDisplay.dp(15)
        }
        spacing: JDisplay.dp(15)

        Column{
            id: leftColumn
            width: JDisplay.dp(473)
            height: parent.height
            spacing: JDisplay.dp(15)
            NegativeFilesView {
              width: JDisplay.dp(473)
              height: JDisplay.dp(205)
              color: "#CC444C4E"
              radius: JDisplay.dp(19)
            }
            Row{
                spacing: JDisplay.dp(15)
                 PlasmaCore.IconItem {

                    id: redImage
                    width: JDisplay.dp(229)
                    height: JDisplay.dp(110)
                    source: Qt.resolvedUrl("../../image/red.png")
                    usesPlasmaTheme: false
                    HoverRectangle {
                        id: xuexiRectangle
                        anchors.fill: parent
                        onRectClicked: {
                            var mx = redImage.Kirigami.ScenePosition.x + iconWidth/2
                            var my = redImage.Kirigami.ScenePosition.y + iconWidth/2
                            toLaunch(mx,my,appsInfo["chrom"]["icon"],appsInfo["chrom"]["name"],appsInfo["chrom"]["storageId"])
                            plasmoid.nativeInterface.listModelManager.openWebUrl("https://www.xuexi.cn")
                        }
                    }
                }
                PlasmaCore.IconItem {
                    id: whiteImage
                    width: JDisplay.dp(229)
                    height: JDisplay.dp(110)
                    source: Qt.resolvedUrl("../../image/white.png")
                    usesPlasmaTheme: false
                    HoverRectangle {
                        id: ccpsRectangle
                        anchors.fill: parent
                        rectRadius: JDisplay.dp(17)
                        onRectClicked: {
                            var mx = whiteImage.Kirigami.ScenePosition.x + iconWidth/2
                            var my = whiteImage.Kirigami.ScenePosition.y + iconWidth/2
                            toLaunch(mx,my,appsInfo["chrom"]["icon"],appsInfo["chrom"]["name"],appsInfo["chrom"]["storageId"])
                            plasmoid.nativeInterface.listModelManager.openWebUrl("https://www.ccps.gov.cn")
                        }
                    }
                }
            }

        }
        Column{
            id: rightColumn
            width: JDisplay.dp(229)
            height: parent.height
            spacing: JDisplay.dp(15)
            Rectangle{
                width: parent.width
                height: JDisplay.dp(205)
                color: "#FFFFFF"
                radius: JDisplay.dp(19)
                Item {
                    id: photoItem
                    anchors{
                      top: parent.top
                      topMargin: JDisplay.dp(11)
                      left: parent.left
                      leftMargin: JDisplay.dp(11)
                    }
                    width: parent.width
                    height: JDisplay.dp(20)
                    PlasmaCore.IconItem {
                        id: icon

                        width: JDisplay.dp(20)
                        height: width

                        usesPlasmaTheme: false
                        source: photoIcon !== "" ? photoIcon : "file:///usr/share/icons/jing/defult.png"
                        scale: 1
                    }
                    Text {
                        id: photoText
                        anchors{
                          left: icon.right
                          leftMargin: JDisplay.dp(6)
                          verticalCenter: icon.verticalCenter
                        }
                        text: photoName
                        font.pixelSize: JDisplay.sp(14)
                        color: "black"
                    }
                }
                Component{
                       id:nullComponent

                       Rectangle{
                           id:nullPageView
                           width: tipText.width
                           color: "transparent"
                           height: nullImage.height + tipText.height

                           Image {
                               id: nullImage
                               anchors{
                                   top: parent.top
                                   horizontalCenter: parent.horizontalCenter
                               }
                               source: "../../image/null_image.png"
                               width: JDisplay.dp(60)
                               height: width
                           }

                           Text {
                               id:tipText
                               width:JDisplay.dp(149)
                               anchors{
                                   horizontalCenter: nullImage.horizontalCenter
                                   top: nullImage.bottom
//                                   topMargin: nullImage.height/5
                               }
                               horizontalAlignment: Text.AlignHCenter
                               color: "#4D3C3C43"
                               font.pixelSize: JDisplay.sp(14)
                               wrapMode: Text.WrapAnywhere
                               maximumLineCount: 2
                               text: i18nd("plasma-phone-components", "There are no photos at present")
                           }
                       }
                   }

                Loader{
                   id:nullLoader
                   anchors.centerIn: parent
                   sourceComponent: nullComponent
                   active: !grid.visible
                }


                GridLayout{
                    id: grid
                    columns: 4
                    rows: 3
                    visible: photoFetureDatas[0] !== ""
                    anchors{
                        top: photoItem.bottom
                        topMargin: JDisplay.dp(10)
                        left: parent.left
                        leftMargin: JDisplay.dp(10)
                        right: parent.right
                        rightMargin: JDisplay.dp(10)
                        bottom: parent.bottom
                        bottomMargin: JDisplay.dp(10)
                    }

                    ImageRadius {
                        Layout.columnSpan: 2
                        Layout.rowSpan: 1

                        url: photoFetureDatas[0]
                    }
                    ImageRadius {
                        Layout.columnSpan: 2
                        Layout.rowSpan: 2
                        url: photoFetureDatas[1]
                    }
                    ImageRadius {
                        Layout.columnSpan: 2
                        Layout.rowSpan: 2
                        url: photoFetureDatas[2]
                    }
                    ImageRadius {
                        url: photoFetureDatas[3]
                    }
                    ImageRadius {
                        url: photoFetureDatas[4]
                    }
                }

            }
            MediaPlayer{
                width: parent.width
                height: JDisplay.dp(110)
                radius: JDisplay.dp(19)
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#2771DF" }
                    GradientStop { position: 1.0; color: "#9249F2"; }
                }
            }
        }
    }

}
