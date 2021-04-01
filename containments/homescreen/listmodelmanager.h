/*
 *   Copyright (C) 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef LISTMODELMANAGER_H
#define LISTMODELMANAGER_H

//KDE
#include <KFileItem>
#include <KDesktopFile>
#include <KDirLister>

// Qt
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QSet>
#include <QStringList>
#include <QDBusConnection>
#include <QDBusError>
#include <QDBusServer>

#include "homescreen.h"
//#include "applicationlistmodel.h"
//#include "favoriteslistmodel.h"
#include "type.h"
#include "launcheritem.h"
#include "basemodel.h"

class ListModelManager;
class ApplicationListModel;

class ListModelManager : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.dbus.jingos.launcher")

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int favoriteCount READ favoriteCount NOTIFY favoriteCountChanged)
    Q_PROPERTY(int maxFavoriteCount READ maxFavoriteCount WRITE setMaxFavoriteCount NOTIFY maxFavoriteCountChanged)

    Q_PROPERTY(QAbstractListModel* launcherPageModel READ launcherPageModel NOTIFY launcherPageModelChanged)

public:
    ListModelManager(HomeScreen *parent = nullptr);
    ~ListModelManager() override;

    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);

    int count() const { return m_applicationList.count(); }
    int favoriteCount() const { return m_favorites.count();}

    int maxFavoriteCount() const;
    void setMaxFavoriteCount(int count);

    Q_INVOKABLE void moveItem(int from, int to, int page = 0);
    Q_INVOKABLE void movePlaceholderItem(int to);

    Q_INVOKABLE void runApplication(const QString &storageId, KWayland::Client::PlasmaWindow *window = nullptr);

    Q_INVOKABLE void loadApplications();

    QAbstractListModel* launcherPageModel() const;
    void setLauncherPageModel(QString pageNum);

    Q_INVOKABLE void addLauncherPage(int page);
    Q_INVOKABLE void refreshPageModel();

    Q_INVOKABLE QAbstractListModel *getMdoelFromPage(int page);
    Q_INVOKABLE QAbstractListModel *getFavoriteAppMdoel();

    Q_INVOKABLE void dragItemToModel(LauncherItem* item, int fromModel , int toModel = -1);
    Q_INVOKABLE void addPlaceholderItem(int page = -1);
    Q_INVOKABLE void removePlaceholderItem();
    Q_INVOKABLE void replacePlaceholderItemToAppItem(LauncherItem* item);
    Q_INVOKABLE void removeLauncherItem(LauncherItem* item);
    Q_INVOKABLE int getPlaceholderPosition();

    Q_INVOKABLE bool getPanelBehavorState(QString desktop);

    Q_INVOKABLE int getDesktopMaxIconNum();
    Q_INVOKABLE int getFavoriteMaxIconNum();
    Q_INVOKABLE void refreshLocation(const int &page);

public Q_SLOTS:
    void sycocaDbChanged(const QStringList &change);
    void updateRunAppState();
    
    void onStarted(const QUrl &_url);
    void onCompleted();
    void onCompletedUrl(const QUrl &_url);
    void onCanceled();
    void onCanceled(const QUrl &_url);
    void onRedirection(const QUrl &_url);
    void onRedirection(const QUrl &oldUrl, const QUrl &newUrl);
    void onClear();
    void onClear(const QUrl &_url);
    void onNewItems(const KFileItemList &fileItems);
    void onItemsAdded(const QUrl &directoryUrl, const KFileItemList &items);
    void onItemsFilteredByMime(const KFileItemList &items);
    void onItemsDeleted(const KFileItemList &items);
    void onRefreshItems(const QList<QPair<KFileItem, KFileItem> > &items);
    void onInfoMessage(const QString &msg);
    void onPercent(int percent);
    void onTotalSize(KIO::filesize_t size);
    void onProcessedSize(KIO::filesize_t size);
    void onSpeed(int bytes_per_second);

    Q_INVOKABLE void openWithApp(const QString &exec, const QStringList &urls);

Q_SIGNALS:
    void countChanged();
    void favoriteCountChanged();
    void maxFavoriteCountChanged();
    void launcherPageModelChanged();

private:
    void initWayland();
    bool checkFirstPageApp(const QString &name);
    bool checkFavoriteApp(const QString &name);

    void writePositions(const QString &storageId, const int &page, const int &index);
    void loadPositions();
    void removePosition(const QString &storageId, const int &page);
    void replaceIconPosition();
    void swapPosition(BaseModel<LauncherItem*>* listModel, int index);
   
    void removeLauncherPageModel(QString pageNum);
    QUrl resolve(const QString& url);

    QList<ApplicationData> m_applicationList;

    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    HomeScreen *m_homeScreen = nullptr;
    int m_maxFavoriteCount = 0;

    QStringList m_appOrder;
    QStringList m_favorites;
    QSet<QString> m_desktopItems;
    QHash<QString, int> m_appPositions;


    QList<ApplicationData* > *m_listModel;

    QMap<int, BaseModel<LauncherItem*>* > applicationModelMap;
    QMap<QString, int> showIconsMap;
    QMap<QString, QString> positionsMap;

    LauncherItem *placeholderitem;
    QStringList panelBehavorList;

    bool runAppActive;
    
    BaseModel<QString> m_launcherPageModel;
    KDirLister *m_dirLister;
};

#endif // LISTMODELMANAGER_H
