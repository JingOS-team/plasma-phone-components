/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *  Copyright 2021 Rui Wang <wangrui@jingos.com>
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

import "../indicators" as Indicators

Item {
    id: root

    signal closeRequested
    signal closed

    property bool screenshotRequested: false
    property bool deviceConnected : false 
  
    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    property int screenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Screen Brightness"] : 0;
    property bool disableBrightnessUpdate: true
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    property bool bluetoothDisConnected: BluezQt.Manager.bluetoothBlocked
    property bool wirelessDisConnected: enabledConnections.wirelessEnabled

    onBluetoothDisConnectedChanged: {
        settingsModel.get(2).enabled = !bluetoothDisConnected
    }

    onWirelessDisConnectedChanged: {
        settingsModel.get(0).enabled = wirelessDisConnected

    }

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    function toggleTorch() {
        plasmoid.nativeInterface.toggleTorch()
    }

    function toggleWifi() {
        nmHandler.enableWireless(!enabledConnections.wirelessEnabled)

        //settingsModel.get(0).enabled = !enabledConnections.wirelessEnabled
    }

    function toggleWwan() {
        nmHandler.enableWwan(!enabledConnections.wwanEnabled)
        settingsModel.get(4).enabled = !enabledConnections.wwanEnabled
    }

    function toggleRotation() {
        const enable = !plasmoid.nativeInterface.autoRotateEnabled
        plasmoid.nativeInterface.autoRotateEnabled = enable
        settingsModel.get(9).enabled = enable
    }

    function toggleBluetooth() {
        const enable = !root.bluetoothDisConnected
        BluezQt.Manager.bluetoothBlocked = enable

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enable;
        }
    }

    function toggleFlightMode() {

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

    onScreenBrightnessChanged: {
        if(!disableBrightnessUpdate) {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness <= 8 ? 8 : screenBrightness;
            operation.silent = true
            service.startOperationCall(operation);
        }
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

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    PlasmaNM.KcmIdentityModel {
        id: connectionModel    
    }
    PlasmaNM.EditorProxyModel {
        id: editorProxyModel
        sourceModel: connectionModel
        onConnectedNameChanged:{

            settingsModel.get(0).currentConnectedName = name
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
            disableBrightnessUpdate = false;
        }
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
            "enabled": enabledConnections.wirelessEnabled,
            "active": true,
            "row": 0,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 3,
            "currentConnectedName": editorProxyModel.currentConnectedName
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
            "currentConnectedName": devicesProxyModel.connectedName
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Flight Mode"),
            "icon": "flight-mode",
            "settingsCommand": "",
            "toggleFunction": "toggleFlightMode",
            "delegate": "Delegate",
            "enabled": false,
            "active": false,
            "row": 2,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 1
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Mobile Data"),
            "icon": "network-modem",
            "settingsCommand": "plasma-settings -m kcm_mobile_broadband",
            "toggleFunction": "toggleWwan",
            "delegate": "Delegate",
            "enabled":false, // enabledConnections.wwanEnabled,
            "active": false,
            "row": 2,
            "column": 1,
            "rowSpan": 1,
            "columnSpan": 1
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Sleep Mode"),
            "icon": "sleep-mode",
            "settingsCommand": "",
            "toggleFunction": "toggleSleepMode",
            "delegate": "Delegate",
            "enabled": false,
            "active": false,
            "row": 2,
            "column": 2,
            "rowSpan": 1,
            "columnSpan": 1
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
            "text": i18nd("plasma-phone-components", "Hotspot"),
            "icon": "hotspot",
            "settingsCommand": "",
            "toggleFunction": "toggleHotspot",
            "delegate": "Delegate",
            "enabled": false,
            "active": false,
            "row": 5,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 1
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Auto-rotate"),
            "icon": "rotation-allowed",
            "enabled": false ,//plasmoid.nativeInterface.autoRotateEnabled,
            "active": false,
            "settingsCommand": "",
            "toggleFunction": "toggleRotation",
            "row": 5,
            "column": 1,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Screenshot"),
            "icon": "screenshot",
            "enabled": false,
            "active": true,
            "settingsCommand": "",
            "toggleFunction": "requestScreenshot",
            "row": 5,
            "column": 2,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Location"),
            "icon": "gps",
            "enabled": false,
            "active": false,
            "settingsCommand": "",
            "row": 5,
            "column": 3,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Settings"),
            "icon": "settings",
            "enabled": false,
            "active": true,
            "settingsCommand": "plasma-settings -m wifi",
            "toggleFunction": "",
            "row": 5,
            "column": 4,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });
        settingsModel.append({
            "text": i18nd("plasma-phone-components", "Sound"),
            "icon": "audio-speakers-symbolic",
            "enabled": false,
            "active": true,
            "settingsCommand": "plasma-settings -m sound",
            "toggleFunction": "",
            "row": 5,
            "column": 5,
            "rowSpan": 1,
            "columnSpan": 1,
            "delegate": "Delegate"
        });

        // settingsModel.append({
        //     "text": i18n("Battery"),
        //     "icon": "battery-full",
        //     "enabled": false,
        //     "settingsCommand": "plasma-settings -m kcm_mobile_power",
        //     "toggleFunction": "",
        //     "delegate": "",
        //     "enabled": false,
        //     "applet": null
        // });

        // settingsModel.append({
        //     "text": i18n("Flashlight"),
        //     "icon": "flashlight-on",
        //     "enabled": false,
        //     "settingsCommand": "",
        //     "toggleFunction": "toggleTorch",
        //     "applet": null
        // });

        // brightnessSlider.moved.connect(function() {
        //     root.screenBrightness = brightnessSlider.value;
        // });
        disableBrightnessUpdate = false;
    }

    ListModel {
        id: settingsModel
    }

    GridLayout {
        id: flow 
        anchors {
            fill: parent
            margins: 10
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
