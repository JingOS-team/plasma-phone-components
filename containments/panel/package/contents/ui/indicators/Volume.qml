/*
    Copyright 2019 Aditya Mehra <Aix.m@outlook.com>
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>
    Copyright 2021 Bangguo Liu <liubangguo@jingos.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import jingos.display 1.0


Item {
    property bool volumeFeedback: true
    property bool toBeDefault: false
    property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)
    property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)
    readonly property string dummyOutputName: "auto_null"
    readonly property int currentVolume: paSinkModel.preferredSink? (!paSinkModel.preferredSink.muted ? paSinkModel.preferredSink.volume : 0) : 0
    property bool isShowWhite: root.showColorWhite//!MobileShell.HomeScreenControls.isSystemApp

    Layout.alignment: Qt.AlignVCenter
    width:JDisplay.dp(11)
    height:JDisplay.dp(11)
    visible: paSinkModel.preferredSink && paSinkModel.preferredSink.muted

    Image {
        id: paIcon

        source: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink)
            ? iconName(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
            : iconName(0, true)

        sourceSize.width: parent.width
        sourceSize.height: parent.height
        antialiasing: true

        visible: paSinkModel.preferredSink && paSinkModel.preferredSink.muted
    }

    function iconName(volume, muted, prefix) {
        var icon = !isShowWhite ? "file:///usr/share/icons/jing/jing/settings/Mute.svg" : "file:///usr/share/icons/jing/jing/settings/Mute_white.svg"

        return icon;
    }

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function boundVolume(volume) {
        return Math.max(PulseAudio.MinimalVolume, Math.min(volume, maxVolumeValue));
    }

    function volumePercent(volume, max){
        if(!max) {
            max = PulseAudio.NormalVolume;
        }
        return Math.round(volume / max * 100.0);
    }

    function playFeedback(sinkIndex) {
        if(!volumeFeedback){
            return;
        }
        if(sinkIndex == undefined) {
            sinkIndex = paSinkModel.preferredSink.index;
        }
        feedback.play(sinkIndex)
    }

    function increaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume + volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();
    }

    function decreaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume - volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();
    }

    function muteVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var toMute = !paSinkModel.preferredSink.muted;
        paSinkModel.preferredSink.muted = toMute;
        osd.show(toMute ? 0 : volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue));
        if (!toMute) {
            playFeedback();
        }
    }

    function setVolume(num) {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(num);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        playFeedback();
    }


    SinkModel {
        id: paSinkModel

        onPreferredSinkChanged:{
            if(preferredSink && toBeDefault == true){
                preferredSink.volume = 30000;
            }
        }
    }

    VolumeOSD {
        id: osd
    }

    VolumeFeedback {
        id: feedback
    }

    GlobalActionCollection {
        // KGlobalAccel cannot transition from kmix to something else, so if
        // the user had a custom shortcut set for kmix those would get lost.
        // To avoid this we hijack kmix name and actions. Entirely mental but
        // best we can do to not cause annoyance for the user.
        // The display name actually is updated to whatever registered last
        // though, so as far as user visible strings go we should be fine.
        // As of 2015-07-21:
        //   componentName: kmix
        //   actions: increase_volume, decrease_volume, mute
        name: "kmix"
        displayName: "kmix"//root.displayName

        GlobalAction {
            objectName: "increase_volume"
            text: i18nd("plasma-phone-components", "Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseVolume()
        }

        GlobalAction {
            objectName: "decrease_volume"
            text: i18nd("plasma-phone-components", "Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseVolume()
        }

        GlobalAction {
            objectName: "mute"
            text: i18nd("plasma-phone-components", "Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: muteVolume()
        }

        GlobalAction {
            objectName: "meta_up_increase_volume"
            text: i18nd("plasma-phone-components", "Meta Up Increase Volume")
            shortcut: Qt.MetaModifier + Qt.Key_Up
            onTriggered: increaseVolume()
        }

        GlobalAction {
            objectName: "meta_down_decrease_volume"
            text: i18nd("plasma-phone-components", "Meta Down Decrease Volume")
            shortcut: Qt.MetaModifier + Qt.Key_Down
            onTriggered: decreaseVolume()
        }

    }
}


