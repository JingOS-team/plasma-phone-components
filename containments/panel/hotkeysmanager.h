/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#ifndef HOTKEYSMANAGER_H
#define HOTKEYSMANAGER_H

#include <QObject>
#include <QDBusServiceWatcher>

class HotkeysManager : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.dbus.jingos.panel")

public:
    explicit HotkeysManager(QObject *parent = nullptr);

    void initDBusWatcher();

    //通知中心删除通知发送的信号
    Q_INVOKABLE void closeNotificationId(uint id);
signals:
    void mouseOnTopLeftConer();
    void mouseOnTopRightConer();

    void showNotificationCenter();
    void showControlCenter();

    void closeLockScreeNotificationId(uint id);
    
public slots:
    void onKWinServiceRegistered(const QString &serviceName);
    void onKWinServiceUnregistered(const QString &serviceName);
    
    void onMouseOnTopLeftConer();
    void onMouseOnTopRightConer();

    void notificationCenterAction();
    void controlCenterAction();

    void closeLockScreeNotificationAction(uint id);
private:

};
#endif // HotkeysManager
