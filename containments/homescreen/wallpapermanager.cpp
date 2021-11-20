/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "wallpapermanager.h"
#include <QDebug>
#include <QDBusConnection>
#include <QDBusError>
#include <QDBusServer>
#include <KConfigGroup>
#include <KSharedConfig>

const QString SERVICE_NAME =  "org.jing.systemui.wallpaper";
const QString SERVICE_PATH =   "/jing/systemui/wallpaper";
const QString SERVICE_INTERFACE =  "org.jing.systemui.wallpaper";

WallpaperManager *WallpaperManager::m_instance = nullptr;

WallpaperManager::WallpaperManager(QObject *parent)
    : QObject(parent)
{
    if ( m_instance != nullptr )  
        return;
    
    if(!QDBusConnection::sessionBus().registerService(SERVICE_NAME))
    {
        qDebug() << "WallpaperManager: error:" << QDBusConnection::sessionBus().lastError().message();
    } else {
        qDebug() << "WallpaperManager: org.jing.systemui.wallpaper service ok ";
    }
    if (!QDBusConnection::sessionBus().registerObject(SERVICE_PATH, this, QDBusConnection::ExportAllContents))
    {
        qDebug() << "WallpaperManager: error:" << QDBusConnection::sessionBus().lastError().message();
    } else {
        qDebug() << "WallpaperManager: org.jing.systemui.wallpaper object path ok";
    }
}

WallpaperManager* WallpaperManager::instance()
{
    if ( m_instance == nullptr )  
        m_instance = new WallpaperManager();
    return m_instance;
}

WallpaperManager::~WallpaperManager()
{

}

QString WallpaperManager::launcherWallpaper()
{
    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "Wallpapers");
    QString path = cfg.readEntry("launcherWallpaper", QString());
    if(path.isEmpty() || path.isNull()) {
       return cfg.readEntry("defaultLauncherWallpaper", QString("file:///usr/share/wallpapers/jing/default.jpg"));
    } else {
        return path;
    }
}

QString WallpaperManager::setLauncherWallpaper(QString path)
{
    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "Wallpapers");
    cfg.writeEntry("launcherWallpaper", path);
    kdeglobals->sync();
    emit launcherWallpaperChanged(path);
    return path;
}

QString WallpaperManager::lockscreenWallpaper()
{
    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "Wallpapers");
    QString path = cfg.readEntry("lockscreenWallpaper", QString());
    if(path.isEmpty() || path.isNull()) {
       return cfg.readEntry("defaultLockScreenWallpaper", QString("file:///usr/share/wallpapers/jing/default.jpg"));
    } else {
        return path;
    }
}

QString WallpaperManager::setLockscreenWallpaper(QString path)
{
    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "Wallpapers");
    cfg.writeEntry("lockscreenWallpaper", path);
    kdeglobals->sync();
    emit lockscreenWallpaperChanged(path);
    return path;
}

void WallpaperManager::setWallpaper(int type, QString path)
{
    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "Wallpapers");

    if(type == 0) {
        cfg.writeEntry("launcherWallpaper", path);
        cfg.writeEntry("lockscreenWallpaper", path);
        emit launcherWallpaperChanged(path);
        emit lockscreenWallpaperChanged(path);

    } else if(type == 1) {
        cfg.writeEntry("launcherWallpaper", path);
        emit launcherWallpaperChanged(path);

    } else if(type == 2) {
        cfg.writeEntry("lockscreenWallpaper", path);
        emit lockscreenWallpaperChanged(path);
    } 

    kdeglobals->sync();
}
