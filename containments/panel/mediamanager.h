/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#ifndef MEDIAMANAGER_H
#define MEDIAMANAGER_H

#include <QObject>
#include <QDBusServiceWatcher>


class MediaManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool dbusConnect READ dbusConnect WRITE setDbusConnect NOTIFY dbusConnectChanged)
    Q_PROPERTY(int playState READ playState WRITE setPlayState NOTIFY playStateChanged)

    enum PlayStateType {
        STOP = 0,
        PLAY = 1
    };

public:
    explicit MediaManager(QObject *parent = nullptr);

    void initDBusWatcher();

    Q_INVOKABLE void previous();
    Q_INVOKABLE void next();
    Q_INVOKABLE void playAndPause();

    bool dbusConnect();
    bool setDbusConnect(const bool &dbusConnect);

    int playState();
    int setPlayState(const int &playState);

signals:
    void mediaInfoChanged(const QString &imagePath,
                            const QString &title,
                            const QString &artist,
                            const QString &album);
    void dbusConnectChanged();
    void playStateChanged();

    void mouseOnTopLeftConer();
    void mouseOnTopRightConer();

public slots:
    void onMouseOnTopLeftConer();
    void onMouseOnTopRightConer();

    void onServiceRegistered(const QString &serviceName);
    void onServiceUnregistered(const QString &serviceName);

    void onKWinServiceRegistered(const QString &serviceName);
    void onKWinServiceUnregistered(const QString &serviceName);
    void getUpdateTracksState(const QString &imagePath,
                              const QString &title,
                              const QString &artist,
                              const QString &album);
    void getPlayingState(const bool &state);

private:
    QDBusServiceWatcher *serviceWatcher;
    bool mDbusConnect;
    int mPlayState;
};
#endif // MEDIAMANAGER_H
