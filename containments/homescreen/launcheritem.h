/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#ifndef LAUNCHERITEM_H
#define LAUNCHERITEM_H

#include <QObject>
#include <QUrl>
#include "basemodel.h"
#include "type.h"

class PrivateLauncherItem;
class LauncherItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int pageIndex READ pageIndex WRITE setPageIndex NOTIFY pageIndexChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString storageId READ storageId WRITE setStorageId NOTIFY storageIdChanged)
    Q_PROPERTY(QString entryPath READ entryPath WRITE setEntryPath NOTIFY entryPathChanged)
    Q_PROPERTY(int location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(bool applicationRunning READ applicationRunning NOTIFY applicationRunningChanged)
    Q_PROPERTY(bool startupNotify READ startupNotify WRITE setStartupNotify NOTIFY startupNotifyChanged)
    Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(int itemIndex READ itemIndex WRITE setItemIndex NOTIFY itemIndexChanged)
    Q_PROPERTY(QString execName READ execName WRITE setExecName NOTIFY execNameChanged)
    Q_PROPERTY(qint64 appPid READ appPid WRITE setAppPid NOTIFY appPidChanged)
    Q_PROPERTY(bool isSystemApp READ isSystemApp WRITE setIsSystemApp NOTIFY isSystemAppChanged)
    Q_PROPERTY(QString categories READ categories WRITE setCategories NOTIFY categoriesChanged)

public:
    explicit LauncherItem(QObject *parent = nullptr);
    ~LauncherItem();

    enum ItemType {
        None = 0,
        App,
        Folder,
        Page
    };

    void initData();

    int pageIndex();
    int setPageIndex(const int &pageIndex);

    QString execName();
    QString setExecName(const QString &execName);

    QString name();
    QString setName(const QString &name);

    QString icon();
    QString setIcon(const QString &icon);

    QUrl url();
    QUrl setUrl(const QUrl &url);

    QString storageId();
    QString setStorageId(const QString &storageId);

    QString entryPath();
    QString setEntryPath(const QString &entryPath);

    int location();
    int setLocation(const int &location);

    bool applicationRunning();

    bool startupNotify();
    bool setStartupNotify(const bool &startupNotify);

    int type();
    int setType(const int &type);

    int itemIndex();
    int setItemIndex(const int &itemIndex);

    qint64 appPid();
    qint64 setAppPid(const qint64 &appPid);

    void setItemData(LauncherItem *itemData);

    bool isSystemApp();
    bool setIsSystemApp(const bool &isSystemApp);

    QString categories();
    QString setCategories(const QString &categories);

signals:
    void pageIndexChanged();
    void nameChanged();
    void iconChanged();
    void urlChanged();
    void storageIdChanged();
    void entryPathChanged();
    void locationChanged();
    void startupNotifyChanged();
    void typeChanged();
    void itemIndexChanged();
    void applicationRunningChanged();
    void execNameChanged();
    void appPidChanged();
    void isSystemAppChanged();
    void categoriesChanged();
    
private:
    PrivateLauncherItem *p;
};

#endif // LAUNCHERITEM_H
