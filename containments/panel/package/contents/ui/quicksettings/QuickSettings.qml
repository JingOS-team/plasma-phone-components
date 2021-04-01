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

import "../indicators" as Indicators

Item {
    id: root

    signal closeRequested
    signal closed

    property bool screenshotRequested: false
    property bool deviceConnected : false 
  
    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    property int screenBrightness                                            
    property bool disableBrightnessUpdate: true
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    function updateBlueZStatus()
    {
        var connectedDevices = [];

        for (var i = 0; i < BluezQt.Manager.devices.length; ++i) {
            var device = BluezQt.Manager.devices[i];
            if (device.connected) {
                connectedDevices.push(device);
            }
        }
        deviceConnected = connectedDevices.length > 0;
    }
        
    function toggleAirplane() {
        print("toggle airplane mode")
    }

    function toggleTorch() {
        plasmoid.nativeInterface.toggleTorch()
    }

    function toggleWifi() {
        nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
        settingsModel.get(0).enabled = !enabledConnections.wirelessEnabled
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
        const enable = !BluezQt.Manager.bluetoothOperational
        BluezQt.Manager.setBluetoothBlocked(enable)
        settingsModel.get(2).enabled = enable
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


    PlasmaNM.Handler {
        id: nmHandler
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
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
        //NOTE: add all in javascript as the static decl of listelements can't have scripts
        BluezQt.Manager.deviceAdded.connect(updateBlueZStatus);
        BluezQt.Manager.deviceRemoved.connect(updateBlueZStatus);
        BluezQt.Manager.deviceChanged.connect(updateBlueZStatus);
        BluezQt.Manager.bluetoothBlockedChanged.connect(updateBlueZStatus);
        BluezQt.Manager.bluetoothOperationalChanged.connect(updateBlueZStatus);

        updateBlueZStatus();

        settingsModel.append({
            "text": i18n("Wifi"),
            "icon": "wifi",
            "settingsCommand": "plasma-settings -m wifi",
            "toggleFunction": "toggleWifi",
            "delegate": "BigBtnDelegate",
            "enabled": enabledConnections.wirelessEnabled,
            "active": true,
            "row": 0,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 3
        });
        settingsModel.append({
            "text": i18n("MediaPlayer"),
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
            "text": i18n("Bluetooth"),
            "icon": "bluetooth",
            "settingsCommand": "plasma-settings -m bluetooth",
            "toggleFunction": "toggleBluetooth",
            "delegate": "BigBtnDelegate",
            "enabled": BluezQt.Manager.bluetoothOperational,
            "active": true,
            "row": 1,
            "column": 0,
            "rowSpan": 1,
            "columnSpan": 3
        });
        settingsModel.append({
            "text": i18n("Flight Mode"),
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
            "text": i18n("Mobile Data"),
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
            "text": i18n("Sleep Mode"),
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
            "text": i18n("Ringer"),
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
            "text": i18n("Bright"),
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
            "text": i18n("Hotspot"),
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
            "text": i18n("Auto-rotate"),
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
            "text": i18n("Screenshot"),
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
            "text": i18n("Location"),
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
            "text": i18n("Settings"),
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
            "text": i18n("Sound"),
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
            margins: units.smallSpacing * 2.5
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

                property bool toggled: model.enabled
                // spacing: 0// units.smallSpacing

                Loader {
                    id: loader

                    anchors.fill: parent
                    anchors.margins: 3
                    source: Qt.resolvedUrl((model.delegate ? model.delegate : "Delegate") + ".qml")
                }
            } 
        }
    }
}
