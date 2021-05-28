/*
Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>
Copyright (C) 2021 Rui Wang <wangrui@jingos.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import QtQml 2.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import "../components"

PlasmaCore.ColorScope {
    id: root

    property string password
    property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
    property bool isWidescreen: root.height < root.width * 0.75
    property bool notificationsShown: false //phoneNotificationsList.count !== 0
    property bool isCharged: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false
    property bool revKeyInput: false
    property bool iconChangFlag: false
    property bool isIgnoreTheFirstSignal: false

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent

    function isPinDrawerOpen() {
        return passwordFlickable.contentY === passwordFlickable.columnHeight;
    }

    Component.onCompleted :{
        if(!isCharged) {
            isIgnoreTheFirstSignal = true
        }
    }
   
    onIsChargedChanged: {
        if (!isIgnoreTheFirstSignal) {
            isIgnoreTheFirstSignal = true
            return
        } 

        if (isCharged) {
            lockScreenChargedLoader.active = true
        } else {
            lockScreenChargedLoader.active = false
        }
    }
    //please don't remove this rect which add by pengbo wu
    Rectangle {
        id: lockScreen

        anchors.fill: parent
        color: "transparent"

        Image {
            id:bgImage
            anchors.fill: parent
            source: Wallpaper.Wallpaper.lockscreenWallpaper
        }

        // blur background once keypad is open
        FastBlur {
            id: blur
            cached: true
            anchors.fill: parent
            source: bgImage //wallpaper
            visible: true

            property bool doBlur: notificationsShown || isPinDrawerOpen() // only blur once animation finished for performance

            Behavior on doBlur {
                NumberAnimation {
                    target: blur
                    property: "radius"
                    duration: 1000
                    to: blur.doBlur ? 0 : 90
                    easing.type: Easing.InOutQuad
                }
                PropertyAction {
                    target: blur
                    property: "visible"
                    value: blur.doBlur
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: visible ? 0.1 : 0
                visible: blur.doBlur

                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }
            }
        }

        Notifications.WatchedNotificationsModel {
            id: notifModel
        }

        // header bar
        SimpleHeaderBar {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: units.gridUnit
            opacity: 1
        }

        // phone clock component
        ColumnLayout {
            id: phoneClockComponent
            visible: !isWidescreen

            anchors {
                top: parent.top
                topMargin: root.height / 2 - (height / 2 + units.gridUnit * 2)
                left: parent.left
                right: parent.right
            }
            spacing: 0
            opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)

            states: State {
                name: "notification"; when: notificationsShown
                PropertyChanges { target: phoneClockComponent; anchors.topMargin: units.gridUnit * 5 }
            }

            transitions: Transition {
                NumberAnimation {
                    properties: "anchors.topMargin"
                    easing.type: Easing.InOutQuad
                }
            }

            Clock {
                id: phoneClock
                alignment: Qt.AlignRight
                Layout.alignment: Qt.AlignRight

                Layout.bottomMargin: units.gridUnit * 2 // keep spacing even if media controls are gone
            }
        }

        // tablet clock component
        Item {
            id: tabletClockComponent
            visible: isWidescreen
            width: parent.width / 2
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: 40
            }

            ColumnLayout {
                id: tabletLayout
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 61//tabletClock.height

                spacing: units.gridUnit * 10
                opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)


                Clock {
                    id: tabletClock
                    alignment: Qt.AlignRight | Qt.AlignBottom
                    Layout.minimumWidth: 260//units.gridUnit * 30
                }
            }
        }
        // scroll up icon
        Item{
            id: scrollUpIconArrow
            anchors.bottom: scrollUpIconLock.top
            anchors.horizontalCenter: parent.horizontalCenter
            height:22
            width:22
            PlasmaCore.IconItem {
                opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
                anchors.centerIn:parent
                height:16
                width:16
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                source: "arrow-up"
            }
        }
        Item{
            id: scrollUpIconLock
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gridUnit //+ passwordFlickable.contentY * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            height:31
            width:31
            Image {
                id:lockImage
                anchors.fill: parent
                source: "file:///usr/share/icons/jing/SwiMachine/lock-screen.svg"
            }
            ShaderEffect {
                anchors.fill: lockImage
                property variant src: lockImage
                property color color: "white"
                fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform sampler2D src;
                    uniform highp vec4 color;
                    uniform lowp float qt_Opacity;
                    void main() {
                        lowp vec4 tex = texture2D(src, qt_TexCoord0);
                        gl_FragColor = vec4(color.r * tex.a, color.g * tex.a, color.b * tex.a, tex.a) * qt_Opacity;
                    }"
            }
        }
        Flickable {
            id: passwordFlickable

            anchors.fill: parent

            property int columnHeight: units.gridUnit * 20

            height: columnHeight + root.height
            contentHeight: columnHeight + root.height
            boundsBehavior: Flickable.StopAtBounds

            // always snap to end (either hidden or shown)
            onFlickEnded: {
                if (!atYBeginning && !atYEnd) {
                    if (contentY > columnHeight - contentY) {
                        flick(0, -1000);
                    } else {
                        flick(0, 1000);
                    }
                }
            }

            // wipe password if it is more than half way down the screen
            onContentYChanged: {
                if (contentY < columnHeight / 2) {
                    root.password = "";
                    keypad.pinLabel = i18nd("plasma-phone-components", "Password");
                    revKeyInput=false
                    keypad.viewDisplay(false)

                }else{
                    revKeyInput=true
                    keypad.viewDisplay(true)
                }
            }
            Keypad {
                id: keypad
                focus: true // passwordFlickable.contentY === passwordFlickable.columnHeight
                anchors.bottom: parent.bottom
                width: root.width
                height: root.height //units.gridUnit * 17
                opacity: Math.sin((Math.PI / 2) * (passwordFlickable.contentY / passwordFlickable.columnHeight) + 1.5 * Math.PI) + 1
            }
        }
    }



    Loader {
        id: lockScreenChargedLoader
        anchors.fill:parent
        sourceComponent: lockScreenChargedComponent
        active: false
    }

    Component {
        id: lockScreenChargedComponent
        LockScreenCharged {
            id: lockscreencharged
            anchors.fill: parent
        }
    }

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }

}
