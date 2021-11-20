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

Rectangle{
    id: noteRect
    Item {
        id: noteItem
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
            source: appsInfo["jingnote"]["icon"] !== "" ? appsInfo["jingnote"]["icon"] : "file:///usr/share/plasma/plasmoids/org.kde.phone.homescreen/contents/image/notelogo.svg"
            scale: 1
        }
        Text {
            id: photoText
            anchors{
              left: icon.right
              leftMargin: JDisplay.dp(6)
              verticalCenter: icon.verticalCenter
            }
            text: appsInfo["jingnote"]["name"] !== "" ? appsInfo["jingnote"]["name"] : i18nd("plasma-phone-components", "Jing Notes")
            font.pixelSize: JDisplay.sp(14)
            color: "white"
        }
    }

    ListView{
        id: noteListView
        anchors{
            top: noteItem.bottom
            topMargin: JDisplay.dp(10)
            left: parent.left
            leftMargin: JDisplay.dp(10)
            right: parent.right
            rightMargin: JDisplay.dp(10)
            bottom: parent.bottom
            bottomMargin: JDisplay.dp(10)
        }
        orientation: ListView.Horizontal
        model: plasmoid.nativeInterface.negativeModel
        spacing: JDisplay.dp(9)
        delegate: noteItemDelegate
        header: headComponent
       interactive: false
        boundsBehavior: Flickable.StopAtBounds
    }
    Component{
       id:noteItemDelegate
       Rectangle{
         id: noteListItem
         width: JDisplay.dp(105)
         height: noteListView.height
         color: "transparent"
         Rectangle{
           id: defaultLoader
           anchors.fill: parent
           color: "white"
           radius: JDisplay.dp(7)
           visible: model.data_image !== "" || model.data_filepath !== ""
           Image {
               id: name
               anchors.fill: parent
               source: model.data_image === "" ? "" : "data:image/png;base64," + model.data_image//"../../image/notescreen.png"
           }
         }
         Loader{
           id:lastLoader
           anchors.fill: parent
           sourceComponent: lastComponent
           active: !defaultLoader.visible
         }
         MouseArea{
             anchors.fill: parent
             onClicked: {
                 console.log("[zhg] negative click index:" + index)
                 plasmoid.nativeInterface.negativeModel.runNoteApp(index)
             }
         }
       }
    }

    Component{
       id:lastComponent
       Rectangle{
         id: noteListItem
         width: JDisplay.dp(105)
         height: noteListView.height
         color: "#B3CBCBCB"//"#1AFFFFFF"
         radius: JDisplay.dp(7)
         Item {
             id: pathContentItem
             anchors.centerIn: parent
             height: pathImage.height + photoText.contentHeight + JDisplay.dp(15)
             width: parent.width
             Image {
                 id: pathImage
                 anchors.top: parent.top
                 anchors.horizontalCenter: parent.horizontalCenter
                 source: "../../image/Path.svg"
             }
             Text {
                 id: photoText
                 anchors{
                   top: pathImage.bottom
                   topMargin: JDisplay.dp(15)
                   horizontalCenter: pathImage.horizontalCenter
                 }
                 text: i18nd("plasma-phone-components", "New Notes")
                 font.pixelSize: JDisplay.sp(12)
                 color: "white"
             }
         }

       }
    }

    Component{
       id:headComponent
       Rectangle{
         id: noteListItem
         width: JDisplay.dp(114)
         height: noteListView.height
         color: "transparent"
         Image {
             id: name
             width: parent.width - JDisplay.dp(9)
             height: parent.height
             source: "../../image/notescreen.png"
         }
         MouseArea{
          anchors.fill: parent
          onClicked: {
           plasmoid.nativeInterface.negativeModel.runNoteApp(-1)
          }
         }
       }
    }

}
