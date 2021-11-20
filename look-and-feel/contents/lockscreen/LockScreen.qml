/*
Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>
Copyright (C) 2021 Rui Wang <wangrui@jingos.com>
Copyright (C) 2021 Dexiang Meng <dexiang.meng@jingos.com>

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
import jingos.display 1.0
import org.kde.kirigami 2.15
import "../components"

PlasmaCore.ColorScope {
    id: root

    property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
    property bool isWidescreen: root.height < root.width * 0.75
    property bool notificationsShown: false
    property bool isCharged: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false
    property bool iconChangFlag: false
    property bool isIgnoreTheFirstSignal: false
    property var moveStartContentY
    property bool moveEndFlag: true
    property bool isDarkTheme: JTheme.colorScheme === "jingosDark"
    property bool isUnlockStatus: false

    signal visibleChanged

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent

    function isPinDrawerOpen() {
        return passwordFlickable.contentY === passwordFlickable.columnHeight
    }

    Component.onCompleted: {
        if(!isCharged) {
            isIgnoreTheFirstSignal = true
        }
    }

    onIsChargedChanged: {
        if(!isIgnoreTheFirstSignal) {
            isIgnoreTheFirstSignal = true
            return
        }

        if (isCharged) {
            lockScreenChargedLoader.active = true
        } else {
            lockScreenChargedLoader.active = false
        }
    }

    onVisibleChanged: {
        passwordFlickable.contentY = 0;
        keypad.focus = true
        keypad.forceActiveFocus()
    }

    function startAnim() {
        console.log(" start animation:::::")
        isUnlockStatus = true
        root.parent.color = "#ff0000"
        xyAnimation.start()
    }

    PropertyAnimation {
        id: xyAnimation
        target: root.parent
        properties: "y"
        easing.type: Easing.InOutQuad
        duration: 200
        from: 0
        to: -root.height
        onFinished: {
            isUnlockStatus = false
            root.parent.y = 0
            root.parent.color = "black"
        }
    }
    //please don't remove this rect which add by pengbo wu
    Rectangle {
        id: lockScreen
        // z: 100
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
//            Behavior on doBlur {

//                NumberAnimation {
//                    target: blur
//                    property: "radius"
//                    duration: 150
//                    to: blur.doBlur ? 0 : 90
//                    easing.type: Easing.InOutQuad
//                }

//                PropertyAction {
//                    target: blur
//                    property: "visible"
//                    value: blur.doBlur
//                }
//            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: visible ? 0.1 : 0
                visible: blur.doBlur

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }

        // header bar
        SimpleHeaderBar {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: JDisplay.dp(18)
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
            onOpacityChanged: {
              //notifications.opacity = opacity
            }
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
            width: parent.width/2
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: JDisplay.dp(40)
            }

            ColumnLayout {
                id: tabletLayout
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: JDisplay.dp(61)//tabletClock.height
                spacing: units.gridUnit * 10
                opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
                onOpacityChanged: {
                    //notifications.opacity = opacity
                }

                Clock {
                    id: tabletClock
                    alignment: Qt.AlignRight | Qt.AlignBottom
                    Layout.minimumWidth: JDisplay.dp(260)//units.gridUnit * 30
                }
            }
        }
        // scroll up icon
        Rectangle {
            id: scrollUpIconArrow
            color: "#00000000"
            anchors.bottom: scrollUpIconLock.top
            anchors.horizontalCenter: parent.horizontalCenter
            height: JDisplay.dp(22)
            width: JDisplay.dp(22)
            Icon {
                opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
                anchors.centerIn:parent
                height: JDisplay.dp(11)
                width: JDisplay.dp(11)
                color: "#ffffff"
//                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                source: "arrow-up"
            }
        }

        Rectangle {
            id: scrollUpIconLock
            color: "#00000000"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gridUnit //+ passwordFlickable.contentY * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            height:JDisplay.dp(31)
            width: JDisplay.dp(31)

            Icon {
                id:lockImage
                height:JDisplay.dp(31)
                width: JDisplay.dp(31)
                color: "#ffffff"
                source: isUnlockStatus ? "file:///usr/share/icons/jing/unlock-screen.svg" : "file:///usr/share/icons/jing/lock-screen.svg"
            }

//            ShaderEffect {
//                anchors.fill: lockImage
//                property variant src: lockImage
//                property color color: "white"
//                fragmentShader: "
//                    varying highp vec2 qt_TexCoord0;
//                    uniform sampler2D src;
//                    uniform highp vec4 color;
//                    uniform lowp float qt_Opacity;
//                    void main() {
//                        lowp vec4 tex = texture2D(src, qt_TexCoord0);
//                        gl_FragColor = vec4(color.r * tex.a, color.g * tex.a, color.b * tex.a, tex.a) * qt_Opacity;
//                    }"
//            }
        }

        Flickable {
            id: passwordFlickable
            anchors.fill: parent
            property int columnHeight: units.gridUnit * 20
            height: columnHeight + root.height
            contentHeight: columnHeight + root.height
            boundsBehavior: Flickable.StopAtBounds

            PropertyAnimation {
                id: pfAnimation
                property int toValue
                target: passwordFlickable
                properties: "contentY"
                easing.type: Easing.InOutQuad
                duration: 150
                from: passwordFlickable.contentY
                to: pfAnimation.toValue
                onFinished: {
                }
            }

            onMovementEnded: {
                moveEndTimer.stop()
                root.moveEndFlag = true
                if (contentY > columnHeight - contentY) {
//                    flick(0, -1000);
                    pfAnimation.toValue = passwordFlickable.columnHeight
                    pfAnimation.start()
                    keypad.revKeyInput = true
                    keypad.simpleKeyPressFlag = true
//                    notifications.keypadisvisible = true;
                    mediaPlayer.keypadisvisible = true;
                } else {
//                    flick(0, 1000);
                    pfAnimation.toValue = 0
                    pfAnimation.start()
                    keypad.resetKeyPad()
                    keypad.revKeyInput = false
                    keypad.simpleKeyPressFlag = false
//                    notifications.keypadisvisible = false;
                    mediaPlayer.keypadisvisible = false;
                    keypad.pinLabel = i18nd("plasma-phone-components", "Password");
                }
            }

            onMovementStarted: {
                moveStartContentY = contentY
            }
            // wipe password if it is more than half way down the screen
            onContentYChanged: {
                keypad.simpleKeyPressFlag = false
                moveEndTimer.restart()
                root.moveEndFlag = false
                if(contentY < columnHeight/2) {
                    keypad.viewDisplay(false)
                    keypad.revKeyInput = false
                } else {
                    keypad.revKeyInput = true
                    keypad.viewDisplay(true)
                }
            }

            ColumnLayout {
                id: passwordLayout
                anchors.bottom: parent.bottom
                width: parent.width
                spacing: units.gridUnit
                opacity: Math.sin((Math.PI / 2) * (passwordFlickable.contentY / passwordFlickable.columnHeight) + 1.5 * Math.PI) + 1

                onOpacityChanged: {
                   blur.radius = opacity * 90
                }
                Keypad {
                    id: keypad
                    focus: true // passwordFlickable.contentY === passwordFlickable.columnHeight
                    Layout.fillWidth: true
                    Layout.minimumHeight: root.height //units.gridUnit * 17
                    Layout.maximumWidth: root.width
                    function show(flag) {
                        if(flag) {
                            if (passwordFlickable.contentY < passwordFlickable.columnHeight - passwordFlickable.contentY) {
//                                passwordFlickable.flick(0, -1000);
                                pfAnimation.toValue = passwordFlickable.columnHeight
                                pfAnimation.start()
                            }
                        } else {
                            if (passwordFlickable.contentY > passwordFlickable.columnHeight - passwordFlickable.contentY) {
//                                passwordFlickable.flick(0, 1000);
//                                blur.radius = 0
                                pfAnimation.toValue = 0
                                pfAnimation.start()
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            id: mediabackground
            //z: mediaPlayer.visible ? 101 : 99
            anchors.top: parent.top
            anchors.topMargin: JDisplay.dp(40)
            anchors.left: parent.left
            anchors.leftMargin: JDisplay.dp(15)
            visible: mediaPlayer.visible
            //opacity: mediaPlayer.opacity
            height: JDisplay.dp(96)
            width: JDisplay.dp(260)
            color: isDarkTheme ? Qt.rgba(38 / 255,38 / 255,38 / 255,1) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1)
            radius: JDisplay.dp(9)
        }

        MediaPlayer{
            id: mediaPlayer
            //z: mediaPlayer.visible ? 101 : 99
            anchors.fill: mediabackground
            height: JDisplay.dp(96)
            radius: JDisplay.dp(9)
            color: isDarkTheme ? Qt.rgba( 142 / 255, 142 / 255, 147 / 255, 0.1) : Qt.rgba(248 / 255, 248 / 255, 248 / 255, 0.7)
        }
    }

    // Notifications.WatchedNotificationsModel {
    //     id: notifyModel
    // }
    // Connections {
    //     target: authenticator

    //     onCloseNotificationId:{
    //         notifyModel.close(id);
    //     }
    // }

        // Item{
        //     id: conentNotifications
        //     z: notifications.listViewCount > 0 && !notifications.keypadisvisible ? 101 : 99
        //     anchors.left: parent.left
        //     anchors.leftMargin: JDisplay.dp(15)
        //     anchors.top: parent.top
        //     anchors.topMargin: notifications.notificationListInitPos
        //     anchors.bottom: parent.bottom
        //     width: JDisplay.dp(260)
        //     clip: true

        //     QuickNotificationList {
        //         id: notifications
        //         anchors.left: parent.left
        //         anchors.right: parent.right
        //         y: - hearderItemHeight
        //         height: parent.height + hearderItemHeight
        //         pullDistance: hearderItemHeight  - parent.anchors.topMargin

        //         onCleanAll:{
        //             conentNotifications.anchors.topMargin = notifications.notificationListInitPos
        //             y = - hearderItemHeight
        //             notificationListIsCanMove = true
        //             distanceY = 0
        //         }
        //         onNotificationListIsCanMoveChanged:{
        //             if(notificationListIsCanMove)
        //             {
        //                 if(mediabackground.visible)
        //                 {
        //                     conentNotifications.anchors.topMargin = JDisplay.dp(7)
        //                     height = parent.height + hearderItemHeight
        //                 }
        //                 else{
        //                     y = - hearderItemHeight
        //                     height = parent.height + hearderItemHeight
        //                 }
        //             }
        //             else{
        //                 if(mediabackground.visible)
        //                 {
        //                     conentNotifications.anchors.topMargin = 0
        //                     notifications.y = 0
        //                     height = parent.height
        //                 }
        //                 else{
        //                     height = parent.height + pullDistance
        //                     //notifications.y = - pullDistance
        //                 }
        //             }
        //         }
        //     }
        //     Connections{
        //         target: mediabackground
        //         onVisibleChanged:{
        //             if(mediabackground.visible)
        //             {
        //                 conentNotifications.anchors.top = mediabackground.bottom
        //                 if(!notifications.notificationListIsCanMove)
        //                 {
        //                     conentNotifications.anchors.topMargin = 0
        //                     notifications.y = 0
        //                     notifications.height = conentNotifications.height
        //                 }
        //                 else
        //                 {
        //                     conentNotifications.anchors.topMargin = JDisplay.dp(7)
        //                     notifications.height = conentNotifications.height + notifications.hearderItemHeight //+ pullDistance
        //                     notifications.y = - notifications.hearderItemHeight
        //                 }
        //             }
        //             else{
        //                 conentNotifications.anchors.top = lockScreen.top
        //                 if(!notifications.notificationListIsCanMove)
        //                 {
        //                     conentNotifications.anchors.topMargin = 0
        //                     notifications.height = conentNotifications.height
        //                     notifications.y = 0
        //                 }
        //                 else
        //                 {
        //                     conentNotifications.anchors.topMargin = notifications.notificationListInitPos
        //                     notifications.y = - notifications.hearderItemHeight
        //                     notifications.height = conentNotifications.height + pullDistance
        //                 }
        //             }
        //         }
        //     }
        // }

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
            z: 200
            imageUrl: chargingIcon()

            function chargingIcon() {
                if(pmSource.data["AC Adapter"]["Quick charging"] == true) {
                    return "file:///usr/share/icons/jing/lightningQuickly.svg";
                }
                return "file:///usr/share/icons/jing/lightning.svg";
            }
        }
    }

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }

    PlasmaCore.DataSource {
        id: stSource
        engine: "statuspanel"
        connectedSources: ["StatusPanel"]
    }

    Timer {
        id: moveEndTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            if(!root.moveEndFlag) {
               passwordFlickable.movementEnded()
            }
        }
    }
}
