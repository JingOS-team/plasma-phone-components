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

import QtQuick 2.14
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.private.bluetooth 1.0
import org.kde.plasma.plasmoid 2.0
import MeeGo.QOfono 0.2
import org.kde.plasma.private.volume 0.1
import jingos.display 1.0

import "../indicators" as Indicators

Item {
    id: root

    signal closeRequested
    signal closed

    property bool screenshotRequested: false
    property bool calculatorRequested: false
    property bool settingRequested: false
    property bool clockRequested: false
    property bool cameraRequested: false
    property bool calendarRequested: false
    property bool deviceConnected : false 
  
    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    property int screenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Screen Brightness"] : 0
    property int audioVolume: volumeHandle.currentVolume
    property bool autoBrightness : pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Auto Brightness"] : false
    property bool disableBrightnessUpdate: false
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] : 0

    property bool bluetoothDisConnected: !BluezQt.Manager.adapters[0].powered//BluezQt.Manager.bluetoothBlocked
    property bool wirelessConnected: stSource.data["StatusPanel"]["wifiEnabled"]//enabledConnections.wirelessEnabled
    property string wirelessNetworkStatus: stSource.data["StatusPanel"]["networkStatus"]
    property string wirelessName: stSource.data["StatusPanel"]["currentWifiName"]
    property bool flightMode: stSource.data["StatusPanel"]? stSource.data["StatusPanel"]["flight mode"] : false
    property bool isDarkScheme: plasmoid.nativeInterface.isDarkColorScheme
    property bool isMute:paSinkModel.preferredSink.muted

    onBluetoothDisConnectedChanged: {
        settingsModel.get(2).enabled = !bluetoothDisConnected
    }

    onWirelessConnectedChanged: {
        settingsModel.get(0).enabled = wirelessConnected
    }

    onWirelessNameChanged: {
        settingsModel.get(0).currentConnectedName = wirelessName
    }

    onWirelessNetworkStatusChanged: {
        settingsModel.get(0).connectStatus = wirelessNetworkStatus
    }

    onFlightModeChanged: {
        settingsModel.get(8).enabled = flightMode
    }

    function toggleTorch() {
        plasmoid.nativeInterface.toggleTorch()
    }

    function toggleWifi() {
        settingsModel.get(0).enabled = !stSource.data["StatusPanel"]["wifiEnabled"]//!enabledConnections.wirelessEnabled

        nmHandler.enableWireless(!stSource.data["StatusPanel"]["wifiEnabled"])
    }

    function toggleWwan() {
//        ofonocontext.active = !ofonocontext.active
//        settingsModel.get(4).enabled = !ofonocontext.active
    }

    function toggleRotation() {
//        const enable = !plasmoid.nativeInterface.autoRotateEnabled
//        plasmoid.nativeInterface.autoRotateEnabled = enable
//        settingsModel.get(9).enabled = enable
    }

    function toggleBluetooth() {
        const enable = root.bluetoothDisConnected
        //BluezQt.Manager.bluetoothBlocked = enable

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enable;
        }

        settingsModel.get(2).enabled = enable
    }

    function toggleFlightMode() {
        var mode = flightMode;
        mode = !mode
        nmHandler.enableAirplaneMode(mode);
        settingsModel.get(8).enabled = mode

    }

    function requestShutdown() {
        print("Shutdown requested, depends on ksmserver running");
        var service = pmSource.serviceForSource("PowerDevil");
        //note the strange camelCasing is intentional
        var operation = service.operationDescription("requestShutDown");
        return service.startOperationCall(operation);
    }

    function addPlasmoid(applet) {
        settingsModel.append({"icon": applet.icon,
                              "text": applet.title,
                              "enabled": false,
                              "applet": applet,
                              "settingsCommand": "",
                              "toggleFunction": ""});
    }

    function toggleRinger(num) {
        volumeHandle.setVolume(num);
    }

    function toggleBright(num) {
        root.screenBrightness = num;
    }

    function toggleSetting()
    {
        settingRequested = true;
        root.closeRequested();
    }

    function toggleCalculator(){
        calculatorRequested = true;
        root.closeRequested();
    }

    function toggleClock(){
        clockRequested = true;
        root.closeRequested();
    }

    function toggleCamera(){
        cameraRequested = true;
        root.closeRequested();
    }

    function toggleCalendar(){
        calendarRequested = true;
        root.closeRequested();
    }

    function toggleMute(){
        paSinkModel.preferredSink.muted = !paSinkModel.preferredSink.muted
        //settingsModel.get(5).enabled = !paSinkModel.preferredSink.muted
    }

    function toggleAutoBrightness(){
        root.autoBrightness = ! root.autoBrightness
        console.log("toggleAutoBrightness,autobrightness:"+root.autoBrightness)

    }

    function refreshBrightnessIcon(){
        if(screenBrightness>0.66*maximumScreenBrightness)
            settingsModel.get(7).icon = "brightness_100";
        else if(screenBrightness>0.33*maximumScreenBrightness)
            settingsModel.get(7).icon = "brightness_66";
        else if(screenBrightness>0.1*maximumScreenBrightness)
            settingsModel.get(7).icon = "brightness_33";
        else
            settingsModel.get(7).icon = "brightness_zero";
    }

    onIsMuteChanged: {
        settingsModel.get(5).enabled = !paSinkModel.preferredSink.muted
    }

    onScreenBrightnessChanged: {
        if(!disableBrightnessUpdate) {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness <= 8 ? 8 : screenBrightness;
            operation.silent = true
            service.startOperationCall(operation);
        }

        refreshBrightnessIcon();
    }

    onAudioVolumeChanged: {
        if(audioVolume>0.66*volumeHandle.maxVolumeValue)
            settingsModel.get(6).icon = "audio_100";
        else if(audioVolume>0.3*volumeHandle.maxVolumeValue)
            settingsModel.get(6).icon = "audio_66";
        else if(audioVolume>0)
            settingsModel.get(6).icon = "audio_33";
        else
            settingsModel.get(6).icon = "audio_mute";
    }

    onAutoBrightnessChanged: {
        settingsModel.get(12).enabled = root.autoBrightness


        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setAutoBrightness");
        operation.autoBrightness = autoBrightness;
        operation.silent = true
        service.startOperationCall(operation);
    }

    function requestScreenshot() {
        screenshotRequested = true;
        root.closeRequested();
    }

    onClosed: {
        if (screenshotRequested) {
            plasmoid.nativeInterface.takeScreenshot();
            screenshotRequested = false;
        }
        if(calculatorRequested){
            calculatorRequested = false;
            plasmoid.nativeInterface.runApplication("org.kde.kalk.desktop");
        }
        if(clockRequested){
            clockRequested = false;
            plasmoid.nativeInterface.runApplication("org.kde.kclock.desktop");
        }
        if(cameraRequested){
            cameraRequested = false;
            plasmoid.nativeInterface.runApplication("org.kde.camera.desktop");
        }
        if(calendarRequested){
            calendarRequested = false;
            plasmoid.nativeInterface.runApplication("org.kde.calindori.desktop");
        }
        if(settingRequested){
            settingRequested = false;
            plasmoid.nativeInterface.runApplication("org.kde.mobile.plasmasettings.desktop");
        }
    }

    function childFocus(focus){
        slidingPanel.childFocus = focus
    }

    DevicesProxyModel {
        id: devicesProxyModel
        sourceModel: devicesModel

        onConnectedNameChanged:{

            settingsModel.get(2).currentConnectedName = connectedName
        }
    }

    BluezQt.DevicesModel { 
        id:devicesModel
    }



    PlasmaNM.Handler {
        id: nmHandler
    }

    OfonoManager {
        id: ofonoManager
    }

    OfonoModem {
            id: ofonomodem
           modemPath: ofonoManager.modems[0]
    }


    OfonoContextConnection {
        id: ofonocontext
       contextPath: connectionManager.contexts[0]
    }

    OfonoConnMan {
        id:connectionManager

        modemPath: ofonoManager.modems[0]
        onRoamingAllowedChanged:{
            console.log("===onRoamingAllowedChanged ",roaming)
        }
    }


    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }
        onDataChanged: {

            disableBrightnessUpdate = true;

            root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
            root.autoBrightness = pmSource.data["PowerDevil"]["Auto Brightness"];
            disableBrightnessUpdate = false;

        }
    }

    PlasmaCore.DataSource {
            id: stSource
            engine: "statuspanel"
            connectedSources: ["StatusPanel"]
        }

    SinkModel {
        id: paSinkModel
    }
    //HACK: make the list know about the applet delegate which is a qtobject
    QtObject {
        id: nullApplet
    }
    Component.onCompleted: {
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "WLAN"),
            "icon": "wifi",
            "settingsCommand": "plasma-settings -m wifi",
            "toggleFunction": "toggleWifi",
            "delegate": "BigBtnDelegate",
            "enabled": wirelessConnected,
            "active": true,
            "row": 0,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 3,
            "currentConnectedName": wirelessName,//editorProxyModel.currentConnectedName,
            "connectStatus": wirelessNetworkStatus,//"Connected",
            "enableIcon":"",
            "disableIcon":""
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "MediaPlayer"),
            "icon": "",
            "settingsCommand": "",
            "toggleFunction": "",
            "delegate": "MediaPlayer",
            "enabled": true,
            "active": true,            
            "row": 0,
            "column": 3,
            "rowSpan": 3,
            "columnSpan": 3
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Bluetooth"),
            "icon": "bluetooth",
            "settingsCommand": "plasma-settings -m bluetooth",
            "toggleFunction": "toggleBluetooth",
            "delegate": "BigBtnDelegate",
            "enabled":  !root.bluetoothDisConnected,
            "active": true,
            "row": 1,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 3,
            "currentConnectedName": devicesProxyModel.connectedName,
            "connectStatus": "Connected"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Screenshot"),
            "icon": "screenshot",
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "requestScreenshot",
            "row": 2,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Settings"),
            "icon": "settings",
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "toggleSetting",
            "row": 2,
            "column": 1,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Sound"),
            "enabled": !root.isMute,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "toggleMute",
            "row": 2,
            "column": 2,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "StateDelegate",
            "enableIcon": "Mute_disable",
            "disableIcon": "Mute_enable",
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Voice"),
            "icon": "audio-speakers-symbolic",
            "settingsCommand": "",
            "toggleFunction": "toggleRinger",
            "delegate": "SliderBtnDelegate",
            "enabled": false,
            "active": true,
            "row": 3,
            "column": 0,
            "rowSpan": 2,
            "columnSpan": 3
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Bright"),
            "icon": "bright",
            "settingsCommand": "",
            "toggleFunction": "toggleBright",
            "delegate": "SliderBtnDelegate",
            "enabled": false,
            "active": true,
            "row": 3,
            "column": 3,
            "rowSpan": 2,
            "columnSpan": 3
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "FlightMode"),
            "icon": "FlightMode_enable",
            "enabled": root.flightMode,
            "active": true,
            "settingsCommand": "plasma-settings -m wifi",
            "toggleFunction": "toggleFlightMode",
            "row": 5,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Calculator"),
            "icon": "Calculator",
            "settingsCommand": "",
            "toggleFunction": "toggleCalculator",
            "delegate": "Delegate",
            "enabled": false,
            "active": true,
            "row": 5,
            "column": 1,
            "rowSpan": 1,
            "columnSpan": 1
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Clock"),
            "icon": "Clock",
            "enabled": false ,//plasmoid.nativeInterface.autoRotateEnabled,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "toggleClock",
            "row": 5,
            "column": 2,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });

        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Camera"),
            "icon": "Camera",
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "toggleCamera",
            "row": 5,
            "column": 3,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "AutoBrightness"),
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "toggleAutoBrightness",
            "row": 5,
            "column": 4,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "StateDelegate",
            "enableIcon": "AutoBrightness_enable",
            "disableIcon": "AutoBrightness_disable"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Poweroff"),
            "icon": "Poweroff",
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "requestShutdown",
            "row": 5,
            "column": 5,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });


        disableBrightnessUpdate = false;
    }

    ListModel {
        id: settingsModel
    }

    GridLayout {
        id: flow 
        anchors {
            fill: parent
            margins: JDisplay.dp(10)
        }
        rows: 6
        columns: 6
        readonly property real cellSizeHint: columnWidth // units.iconSizes.large + units.smallSpacing * 5
        readonly property real columnWidth: parent.width / 7 //Math.floor(width / Math.floor(width / cellSizeHint))
        readonly property real columnHeight: columnWidth //Math.floor(width / Math.floor(width / cellSizeHint))

        Repeater {
            model: settingsModel

            Item {
                Layout.row: model.row
                Layout.column: model.column
                Layout.columnSpan: model.columnSpan
                Layout.rowSpan: model.rowSpan

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: Layout.columnSpan
                Layout.preferredHeight: Layout.rowSpan

                // property bool toggled: model.enabled
                // spacing: 0// units.smallSpacing

                Loader {
                    id: loader

                    anchors.fill: parent
                    // anchors.margins: 3
                    source: Qt.resolvedUrl((model.delegate ? model.delegate : "Delegate") + ".qml")
                }
            } 
        }
    }
}
