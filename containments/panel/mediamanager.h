/***************************************************************************
 *   Copyright (C) 2021 Wang Rui <wangrui@jingos.com>                      *
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

public slots:
    void onServiceRegistered(const QString &serviceName);
    void onServiceUnregistered(const QString &serviceName);
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
