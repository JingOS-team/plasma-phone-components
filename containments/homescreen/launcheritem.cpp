/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "launcheritem.h"
#include <QDebug>
#include <QMetaType>
#include <QList>
#include <QDBusInterface>
#include <QDBusReply>

#define DBUS_SERVICE_NAME            "com.jingos.jappmanagerd"
#define DBUS_PATH_NAME               "/com/jingos/jappmanagerd"
#define DBUS_INTERFACE_NAME          "com.jingos.jappmanagerd"

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
        mType = LauncherItem::App;
        mStartupNotify = true;
        mType = 0;
        mItemIndex = 0;
        mAppPid = 0;
        mIsSystemApp = false;
        mCategories.clear();
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
    bool mStartupNotify;
    int mType;
    int mItemIndex;
    qint64 mAppPid;
    bool mIsSystemApp;
    QString mCategories;
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

bool LauncherItem::applicationRunning()
{
    QDBusInterface interface(DBUS_SERVICE_NAME, DBUS_PATH_NAME, DBUS_INTERFACE_NAME, QDBusConnection::sessionBus());
    QDBusReply<bool> reply = interface.call("appIsRunning", storageId());

    if (reply.isValid()) {
        qDebug() << "reply.value: " << reply.value();
        return reply.value();
    } else {
        qDebug() << "reply.error: " << reply.error();
    }
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
    setStartupNotify(itemData->startupNotify());
    setType(itemData->type());
    setItemIndex(itemData->itemIndex());
    setIsSystemApp(itemData->isSystemApp());
    setCategories(itemData->categories());
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

QString LauncherItem::categories()
{
    return p->mCategories;
}

QString LauncherItem::setCategories(const QString &categories)
{
    if(p->mCategories != categories)
        p->mCategories = categories;
    emit categoriesChanged();
    return p->mCategories;
}
