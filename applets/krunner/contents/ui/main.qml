/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *   Copyright 2021 Liu Bangguo <liubangguo@jingos.com>
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

import QtQuick 2.1
import QtQuick.Window 2.1
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.milou 0.1 as Milou
import org.kde.kirigami 2.14 as Kirigami
import jingos.display 1.0

Item {
    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    Layout.minimumWidth: Math.min(plasmoid.availableScreenRect.width, plasmoid.availableScreenRect.height) - Kirigami.Units.gridUnit * 2

    Rectangle {
        id: background

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins:  units.gridUnit
        }
        radius: height/2
        height:  layout.implicitHeight + units.gridUnit
        color: Qt.rgba(1,1,1, 0.3)

        RowLayout {
            id: layout
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: background.radius/2
            }
            Kirigami.Icon {
                source: "search"
                Layout.fillHeight: true
                Layout.preferredWidth: height
                color: "white"
            }
            PlasmaExtras.Heading {
                level: 2
                text: i18nd("plasma-phone-components", "Search...")
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: window.showMaximized()
        }
        Kirigami.AbstractApplicationWindow {
            id: window
            visible: false
            onVisibleChanged: {
                if (visible) {
                    queryField.forceActiveFocus();
                }
            }
            header: Controls.ToolBar {
                height:  Kirigami.Units.gridUnit * 2
                contentItem: Kirigami.SearchField {
                    id: queryField
                    focus: true
                }
            }
            Rectangle {
                anchors.fill: parent
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.BackgroundColor
                PlasmaCore.IconItem {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width:  Math.min(parent.width, parent.height) * 0.8
                    height: width
                    opacity: 0.2
                    source: "search"
                }
                Controls.ScrollView {
                    anchors.fill: parent
                    Milou.ResultsListView {
                        id: listView
                        queryString: queryField.text
                        highlight: null
                        PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup
                        anchors.rightMargin: JDisplay.dp(10)

                        onActivated: {
                            window.visible = false;
                            queryField.text = "";
                        }
                        onUpdateQueryString: {
                            queryField.text = text
                            queryField.cursorPosition = cursorPosition
                        }
                        delegate: Kirigami.BasicListItem {
                            id: resultDelegate
                            property var additionalActions: typeof actions !== "undefined" ? actions : []
                            icon: model.decoration
                            label: typeof modelData !== "undefined" ? modelData : model.display
                            subtitle: model.subtext || ""
                            onClicked: {
                                listView.currentIndex = model.index
                                listView.runCurrentIndex()
                            }
                            Row {
                                id: actionsRow

                                Repeater {
                                    id: actionsRepeater
                                    model: resultDelegate.additionalActions

                                    Controls.ToolButton {
                                        width: height
                                        height: listItem.height
                                        visible: modelData.visible || true
                                        enabled: modelData.enabled || true

                                        Accessible.role: Accessible.Button
                                        Accessible.name: modelData.text
                                        checkable: checked
                                        checked: resultDelegate.activeAction === index
                                        focus: resultDelegate.activeAction === index

                                        Kirigami.Icon{
                                            anchors.centerIn: parent
                                            width:  JDisplay.dp(units.iconSizes.small)
                                            height:  JDisplay.dp(units.iconSizes.small)
                                            // ToolButton cannot cope with QIcon
                                            source: modelData.icon || ""
                                            active: parent.hovered || parent.checked
                                        }

                                        onClicked: resultDelegate.ListView.view.runAction(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
