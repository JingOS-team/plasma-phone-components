/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *  Copyright 2021 Liu Bangguo <liubangguo@jingos.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.6
import MeeGo.QOfono 0.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import jingos.display 1.0


Item {
    property bool isShowWhite: root.showColorWhite
    property string iconPath: "file:///usr/share/icons/jing/jing/settings/"
    property string strengthIconSource: iconPath+"sim_volume_0"

    width: strengthIcon.width + strengthLabel.width + strengthType.width + JDisplay.dp(8)
    Layout.minimumWidth: strengthIcon.width + strengthLabel.width + strengthType.width + JDisplay.dp(8)
    Layout.alignment: Qt.AlignVCenter
    visible: ofonomodem.online && netreg.strength>0 && netreg.name != ""

    function signalName(){
        if(netreg.technology == "gsm")
            return "2G";
        else if(netreg.technology == "umts")
            return "3G";
//        else if(netreg.technology == "lte")
//            return "4G";
        else if(netreg.technology == "lte" || netreg.technology == "nr")
            return "5G";
        else
            return "Unknown";
    }

    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {
           console.log("Ofono is " + available)
        }
        onModemAdded: {
            console.log("modem added " + modem)
            console.log("modem added ofonoManager.modems[0]:" + ofonoManager.modems[0])
            ofonomodem.online = true;
        }
        onModemRemoved: {
            console.log("modem removed")
            ofonomodem.online = false;
        }
    }

    OfonoNetworkRegistration {
        id: netreg
        
        modemPath: ofonoManager.modems[0]//ofonoManager.modems.length ? ofonoManager.modems[0] : ""

        Component.onCompleted: {
            netreg.scan()
            updateStrengthIcon()
        }

        onNetworkOperatorsChanged : {
            console.log("operators :"+netreg.currentOperator["Name"].toString())
        }

        function updateStrengthIcon() {
            if (netreg.strength >= 25) {
                strengthIconSource = iconPath+"sim_volume_100";
            }  else if (netreg.strength >= 15) {
                strengthIconSource = iconPath+"sim_volume_75";
            } else if (netreg.strength >= 5) {
                strengthIconSource = iconPath+"sim_volume_50";
            } else if (netreg.strength >= 2) {
                strengthIconSource = iconPath+"sim_volume_25";
            } else {
                strengthIconSource = iconPath+"sim_volume_0";
            }
        }

        onStrengthChanged: {
            console.log("Strength changed to " + netreg.strength)
            updateStrengthIcon()
        }

        onRegistrationFinished:{
        }

        onScanFinished: {
        }
    }

    OfonoModem {
        id: ofonomodem
        modemPath: ofonoManager.modems[0]

        onOnlineChanged: {
        }

        Component.onCompleted: {
            ofonomodem.online = true
        }
    }

    PlasmaComponents.Label {
        id: strengthLabel
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        text:  i18nd("plasma-phone-components", netreg.name)
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: JDisplay.sp(12)
    }

    Image{
        id: strengthIcon
        anchors {
            left: strengthLabel.right
            leftMargin: JDisplay.dp(4)
            verticalCenter: parent.verticalCenter
        }
        width:JDisplay.dp(11)
        height:JDisplay.dp(11)
        source:strengthIconSource
    }


    PlasmaComponents.Label {
        id: strengthType
        anchors {
            left: strengthIcon.right
            leftMargin:JDisplay.dp(4)
            verticalCenter: parent.verticalCenter
        }
        text:  signalName()//i18nd("plasma-phone-components", netreg.technology)
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: JDisplay.dp(12)
    }


    ColorOverlay {
        anchors.fill: strengthIcon
        source: strengthIcon
        color: !isShowWhite ?  "#000000" : "#ffffff"
        antialiasing: true
        opacity:1.0
    }
}
