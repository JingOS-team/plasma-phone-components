/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.0
import QtQml 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick 2.0
import QtQml 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

Item {
    id: root

    property bool enable
    property color bgcolor : "#00000000"
    property alias text: text.text
    property real fontSize
    signal clicked()

    Rectangle {
        width: parent.width
        height: parent.height
        radius: 7
        clip: true

        color: bgcolor

        Control {
            anchors.fill: parent
            padding: 7
            RowLayout {
                height: parent.availableHeight
                width: parent.availableWidth
                anchors.centerIn: parent
                clip: true

                Label {
                    id: text
                    width: contentWidth
                    height: contentHeight
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    // verticalAlignment: Text.AlignCenter
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.clicked()
            }
            hoverEnabled: true

            onEntered: {
                hoverMask.visible = true
            }

            onExited: {
                hoverMask.visible = false
            }

            onPressed: {
                touchMask.visible = true
            }

            onReleased: {
                touchMask.visible = false
            }
        }
    }

    Rectangle {
        id: hoverMask
        visible: false
        width: parent.width
        height: parent.height
        radius: 7
        color: "#9F9FAA"
        opacity: 0.2
    }

    Rectangle {
        id: touchMask
        visible: false
        width: parent.width
        height: parent.height
        radius: 7
        color: "#9F9FAA"
        opacity: 0.3

        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
        }
    }
}

