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

#ifndef WALLPAPERMANAGER
#define WALLPAPERMANAGER

#include <QObject>

class WallpaperManager : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.jing.systemui.wallpaper")
    Q_PROPERTY(QString launcherWallpaper READ launcherWallpaper WRITE setLauncherWallpaper NOTIFY launcherWallpaperChanged)
    Q_PROPERTY(QString lockscreenWallpaper READ lockscreenWallpaper WRITE setLockscreenWallpaper NOTIFY lockscreenWallpaperChanged)

public:
    enum WallpaperType {
        BOTH = 0,
        LAUNCHER = 1,
        LOCKSCREEN = 2
    };
    
    static WallpaperManager *instance();

    QString launcherWallpaper();
    QString setLauncherWallpaper(QString path);

    QString lockscreenWallpaper();
    QString setLockscreenWallpaper(QString path);

    Q_INVOKABLE void setWallpaper(int type, QString path);

Q_SIGNALS:
    void launcherWallpaperChanged(QString path);
    void lockscreenWallpaperChanged(QString path);

private:
    explicit WallpaperManager(QObject* parent = nullptr);
    ~WallpaperManager() override;

    static WallpaperManager* m_instance;
    QString m_launcherWallpaper;
    QString m_lockscreenWallpaper;
};

#endif
