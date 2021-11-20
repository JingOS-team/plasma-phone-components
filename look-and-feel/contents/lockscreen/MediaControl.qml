/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
//import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    property var currentMetadata: mpris2Source.currentData ? mpris2Source.currentData.Metadata : undefined
    property string track: {
        if (!currentMetadata) {
            return ""
        }
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }
    property string artist: {
        if (!currentMetadata) {
            return ""
        }
        var xesamArtist = currentMetadata["xesam:artist"]
        if (!xesamArtist) {
            return "";
        }

        if (typeof xesamArtist == "string") {
            return xesamArtist
        } else {
            return xesamArtist.join(", ")
        }
    }
    property string albumArt: currentMetadata ? currentMetadata["mpris:artUrl"] || "" : ""
    readonly property string identity: !root.noPlayer ? mpris2Source.currentData.Identity || mpris2Source.current : ""
    property bool noPlayer: mpris2Source.sources.length <= 1
    property var mprisSourcesModel: []
    readonly property bool canControl: (!root.noPlayer && mpris2Source.currentData.CanControl) || false
    readonly property bool canGoPrevious: (canControl && mpris2Source.currentData.CanGoPrevious) || false
    readonly property bool canGoNext: (canControl && mpris2Source.currentData.CanGoNext) || false
    readonly property bool canPlay: (canControl && mpris2Source.currentData.CanPlay) || false
    readonly property bool canPause: (canControl && mpris2Source.currentData.CanPause) || false

    // HACK Some players like Amarok take quite a while to load the next track
    // this avoids having the plasmoid jump between popup and panel
    onStateChanged: {
        if (state != "") {
            plasmoid.status = PlasmaCore.Types.ActiveStatus
        } else {
            updatePlasmoidStatusTimer.restart()
        }
    }

    Timer {
        id: updatePlasmoidStatusTimer
        interval: 3000
        onTriggered: {
            if (state != "") {
                plasmoid.status = PlasmaCore.Types.ActiveStatus
            } else {
                plasmoid.status = PlasmaCore.Types.PassiveStatus
            }
        }
    }

    PlasmaCore.DataSource {
        id: mpris2Source
        readonly property string multiplexSource: "@multiplex"
        property string current: multiplexSource
        readonly property var currentData: data[current]
        engine: "mpris2"
        connectedSources: sources

        onSourceAdded: {
            updateMprisSourcesModel()
        }

        onSourceRemoved: {
            // if player is closed, reset to multiplex source
            if (source === current) {
                current = multiplexSource
            }
            updateMprisSourcesModel()
        }
    }

    Component.onCompleted: {
        //mpris2Source.serviceForSource("@multiplex").enableGlobalShortcuts()
        updateMprisSourcesModel()
    }

    function togglePlaying() {
        if (root.state === "playing") {
            if (root.canPause) {
                root.action_pause();
            }
        } else {
            if (root.canPlay) {
                root.action_play();
            }
        }
    }

    function action_open() {
        serviceOp(mpris2Source.current, "Raise");
    }
    function action_quit() {
        serviceOp(mpris2Source.current, "Quit");
    }

    function action_play() {
        serviceOp(mpris2Source.current, "Play");
    }

    function action_pause() {
        serviceOp(mpris2Source.current, "Pause");
    }

    function action_playPause() {
        console.log("=======on mediacontrol PlayPause===")
        serviceOp(mpris2Source.current, "PlayPause");
    }

    function action_previous() {
        console.log("=======on mediacontrol previous===")
        serviceOp(mpris2Source.current, "Previous");
    }

    function action_next() {
        console.log("=======on mediacontrol next===")
        serviceOp(mpris2Source.current, "Next");
    }

    function action_stop() {
        serviceOp(mpris2Source.current, "Stop");
    }

    function serviceOp(src, op) {
        var service = mpris2Source.serviceForSource(src);
        var operation = service.operationDescription(op);

        return service.startOperationCall(operation);
    }

    function updateMprisSourcesModel () {

        var model = [{
            'text': i18n("Choose player automatically"),
            'icon': 'emblem-favorite',
            'source': mpris2Source.multiplexSource
        }]

        var sources = mpris2Source.sources
        console.log("====updateMprisSourcesModel,count="+sources.length)
        for (var i = 0, length = sources.length; i < length; ++i) {
            var source = sources[i]
            if (source === mpris2Source.multiplexSource) {
                continue
            }

            model.push({
                'text': mpris2Source.data[source]["Identity"],
                'icon': mpris2Source.data[source]["Desktop Icon Name"] || mpris2Source.data[source]["Desktop Entry"] || source,
                'source': source
            });
        }

        root.mprisSourcesModel = model;
    }

    states: [
        State {
            name: "playing"
            when: !root.noPlayer && mpris2Source.currentData.PlaybackStatus === "Playing"

            PropertyChanges {
                target: plasmoid
                icon: "media-playback-playing"
                toolTipMainText: track
                toolTipSubText: artist ? i18nc("by Artist (player name)", "by %1 (%2)", artist, identity) : identity
            }
        },
        State {
            name: "paused"
            when: !root.noPlayer && mpris2Source.currentData.PlaybackStatus === "Paused"

            PropertyChanges {
                target: plasmoid
                icon: "media-playback-paused"
                toolTipMainText: track
                toolTipSubText: artist ? i18nc("by Artist (paused, player name)", "by %1 (paused, %2)", artist, identity) : i18nc("Paused (player name)", "Paused (%1)", identity)
            }
        }
    ]
}
