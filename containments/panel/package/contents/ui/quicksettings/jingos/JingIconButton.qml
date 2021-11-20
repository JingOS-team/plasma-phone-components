/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.2
import org.kde.kirigami 2.0
import QtQuick.Controls 2.14 as QQC2
import org.kde.kirigami 2.0 as Kirigami

Item  {
    id: control

    property string source: ""
    property var color: ""

    //define the image disable status url load path
    property string disableSource: ""

    property bool darkMode: applicationWindow().darkMode
    property bool hoverEnabled: true
    property bool sizeSet: false
    property int defSizeWidth: 0
    property int defSizeHeight: 0
    property int iconRadius: 15
    property var backgroundColor: ""

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    height: sizeSet? defSizeHeight : Math.max(icon.height, icon.implicitHeight) + 10
    width: sizeSet? defSizeWidth : Math.max(icon.width, icon.implicitWidth) + 10

    PrivateMouseHover {
        visible: control.hoverEnabled ? true : false
        darkMode: control.darkMode
        radius: iconRadius
        color: backgroundColor ? backgroundColor : "transparent"
    }

    Kirigami.Icon {
        id:icon
        width: defSizeWidth
        height: defSizeHeight
        anchors.centerIn: parent
        color: control.color
        source: control.enabled ? control.source : (control.disableSource.length > 0 ? control.disableSource: control.source)
    }

    Component.onCompleted:{
        if(!sizeSet){
            if (control.width == 0 || control.height == 0) {
                control.width = Qt.binding(function() {return Math.max(icon.width, icon.implicitWidth) + 10});
                control.height = Qt.binding(function() {return Math.max(icon.height, icon.implicitHeight)+ 10});
            } else {
                defSizeWidth = Qt.binding(function() {return control.width - 10});
                defSizeHeight = Qt.binding(function() {return control.height - 10});
            }
        }
    }
}
