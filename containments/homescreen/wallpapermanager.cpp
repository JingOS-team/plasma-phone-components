/*
 *  Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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
       return cfg.readEntry("defaultLauncherWallpaper", QString());
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
       return cfg.readEntry("defaultLockScreenWallpaper", QString());
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