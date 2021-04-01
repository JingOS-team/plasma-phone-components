/***************************************************************************
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>                      *
 *                                                                         *
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

#include "launcheritem.h"
#include <QDebug>
#include <QMetaType>
#include <QList>

class PrivateLauncherItem
{
public:
    PrivateLauncherItem() {
        mPageIndex = 0;
        mName.clear();
        mIcon.clear();
        mUrl.clear();
        mStorageId.clear();
        mEntryPath.clear();
        mLocation = Desktop;
        mWindow = nullptr;
        mType = LauncherItem::App;
        mStartupNotify = true;
        mType = 0;
        mItemIndex = 0;
        mAppPid = 0;
        mWindowList.clear();
        mIsSystemApp = false;
    }

    ~PrivateLauncherItem() {
    }

    int mPageIndex;
    QString mExecName;
    QString mName;
    QString mIcon;
    QUrl mUrl;
    QString mStorageId;
    QString mEntryPath;
    int mLocation;
    KWayland::Client::PlasmaWindow *mWindow;
    QList<KWayland::Client::PlasmaWindow* > mWindowList;
    bool mStartupNotify;
    int mType;
    int mItemIndex;
    qint64 mAppPid;
    bool mIsSystemApp;
};

LauncherItem::LauncherItem(QObject *parent) : QObject(parent),
    p(new PrivateLauncherItem())
{
}

LauncherItem::~LauncherItem()
{
    delete p;
}

void LauncherItem::initData()
{
    p->mPageIndex = 0;
    p->mName.clear();
    p->mIcon.clear();
    p->mUrl.clear();
    p->mStorageId.clear();
    p->mEntryPath.clear();
    p->mLocation = Desktop;
    p->mWindow = nullptr;
    p->mType = LauncherItem::App;
    p->mStartupNotify = true;
    p->mType = 0;
    p->mItemIndex = 0;
    p->mAppPid = 0;
    p->mIsSystemApp = false;
}

int LauncherItem::pageIndex()
{
    return p->mPageIndex;
}

int LauncherItem::setPageIndex(const int &pageIndex)
{
    if(p->mPageIndex != pageIndex)
        p->mPageIndex = pageIndex;
    emit pageIndexChanged();
    return p->mPageIndex;
}

QString LauncherItem::execName()
{
    return p->mExecName;
}

QString LauncherItem::setExecName(const QString &execName)
{
    if(p->mExecName != execName)
        p->mExecName = execName;
    emit execNameChanged();
    return p->mExecName;
}

QString LauncherItem::name()
{
    return p->mName;
}

QString LauncherItem::setName(const QString &name)
{
    if(p->mName != name)
        p->mName = name;
    emit nameChanged();
    return p->mName;
}

QString LauncherItem::icon()
{
    return p->mIcon;
}

QString LauncherItem::setIcon(const QString &icon)
{
    if(p->mIcon != icon)
        p->mIcon = icon;
    emit iconChanged();
    return p->mIcon;
}

QUrl LauncherItem::url()
{
    return p->mUrl;
}

QUrl LauncherItem::setUrl(const QUrl &url)
{
    if(p->mUrl != url)
        p->mUrl = url;
    emit urlChanged();
    return p->mUrl;
}

QString LauncherItem::storageId()
{
    return p->mStorageId;
}

QString LauncherItem::setStorageId(const QString &storageId)
{
    if(p->mStorageId != storageId)
        p->mStorageId = storageId;
    emit storageIdChanged();
    return p->mStorageId;
}

QString LauncherItem::entryPath()
{
    return p->mEntryPath;
}

QString LauncherItem::setEntryPath(const QString &entryPath)
{
    if(p->mEntryPath != entryPath)
        p->mEntryPath = entryPath;
    emit entryPathChanged();
    return p->mEntryPath;
}

int LauncherItem::location()
{
    return p->mLocation;
}

int LauncherItem::setLocation(const int &location)
{
    if(p->mLocation != location)
        p->mLocation = location;
    emit locationChanged();
    return p->mLocation;
}

KWayland::Client::PlasmaWindow *LauncherItem::window()
{
    return p->mWindow;
}

KWayland::Client::PlasmaWindow *LauncherItem::setWindow(KWayland::Client::PlasmaWindow *window)
{
    if(p->mWindow != window)
        p->mWindow = window;
    emit windowChanged();
    return p->mWindow;
}

void LauncherItem::addWindow(KWayland::Client::PlasmaWindow* window)
{
    setWindow(window);
    p->mWindowList.append(window);
}

void LauncherItem::removeWindow(KWayland::Client::PlasmaWindow* window)
{
    for (int i = 0; i < p->mWindowList.size(); ++i) {
        if (p->mWindowList.at(i) == window) {
            p->mWindowList.removeAt(i);
        }
    }

    if(p->mWindowList.count() == 0 || p->mWindowList.empty()) {
        setWindow(nullptr);
    }
    
    window = nullptr;
}

bool LauncherItem::applicationRunning()
{
    if(p->mWindow != nullptr)
        return true;
    return false;
}

bool LauncherItem::startupNotify()
{
    return p->mStartupNotify;
}

bool LauncherItem::setStartupNotify(const bool &startupNotify)
{
    if(p->mStartupNotify != startupNotify)
        p->mStartupNotify = startupNotify;
    emit startupNotifyChanged();
    return p->mStartupNotify;
}

int LauncherItem::type()
{
    return p->mType;
}

int LauncherItem::setType(const int &type)
{
    if(p->mType != type)
        p->mType = type;
    emit typeChanged();
    return p->mType;
}

int LauncherItem::itemIndex()
{
    return p->mItemIndex;
}

int LauncherItem::setItemIndex(const int &itemIndex)
{
    if(p->mItemIndex != itemIndex)
        p->mItemIndex = itemIndex;
    emit itemIndexChanged();
    return p->mItemIndex;
}

void LauncherItem::setItemData(LauncherItem *itemData)
{
    if(itemData == nullptr)
        return;

    setPageIndex(itemData->pageIndex());
    setName(itemData->name());
    setIcon(itemData->icon());
    setUrl(itemData->url());
    setStorageId(itemData->storageId());
    setEntryPath(itemData->entryPath());
    setLocation(itemData->location());
    setWindow(itemData->window());
    setStartupNotify(itemData->startupNotify());
    setType(itemData->type());
    setItemIndex(itemData->itemIndex());
    setIsSystemApp(itemData->isSystemApp());
}

qint64 LauncherItem::appPid()
{
    return p->mAppPid;
}
qint64 LauncherItem::setAppPid(const qint64 &appPid)
{
    if(p->mAppPid != appPid)
        p->mAppPid = appPid;
    emit appPidChanged();
    return p->mAppPid;
}

bool LauncherItem::isSystemApp()
{
    return p->mIsSystemApp;
}

bool LauncherItem::setIsSystemApp(const bool &isSystemApp)
{
    if(p->mIsSystemApp != isSystemApp)
        p->mIsSystemApp = isSystemApp;
    emit isSystemAppChanged();
    return p->mIsSystemApp;
}
