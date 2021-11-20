/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "mediamanager.h"

#include <QDebug>
#include <QtQml>
#include <QDebug>
#include <QDBusConnection> 
#include <QDBusInterface> 
#include <QDBusReply> 

#define DBUS_SERVICE_NAME            "org.kde.media.jingos.media"
#define DBUS_METHOD_PATH_NAME            "/services/jingos_dbus/jingosdbus"
#define DBUS_PATH_NAME            "/media/jingos/media"
#define DBUS_INTERFACE_NAME            "org.kde.media.jingos.media"
#define DBUS_PLAYINGSTATE_SIGNAL_NAME            "updatePlayingState"

#define DEFULT_STR            "No audio playback"
#define DEFULT_PATH            "file:///usr/share/icons/jing/album.png"

const QString KWIN_DEBUS_SERVICE = "org.kde.KWin";
const QString KWIN_DEBUS_PATH = "/KWin";
const QString KWIN_DEBUS_INTERFACE = "org.kde.KWin";

MediaManager::MediaManager(QObject *parent)
    : QObject(parent),
    mDbusConnect(false),
    mPlayState(STOP)
{
    initDBusWatcher();
}

void MediaManager::initDBusWatcher()
{
    serviceWatcher = new QDBusServiceWatcher(DBUS_SERVICE_NAME, QDBusConnection::sessionBus(),
                                       QDBusServiceWatcher::WatchForOwnerChange);

    QObject::connect(serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this,  &MediaManager::onServiceRegistered);
    QObject::connect(serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this,  &MediaManager::onServiceUnregistered);


    // QDBusServiceWatcher *kwinWatcher = new QDBusServiceWatcher(KWIN_DEBUS_SERVICE, QDBusConnection::sessionBus(),
    //                                    QDBusServiceWatcher::WatchForOwnerChange);
    // QObject::connect(kwinWatcher, &QDBusServiceWatcher::serviceRegistered, this,  &MediaManager::onKWinServiceRegistered);
    // QObject::connect(kwinWatcher, &QDBusServiceWatcher::serviceUnregistered, this,  &MediaManager::onKWinServiceUnregistered);

    // QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));
    // QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void MediaManager::onServiceRegistered(const QString &serviceName)
{
    setDbusConnect(true);
    QDBusConnection::sessionBus().connect(DBUS_SERVICE_NAME, DBUS_PATH_NAME, DBUS_INTERFACE_NAME, "updateTracksState", this, SLOT(getUpdateTracksState(const QString &,
                                            const QString &,
                                            const QString &,
                                            const QString &)));
    QDBusConnection::sessionBus().connect(DBUS_SERVICE_NAME, DBUS_PATH_NAME, DBUS_INTERFACE_NAME, DBUS_PLAYINGSTATE_SIGNAL_NAME, this, SLOT(getPlayingState(const bool &)));
}

void MediaManager::onServiceUnregistered(const QString &serviceName)
{
    setDbusConnect(false);
    QDBusConnection::sessionBus().disconnect(DBUS_SERVICE_NAME, DBUS_PATH_NAME, DBUS_INTERFACE_NAME, "updateTracksState", this, SLOT(getUpdateTracksState(const QString &,
                                            const QString &,
                                            const QString &,
                                            const QString &)));

    QDBusConnection::sessionBus().disconnect(DBUS_SERVICE_NAME, DBUS_PATH_NAME, DBUS_INTERFACE_NAME, DBUS_PLAYINGSTATE_SIGNAL_NAME, this, SLOT(getPlayingState(const bool &)));
    
    setPlayState(STOP);
    emit mediaInfoChanged(DEFULT_PATH,
                          DEFULT_STR,
                          DEFULT_STR,
                          DEFULT_STR);
}

void MediaManager::onKWinServiceRegistered(const QString &serviceName)
{
    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));
    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void MediaManager::onKWinServiceUnregistered(const QString &serviceName)
{
    QDBusConnection::sessionBus().disconnect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));

    QDBusConnection::sessionBus().disconnect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void MediaManager::getUpdateTracksState(const QString &imagePath,
                                        const QString &title,
                                        const QString &artist,
                                        const QString &album)
{
    setPlayState(PLAY);
    emit mediaInfoChanged(imagePath,
                          title,
                          artist,
                          album);
}

void MediaManager::getPlayingState(const bool &state)
{
    if(state)
        setPlayState(PLAY);
    else
        setPlayState(STOP);
}


void MediaManager::previous()
{
    QDBusInterface interface(DBUS_SERVICE_NAME, DBUS_METHOD_PATH_NAME, "", QDBusConnection::sessionBus());
    QDBusReply<QString> reply = interface.call("previousTrack");

    if (reply.isValid()) {
        qDebug() << "reply.value: " << reply.value();
    } else {
        qDebug() << "reply.error: " << reply.error();
    }
}
void MediaManager::next()
{
    QDBusInterface interface(DBUS_SERVICE_NAME, DBUS_METHOD_PATH_NAME, "", QDBusConnection::sessionBus());
    QDBusReply<QString> reply = interface.call("nextTrack");

    if (reply.isValid()) {
        qDebug() << "reply.value: " << reply.value();
    } else {
        qDebug() << "reply.error: " << reply.error();
    }
}

void MediaManager::playAndPause()
{
    QDBusInterface interface(DBUS_SERVICE_NAME, DBUS_METHOD_PATH_NAME, "", QDBusConnection::sessionBus());
    QDBusReply<QString> reply = interface.call("play");
    
    if(playState() == STOP) {
        setPlayState(PLAY);
    } else {
        setPlayState(STOP);
    }

    if (reply.isValid()) {
        qDebug() << "reply.value: " << reply.value();
    } else {
        qDebug() << "reply.error: " << reply.error();
    }
}

bool MediaManager::dbusConnect()
{
    return mDbusConnect;
}

bool MediaManager::setDbusConnect(const bool &dbusConnect)
{
    if(mDbusConnect == dbusConnect)
        return mDbusConnect;
    mDbusConnect = dbusConnect;
    emit dbusConnectChanged();
    return mDbusConnect; 
}

int MediaManager::playState()
{
    return mPlayState;
}

int MediaManager::setPlayState(const int &playState)
{
    if(mPlayState == playState)
        return mPlayState;
    mPlayState = playState;
    emit playStateChanged();
    return mPlayState;
}

void MediaManager::onMouseOnTopLeftConer()
{
    emit mouseOnTopLeftConer();
}

void MediaManager::onMouseOnTopRightConer()
{
    emit mouseOnTopRightConer();
}
