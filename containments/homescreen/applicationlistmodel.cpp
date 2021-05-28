/***************************************************************************
 *   Copyright (C) 2021 Wang Rui <wangrui@jingos.com>                      *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "applicationlistmodel.h"
#include <QMetaType>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<ApplicationListModel*>();
}

ApplicationListModel::~ApplicationListModel()
{

}
void ApplicationListModel::setAppData(ApplicationData data)
{
    LauncherItem *item = new LauncherItem(this);
    item->setName(data.name);
    item->setIcon(data.icon);
    item->setEntryPath(data.entryPath);
    item->setStorageId(data.storageId);
    item->setLocation(data.location);
    item->setWindow(data.window);

//    addItem(item);
}
