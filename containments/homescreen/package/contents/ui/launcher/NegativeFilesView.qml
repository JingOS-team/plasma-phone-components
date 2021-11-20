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
            source: fileIcon !== "" ? fileIcon : ""
            scale: 1
        }
        Text {
            id: photoText
            anchors{
              left: icon.right
              leftMargin: JDisplay.dp(6)
              verticalCenter: icon.verticalCenter
            }
            text: fileName
            font.pixelSize: JDisplay.sp(14)
            color: "white"
        }
    }

    GridView {
        id: detailGrid
        property bool movementEndd
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
        onMovementStarted: {
            movementEndd = false
        }

        onMovementEnded: {
            movementEndd = true
        }
        width: parent.width
        height: JDisplay.dp(156)
        cellWidth: width / 3
        cellHeight: cellWidth / 2 + JDisplay.dp(4)
        clip: true
        model: plasmoid.nativeInterface.negativeModel
        delegate: fileitemDelegate
        interactive: false
        visible: detailGrid.count > 0
    }

    Rectangle{
        id:background
      anchors.fill: detailGrid
      color: "#1ACBCBCB"
      radius: JDisplay.dp(13)
      visible: !detailGrid.visible
    }
    Component{
       id:fileitemDelegate
       Item {
           id: name
           width: detailGrid.cellWidth
           height: detailGrid.cellHeight
           Rectangle{
             id: noteListItem
             anchors.centerIn: parent
             width: detailGrid.cellWidth - JDisplay.dp(9)
             height: detailGrid.cellHeight - JDisplay.dp(9)
             color: "#1ACBCBCB"
             radius: JDisplay.dp(13)

             PlasmaCore.IconItem  {
                 id: fileTypeImage
                 anchors{
                     left: parent.left
                     verticalCenter: parent.verticalCenter
                 }
                 width: JDisplay.dp(60)
                 height: width
                 usesPlasmaTheme: false
                 source: Qt.resolvedUrl(model.data_image)
                 antialiasing:true
             }
             Column{
                 anchors{
                     left: fileTypeImage.right
                     leftMargin: JDisplay.dp(6)
                     verticalCenter: fileTypeImage.verticalCenter
                 }
                 width: parent.width - fileTypeImage.width - JDisplay.dp(14)
                 height: fileNameText1.contentHeight + size.contentHeight + JDisplay.dp(5)
                 spacing: JDisplay.dp(5)
                 Text {
                     id: fileNameText1
                     width:parent.width
                     text: model.data_filename//fileName + "word wordwordopenwordwordopenwordwordopenwordnotenot"
                     font.pixelSize: JDisplay.sp(12)
                     color: "white"
                     wrapMode: Text.WrapAnywhere
                     maximumLineCount: 2
                     elide: Text.ElideRight
                     clip: true
                 }
                 Text {
                     id: size
                     width:parent.width
                     text: model.data_filesize
                     font.pixelSize: JDisplay.sp(10)
                     color: "#F7F7F7"
                     wrapMode: Text.WrapAnywhere
                     maximumLineCount: 2
                     elide: Text.ElideMiddle
                     clip: true
                     opacity: 0.5
                 }
             }

             HoverRectangle {
                 rectRadius: JDisplay.dp(13)
                 anchors.fill: parent
                 visible: model.data_filepath !== ""
                 onRectClicked: {
                     console.log("[zhg] fileNegative click index:" + index + " model.data_filepath:" + model.data_filepath)
                     var mapItem = mapToItem(root, mouse.x, mouse.x)
                     toLaunch(mapItem.x,mapItem.y,appsInfo["wps"]["icon"],appsInfo["wps"]["name"],appsInfo["wps"]["storageId"])
                     plasmoid.nativeInterface.listModelManager.openWithApp(appsInfo["wps"]["storageId"],"file://"+model.data_filepath)
                 }
             }
           }
       }

    }

    Component{
           id:nullComponent

           Rectangle{
               id:nullPageView
               width: tipText.width + nullImage.width
               color: "transparent"
               height: nullImage.height

               Image {
                   id: nullImage
                   anchors{
                       left: parent.left
                   }
                   source: "../../image/null_file.png"
                   width: JDisplay.dp(50)
                   height: width
               }

               Text {
                   id:tipText
                   anchors{
                       verticalCenter: nullImage.verticalCenter
                       left: nullImage.right
                   }
                   horizontalAlignment: Text.AlignHCenter
                   color: "#80FFFFFF"
                   font.pixelSize: JDisplay.sp(14)
                   text: i18nd("plasma-phone-components", "There are no files at present")
               }
           }
       }

    Loader{
       id:nullLoader
       anchors.centerIn: background
       sourceComponent: nullComponent
       active: !detailGrid.visible
    }
}
