/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
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
