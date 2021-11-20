/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "hotkeysmanager.h"

#include <QDebug>
#include <QtQml>
#include <QDebug>
#include <QDBusConnection> 
#include <QDBusInterface> 
#include <QDBusReply> 
#include <QDBusMessage>

const QString KWIN_DEBUS_SERVICE = "org.kde.KWin";
const QString KWIN_DEBUS_PATH = "/KWin";
const QString KWIN_DEBUS_INTERFACE = "org.kde.KWin";

HotkeysManager::HotkeysManager(QObject *parent)
    : QObject(parent)
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    if(!connection.registerService("org.dbus.jingos.panel")) {
        qDebug() << " === org.dbus.jingos.panel dbus error:" << connection.lastError().message();
    }
    if (!connection.registerObject("/org/jingos/panel", this, QDBusConnection::ExportAllSlots)) {
        qDebug() << " === org.dbus.jingos.panel dbus error:" << connection.lastError().message();
    }


    //添加锁屏通知删除通知响应
     QDBusConnection::sessionBus().connect(QString(), QString("/org/jingos/lockScreeNotification"),
        QString("org.jingos.lockScreenotification"), QString("closelockScreeNotificationId"), this,SLOT(closeLockScreeNotificationAction(uint)));

    initDBusWatcher();
}

void HotkeysManager::initDBusWatcher()
{
    QDBusServiceWatcher *kwinWatcher = new QDBusServiceWatcher(KWIN_DEBUS_SERVICE, QDBusConnection::sessionBus(),
                                       QDBusServiceWatcher::WatchForOwnerChange);
    QObject::connect(kwinWatcher, &QDBusServiceWatcher::serviceRegistered, this,  &HotkeysManager::onKWinServiceRegistered);
    QObject::connect(kwinWatcher, &QDBusServiceWatcher::serviceUnregistered, this,  &HotkeysManager::onKWinServiceUnregistered);

    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));
    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void HotkeysManager::onKWinServiceRegistered(const QString &serviceName)
{
    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));
    QDBusConnection::sessionBus().connect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void HotkeysManager::onKWinServiceUnregistered(const QString &serviceName)
{
    QDBusConnection::sessionBus().disconnect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopLeftConer", this, SLOT(onMouseOnTopLeftConer()));

    QDBusConnection::sessionBus().disconnect(KWIN_DEBUS_SERVICE, KWIN_DEBUS_PATH, KWIN_DEBUS_INTERFACE, "mouseOnTopRightConer", this, SLOT(onMouseOnTopRightConer()));
}

void HotkeysManager::onMouseOnTopLeftConer()
{
    emit mouseOnTopLeftConer();
}

void HotkeysManager::onMouseOnTopRightConer()
{
    emit mouseOnTopRightConer();
}

void HotkeysManager::notificationCenterAction()
{
    Q_EMIT showNotificationCenter();
}

void HotkeysManager::controlCenterAction()
{
    Q_EMIT showControlCenter();
}
void HotkeysManager::closeNotificationId(uint id)
{
    QDBusMessage message =QDBusMessage::createSignal(QStringLiteral("/org/jingos/notification"), 
            QStringLiteral("org.jingos.notification"), QStringLiteral("closeNotificationId"));
    message << id;

    QDBusConnection::sessionBus().send(message);
}

void HotkeysManager::closeLockScreeNotificationAction(uint id)
{
    Q_EMIT closeLockScreeNotificationId(id);
}
