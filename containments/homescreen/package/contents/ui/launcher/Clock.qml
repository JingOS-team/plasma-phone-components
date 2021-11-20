/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.core 2.0
import org.kde.plasma.private.digitalclock 1.0 as DC
import jingos.display 1.0

Rectangle {
    
    property  bool is24HourTime : false
    color: "transparent"
    
    Label {
        id: timeLable
        text: dateTimeTimer.timeString//
        color: "#FFFFFF"
        font.weight: Font.Light // this font weight may switch to regular on distros that don't have a light variant
        font.pixelSize: JDisplay.sp(63)
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: "#757575"
        }
    }
    Label {
        id: dateLable
        anchors{
           top: timeLable.bottom
           topMargin: JDisplay.dp(5)
//           horizontalCenter: timeLable.horizontalCenter
        }
        text: dateTimeTimer.dateString
        color: "#FFFFFF"

        font.pixelSize: JDisplay.sp(17)
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: "#757575"
        }
    }

    Timer {
        id:dateTimeTimer
        property string dateString : ""
        property string timeString : ""
        property var locale : Qt.locale()
        property string datePrefix:{
            timezoneProxy.getRegionTimeFormat() === "zh_" ? i18nd("plasma-phone-components", "day") : ""
        }
        running: true
        repeat: true
        interval: 1000
        triggeredOnStart:true
        onTriggered: {
            var currentDate = new Date();
            var timeStr = currentDate.toLocaleTimeString(dateTimeTimer.locale,timezoneProxy.isSystem24HourFormat ?
                                     "hh:mm" : (timezoneProxy.getRegionTimeFormat() === "zh_"? "AP hh:mm" : "hh:mm AP"));
            if(timezoneProxy.getRegionTimeFormat() === "zh_"){
                if(timeStr.search("AM") !== -1)
                    timeStr = timeStr.replace("AM","上午");
                if(timeStr.search("PM") !== -1)
                    timeStr = timeStr.replace("PM","下午");
                dateTimeTimer.dateString = currentDate.toLocaleDateString(dateTimeTimer.locale, "MMMd") + "日";
                dateTimeTimer.dateString+=currentDate.toLocaleDateString(dateTimeTimer.locale, " dddd")
            }else{
                if(timeStr.search("上午") !== -1)
                    timeStr = timeStr.replace("上午","AM");
                if(timeStr.search("下午") !== -1)
                    timeStr = timeStr.replace("下午","PM");
                dateTimeTimer.dateString = currentDate.toLocaleDateString(dateTimeTimer.locale, "dddd,MMM d") + dateTimeTimer.datePrefix;
            }
            dateTimeTimer.timeString= timeStr
        }
    }

    DC.TimeZoneFilterProxy{
        id:timezoneProxy
    }
}
