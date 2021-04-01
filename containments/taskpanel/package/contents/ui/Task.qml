/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *   Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick 2.14

Item {
    id: delegate
    width: tasksView.width
    height: tasksView.height

    //Workaround
    property bool active: model.IsActive
    onActiveChanged: {
        //sometimes the task switcher window itself appears, screwing up the state
        if (model.IsActive) {
           // window.currentTaskIndex = index
        }
    }

    function syncDelegateGeometry() {
        let pos = pipeWireLoader.mapToItem(tasksView, 0, 0);
        if (window.visible) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
        } else {
          //  tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, delegate.width, delegate.height), dummyWindowTask);
        }
    }

    Connections {
        target: window
        function onVisibleChanged() {
            syncDelegateGeometry();
        }
    }

    Component.onCompleted: syncDelegateGeometry();

    Item {
        width: parent.width 
        height: parent.height 

        x: index !== tasksView.currentIndex ? tasksView.currentMargins : 0

        Behavior on x {
            PropertyAnimation {duration: tasksView.animationNum }
        }
        Behavior on y {
            PropertyAnimation {duration: tasksView.animationNum }
        }

        SequentialAnimation {
            id: slideAnim
            property alias to: internalSlideAnim.to

            NumberAnimation {
                id: internalSlideAnim
                target: background
                properties: "y"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (background.y != 0) {
                        tasksModel.requestClose(tasksModel.index(model.index, 0));
                    }
                }
            }
        }

        Item {
            id: background

            width: parent.width
            height: parent.height

            MouseArea {
                anchors.fill: parent
                drag {
                    target: background
                    axis: Drag.YAxis
                }

                function recovery() {
                    delegate.z = 0;
                    if ( -background.y > background.height/5) {
                        slideAnim.to = -background.height*2;
                        slideAnim.running = true;
                    } else {
                        slideAnim.to = 0;
                        slideAnim.running = true;
                    }
                }

                onPressed: delegate.z = 10;
                onClicked: {
                    window.setSingleActiveWindow(model.index, delegate);
                    window.hideTask()
                }
                onReleased: {
                   recovery()
                }

                onCanceled:  {
                    recovery()
                }

                Loader {
                    id: pipeWireLoader
                    anchors.fill:parent
                    source: Qt.resolvedUrl("./Thumbnail.qml")
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            source = Qt.resolvedUrl("./TaskIcon.qml");
                        }
                    }
                }
            }
        }
    }
}

