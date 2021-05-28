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

// Self
#include "listmodelmanager.h"

// Qt
#include <QByteArray>
#include <QModelIndex>
#include <QProcess>
#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>
#include <QList>

// KDE
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KServiceGroup>
#include <KSharedConfig>
#include <KSycoca>
#include <KSycocaEntry>
#include <KDesktopFile>
#include <KShell>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>
#include <QMetaType>
#include <QDebug>
#include <QSettings>
#include <QStringList>
#include <QTimer>
#include <QList>

constexpr int MAX_FAVOURITES = 8;
constexpr int DESKTOP_MAX_ICON_NUM = 24;
constexpr int FAVORITE_MAX_ICON_NUM = 12;

#define DESKTOP_DIR "/usr/share/applications/"
QString TERMINAL_DESKTOP = QStringLiteral("org.kde.konsole.desktop");

ListModelManager::ListModelManager(HomeScreen *parent)
    : QObject(parent),
      m_homeScreen(parent),
      runAppActive(true)
{
    qRegisterMetaType<QAbstractListModel* >();
    qRegisterMetaType<KWayland::Client::PlasmaWindow* >();

    QDBusConnection connection = QDBusConnection::sessionBus();
    if(!connection.registerService("org.dbus.jingos.launcher")) {
        qDebug() << "org.dbus.jingos.launcher dbus error:" << connection.lastError().message();
    }

    if (!connection.registerObject("/org/jingos/launcher", this, QDBusConnection::ExportAllSlots)) {
        qDebug() << "org.dbus.jingos.launcher dbus error:" << connection.lastError().message();
    }

    placeholderitem = nullptr;
    
    loadPositions();
    replaceIconPosition();

    m_dirLister = new KDirLister(this);
    connect(m_dirLister, &KCoreDirLister::started, this, &ListModelManager::onStarted);
    connect(m_dirLister, &KCoreDirLister::itemsAdded, this, &ListModelManager::onItemsAdded);
    connect(m_dirLister, &KCoreDirLister::itemsDeleted, this, &ListModelManager::onItemsDeleted);

    connect(m_dirLister, &KCoreDirLister::itemsFilteredByMime, this, &ListModelManager::onItemsFilteredByMime);
    connect(m_dirLister, &KCoreDirLister::refreshItems, this, &ListModelManager::onRefreshItems);
    connect(m_dirLister, &KCoreDirLister::infoMessage, this, &ListModelManager::onInfoMessage);
    connect(m_dirLister, &KCoreDirLister::percent, this, &ListModelManager::onPercent);

    connect(m_dirLister, &KCoreDirLister::totalSize, this, &ListModelManager::onTotalSize);
    connect(m_dirLister, &KCoreDirLister::processedSize, this, &ListModelManager::onProcessedSize);
    connect(m_dirLister, &KCoreDirLister::speed, this, &ListModelManager::onSpeed);

    m_dirLister->openUrl(resolve(DESKTOP_DIR));
    m_dirLister->setAutoUpdate(true);
    m_dirLister->started(resolve(DESKTOP_DIR));
    
    // loadApplications();
    initWayland();

    // connect(KSycoca::self(), qOverload<const QStringList &>(&KSycoca::databaseChanged),
    //         this, &ListModelManager::sycocaDbChanged);
}

ListModelManager::~ListModelManager() = default;

void ListModelManager::sycocaDbChanged(const QStringList &changes)
{
    if (!changes.contains(QStringLiteral("apps")) && !changes.contains(QStringLiteral("xdgdata-apps"))) {
        return;
    }

    // loadApplications();
}

bool appNameLessThan(const ApplicationData &a1, const ApplicationData &a2)
{
    return a1.name.toLower() < a2.name.toLower();
}

void ListModelManager::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        return;
    }

    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);

    if (!connection) {
        return;
    }
    auto *registry = new Registry(this);
    registry->create(connection);
    connect(registry, &Registry::plasmaWindowManagementAnnounced, this,
            [this, registry] (quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
        qRegisterMetaType<QVector<int> >("QVector<int>");

        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated,
                this, [this] (KWayland::Client::PlasmaWindow *window) {
            if (window->appId() == QStringLiteral("org.kde.plasmashell")) {
                return;
            }

            for(int i = 0; i < applicationModelMap.keys().size(); i++) {
                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

                if(listModel == nullptr)
                    break;

                for(int i = 0; i < listModel->size(); i++) {
                    if (listModel->at(i) != nullptr && ((listModel->at(i)->storageId() == window->appId() + QStringLiteral(".desktop")) 
                        || window->pid() == listModel->at(i)->appPid())) {
                        listModel->at(i)->addWindow(window);
                        connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, window] () {

                            for(int i = 0; i < applicationModelMap.keys().size(); i++) {
                                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

                                if(listModel == nullptr)
                                    break;

                                for(int i = 0; i < listModel->size(); i++) {
                                    if (listModel->at(i) !=nullptr && (listModel->at(i)->storageId() == window->appId() + QStringLiteral(".desktop") 
                                        || window->pid() == listModel->at(i)->appPid())) {
                                        listModel->at(i)->removeWindow(window);
                                        break;
                                    }
                                }
                            }
                        });
                        break;
                    }
                }
            }
        });
    });

    registry->setup();
    connection->roundtrip();
}

void ListModelManager::loadApplications()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    // This is only temporary to get a clue what those apps' desktop files are called
    // I'll remove it once I've done a blacklist
    QStringList bl;
    QStringList pb3;
    QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    KServiceGroup::Ptr group = KServiceGroup::root();
    if (!group || !group->isValid()) return;
    KServiceGroup::List subGroupList = group->entries(true);

    QMap<int, ApplicationData> orderedList;
    QList<ApplicationData> unorderedList;
    QSet<QString> foundFavorites;

    // Iterate over all entries in the group
    while (!subGroupList.isEmpty()) {

        KSycocaEntry::Ptr groupEntry = subGroupList.first();
        subGroupList.pop_front();

        if (groupEntry->isType(KST_KServiceGroup)) {
            KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(groupEntry.data()));

            if (!serviceGroup->noDisplay()) {
                KServiceGroup::List entryGroupList = serviceGroup->entries(true);

                for(KServiceGroup::List::ConstIterator it = entryGroupList.constBegin();  it != entryGroupList.constEnd(); it++) {
                    KSycocaEntry::Ptr entry = (*it);

                    if (entry->isType(KST_KServiceGroup)) {
                        KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(entry.data()));
                        subGroupList << serviceGroup;

                    } else if (entry->property(QStringLiteral("Exec")).isValid()) {
                        KService::Ptr service(static_cast<KService *>(entry.data()));
                        if (service->isApplication() &&
                                !blacklist.contains(service->desktopEntryName()) &&
                                service->showOnCurrentPlatform() &&
                                !service->property(QStringLiteral("Terminal"), QVariant::Bool).toBool()) {

                            if (service->property(QStringLiteral("PanelBehavor"), QVariant::Int).toInt() == 3) {
                                pb3 << service->desktopEntryName();
                            }

                            if(service->storageId().isEmpty())
                                continue;

                            // bl << service->desktopEntryName();
                            
                            QString execPath = service->exec();
                            if (execPath.contains(" ")) {
                                QStringList values = execPath.split(" ");
                                if (values.size() >= 2) {
                                    execPath = values.at(values.size() - 2);
                                } else {
                                    execPath = values.at(values.size() - 1);
                                }
                            }
                            int initFlag = false;
                            for(int i = 0; i < applicationModelMap.keys().size(); i ++) {

                                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

                                if(listModel == nullptr)
                                    continue; 
                                
                                for(int i = 0; i < listModel->size(); i++) {
                                    if(listModel->at(i)->type() != LauncherItem::None)
                                        continue; 

                                    if(listModel->at(i)->storageId() == service->storageId()) {
                                        listModel->at(i)->setName(service->name());
                                        listModel->at(i)->setIcon(service->icon());
                                        listModel->at(i)->setEntryPath(service->exec());
                                        listModel->at(i)->setStartupNotify(service->property(QStringLiteral("StartupNotify")).toBool());
                                        listModel->at(i)->setType(LauncherItem::App);
                                        listModel->at(i)->setExecName(execPath.split("/").last());

                                        initFlag = true;
                                        break;
                                    }
                                }
                                if(initFlag)
                                    break;
                            }

                            if(showIconsMap.contains(service->storageId())) {
                                continue;
                            }
 
                            LauncherItem* data = new LauncherItem(this);
                            data->setName(service->name());
                            data->setIcon(service->icon());
                            data->setStorageId(service->storageId());
                            data->setEntryPath(service->exec());
                            data->setStartupNotify(service->property(QStringLiteral("StartupNotify")).toBool());
                            data->setType(LauncherItem::App);
                            data->setLocation(Desktop);
                            data->setExecName(execPath.split("/").last());

                            if(applicationModelMap.keys().size() == 0) {
                                BaseModel<LauncherItem*> *firstPageModel = new BaseModel<LauncherItem*>;
                                applicationModelMap[0] = firstPageModel;
                            }

                            int mapSize = applicationModelMap.keys().size();

                            for(int i = 0; i < applicationModelMap.keys().size(); i ++) {
                                if(applicationModelMap.keys().at(i) == -1)
                                    continue;

                                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

                                if(listModel == nullptr)
                                    continue; 
                                
                                if(listModel->size() < DESKTOP_MAX_ICON_NUM) {
                                    data->setPageIndex(i);
                                    data->setItemIndex(listModel->size());
                                    showIconsMap[data->storageId()] = i;
                                    listModel->append(data);
                                    writePositions(data->storageId(), data->pageIndex(), data->itemIndex());
                                    break;
                                } else {
                                    if(i == applicationModelMap.keys().size() -1) {
                                        BaseModel<LauncherItem*> *m_applicationModel = new BaseModel<LauncherItem*>;
                                        applicationModelMap[mapSize] = m_applicationModel;
                                        data->setPageIndex(mapSize);
                                        data->setItemIndex(applicationModelMap[mapSize]->size());
                                        showIconsMap[data->storageId()] = mapSize;
                                        applicationModelMap[mapSize]->append(data);
                                        writePositions(data->storageId(), data->pageIndex(), data->itemIndex());
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    panelBehavorList << pb3 << QStringLiteral("org.kde.plasmashell");

    blgroup.writeEntry("belowPanel", pb3);
    cfg->sync();

    emit countChanged();

    QList<int> model = applicationModelMap.keys();
    for(int i = 0; i < model.size(); i++) {
        if(model.at(i) == -1)
            continue;
        BaseModel<LauncherItem*>* listModel =  applicationModelMap[model.at(i)];
        setLauncherPageModel(listModel);
    }
}

bool ListModelManager::checkFirstPageApp(const QString &name)
{
    QString tmpName = name.toLower();
    if(tmpName.contains("wps") || tmpName.contains("browser")||tmpName.contains("media") || 
        tmpName.contains("photo") || tmpName.contains("clock") || tmpName.contains("voice") || 
        tmpName.contains("calendar") || tmpName.contains("calculator")) {
        return true;
    } else {
        return false;
    }
}

bool ListModelManager::checkFavoriteApp(const QString &name)
{
    QString tmpName = name.toLower();

    if(tmpName.contains("settings") || tmpName.contains("konsole") || tmpName.contains("discover")) {
        return true;
    } else {
        return false;
    }
}

void ListModelManager::moveRow(const QModelIndex& /* sourceParent */, int sourceRow, const QModelIndex& /* destinationParent */, int destinationChild)
{
    moveItem(sourceRow, destinationChild);
}

void ListModelManager::moveItem(int from, int to, int page)
{
    if(applicationModelMap.contains(page)) {
        if(applicationModelMap[page] != nullptr && applicationModelMap[page]->size() > to) {
            applicationModelMap[page]->move(from, to);
        }
    }
}

void ListModelManager::movePlaceholderItem(int to)
{
    if(placeholderitem == nullptr) {
        return;
    }
    if(applicationModelMap.contains(placeholderitem->pageIndex()) && applicationModelMap[placeholderitem->pageIndex()]) {
        applicationModelMap[placeholderitem->pageIndex()]->move(placeholderitem->itemIndex(), to);
    }
}

void ListModelManager::runApplication(const QString &storageId, KWayland::Client::PlasmaWindow *window)
{
    if(!runAppActive)
        return;
    runAppActive = false;
    QTimer::singleShot(800, this, SLOT(updateRunAppState()));

    if (storageId.isEmpty()) {
        return;
    }

    if(window != nullptr) {
        window->requestActivate();
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);
    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(service);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();

    connect(job, &KIO::ApplicationLauncherJob::finished, this, [this, job, storageId]() {
        for(int i = 0; i < applicationModelMap.keys().size(); i++) {
            BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

            if(listModel == nullptr)
                break;

            for(int i = 0; i < listModel->size(); i++) {

                if (listModel->at(i)->storageId() == storageId) {
                    listModel->at(i)->setAppPid(job->pid());
                    break;
                }
            }
        }
    });
}

void ListModelManager::updateRunAppState()
{
    runAppActive = true;
}

int ListModelManager::maxFavoriteCount() const
{
    return m_maxFavoriteCount;
}

void ListModelManager::setMaxFavoriteCount(int count)
{
    if (m_maxFavoriteCount == count) {
        return;
    }

    if (m_maxFavoriteCount > count) {
        while (m_favorites.size() > count && m_favorites.count() > 0) {
            m_favorites.pop_back();
        }
        emit favoriteCountChanged();

        int i = 0;
        for (auto &app : m_applicationList) {
            if (i >= count && app.location == Favorites) {
                app.location = Grid;
                //emit dataChanged(index(i, 0), index(i, 0));
            }
            ++i;
        }
    }

    m_maxFavoriteCount = count;
    m_homeScreen->config().writeEntry("MaxFavoriteCount", m_maxFavoriteCount);

    emit maxFavoriteCountChanged();
}

QAbstractListModel* ListModelManager::launcherPageModel() const
{
    return const_cast<BaseModel<BaseModel<LauncherItem*>*> *>(&m_launcherPageModel);
}

void ListModelManager::setLauncherPageModel(BaseModel<LauncherItem*>* page)
{
    if(m_launcherPageModel.contains(page)) {
        return;
    }
    m_launcherPageModel.append(page);
    emit launcherPageModelChanged();
}

void ListModelManager::removeLauncherPageModel(BaseModel<LauncherItem*>* page)
{
    if(m_launcherPageModel.contains(page)) {
        m_launcherPageModel.removeOne(page);
        emit launcherPageModelChanged();
    }
}

void ListModelManager::addLauncherPage(int page)
{
    if(!applicationModelMap.contains(page)) {
        BaseModel<LauncherItem*> *pageModel = new BaseModel<LauncherItem*>;
        applicationModelMap[page] = pageModel;

        setLauncherPageModel(pageModel);
    }
}

QAbstractListModel *ListModelManager::getMdoelFromPage(int page)
{
    if(applicationModelMap.contains(page)) {
        if(applicationModelMap[page] != nullptr) {
            return  applicationModelMap[page];
        }
    }

    return new BaseModel<QAbstractListModel*>;
}

QAbstractListModel *ListModelManager::getFavoriteAppMdoel()
{
    if(applicationModelMap.contains(-1)) {
        if(applicationModelMap[-1] != nullptr)
            return applicationModelMap[-1];
    }
    BaseModel<LauncherItem*> *pageModel = new BaseModel<LauncherItem*>;
    applicationModelMap[-1] = pageModel;
    return applicationModelMap[-1];
}

void ListModelManager::dragItemToModel(LauncherItem *item, int fromModel, int toModel)
{
    if(applicationModelMap.contains(fromModel) && applicationModelMap[fromModel])
        applicationModelMap[fromModel]->removeOne(item);

    if(applicationModelMap.contains(toModel) && applicationModelMap[toModel])
        applicationModelMap[toModel]->append(item);
}

void ListModelManager::addPlaceholderItem(int page)
{
    if(applicationModelMap.contains(page) && applicationModelMap[page] ) {
        int maxnum = page == -1 ? FAVORITE_MAX_ICON_NUM : DESKTOP_MAX_ICON_NUM;
        if(applicationModelMap[page]->size() >= maxnum) {
            removePlaceholderItem();
            return;
        }
    }

    if(placeholderitem) {
        if(placeholderitem->pageIndex() != page)
            removePlaceholderItem();
    }

    if(!applicationModelMap.contains(page) || !applicationModelMap[page])
        return;

    if(placeholderitem == nullptr) {
        placeholderitem = new LauncherItem(this);
    
        placeholderitem->setType(LauncherItem::None);
        placeholderitem->setPageIndex(page);
        if(page == -1) {
            placeholderitem->setLocation(Favorites);
        } else {
            placeholderitem->setLocation(Desktop);
        }
        applicationModelMap[page]->append(placeholderitem);
    }
}

void ListModelManager::removePlaceholderItem()
{
    if(placeholderitem == nullptr)
        return;

    if(applicationModelMap.contains(placeholderitem->pageIndex()) && applicationModelMap[placeholderitem->pageIndex()]) {
        applicationModelMap[placeholderitem->pageIndex()]->removeOne(placeholderitem);
    }
    placeholderitem->initData();
    placeholderitem->deleteLater();
    placeholderitem = nullptr;
}

void ListModelManager::replacePlaceholderItemToAppItem(LauncherItem *item)
{
    if(item == nullptr) {
        return;
    }
    if(placeholderitem == nullptr)
        return;

    LauncherItem *appItem = new LauncherItem(this);
    appItem->setItemData(item);
    appItem->setItemIndex(placeholderitem->itemIndex());
    appItem->setPageIndex(placeholderitem->pageIndex());
    appItem->setLocation(placeholderitem->location());

    if(!applicationModelMap.contains(appItem->pageIndex())) {
        BaseModel<LauncherItem*> *pageModel = new BaseModel<LauncherItem*>;

        applicationModelMap[appItem->pageIndex()] = pageModel;
        applicationModelMap[appItem->pageIndex()]->insert(appItem->itemIndex(), appItem);
    } else {
        if(applicationModelMap[appItem->pageIndex()])
            applicationModelMap[appItem->pageIndex()]->insert(appItem->itemIndex(), appItem);
    }
    if(placeholderitem->pageIndex() != appItem->pageIndex())
        refreshLocation(placeholderitem->pageIndex());
    removePlaceholderItem();
    writePositions(appItem->storageId(), appItem->pageIndex(), appItem->itemIndex());
    removeLauncherItem(item);
}

void ListModelManager::removeLauncherItem(LauncherItem* item)
{
    if(item == nullptr) {
        return;
    }

    if(applicationModelMap.contains(item->pageIndex()) && applicationModelMap[item->pageIndex()]) {
        removePosition(item->storageId(), item->pageIndex());
        applicationModelMap[item->pageIndex()]->removeOne(item);
        showIconsMap.remove(item->storageId());
        item->initData();
        item->deleteLater();
        item = nullptr;
        refreshPageModel();
    }
}

void ListModelManager::refreshPageModel()
{
    reloadPageModel(0);

    QList<int> keysList = applicationModelMap.keys();

    for(int i = 0; i < keysList.size(); i++) {
        if(keysList.at(i) == -1)
            continue;

        if(applicationModelMap[keysList.at(i)]->size() == 0) {
            if(applicationModelMap[keysList.at(i)] != nullptr) {
                removeLauncherPageModel(applicationModelMap[keysList.at(i)]);
                applicationModelMap[keysList.at(i)]->deleteLater();
                applicationModelMap[keysList.at(i)] = nullptr;
            }
            applicationModelMap.remove(keysList.at(i)); 
        }
    }

    refreshAllLocation();
}

void ListModelManager::refreshAllLocation()
{
    for(int index = 0; index < m_launcherPageModel.size(); index++) {
        BaseModel<LauncherItem*>* listModel =  m_launcherPageModel.at(index);

        if(listModel == nullptr)
            return;

        for(int i = 0; i < listModel->size(); i++) {
            listModel->at(i)->setItemIndex(i);
            writePositions(listModel->at(i)->storageId(), index, i);
        }
    }
}

void ListModelManager::reloadPageModel(int currentIndex)
{
    if(applicationModelMap.contains(currentIndex) && applicationModelMap.contains(currentIndex + 1)) {
        if(applicationModelMap[currentIndex]->size() == 0 && applicationModelMap[currentIndex + 1]->size() != 0) {

            BaseModel<LauncherItem*>* listModel = applicationModelMap[currentIndex];

            applicationModelMap[currentIndex] = applicationModelMap[currentIndex + 1];
            for(int i = 0; i < applicationModelMap[currentIndex]->size(); i++) {
                applicationModelMap[currentIndex]->at(i)->setPageIndex(currentIndex);
                applicationModelMap[currentIndex]->at(i)->setLocation(currentIndex == -1 ? Favorites : Desktop);
            }

            applicationModelMap[currentIndex + 1] = listModel;
            for(int i = 0; i < applicationModelMap[currentIndex + 1]->size(); i++) {
                applicationModelMap[currentIndex + 1]->at(i)->setPageIndex(currentIndex + 1);
                applicationModelMap[currentIndex + 1]->at(i)->setLocation((currentIndex + 1) == -1 ? Favorites : Desktop);
            }
        }

        reloadPageModel(currentIndex + 1);
    }
}

int ListModelManager::getPlaceholderPosition()
{
    if(placeholderitem == nullptr)
        return -10000;

    return placeholderitem->pageIndex();
}

bool ListModelManager::getPanelBehavorState(QString desktop)
{
    if(desktop.endsWith(".desktop")) {
        return panelBehavorList.contains(desktop.remove(".desktop"));
    }
    return panelBehavorList.contains(desktop);
}

void ListModelManager::writePositions(const QString &storageId, const int &page, const int &index)
{    
    QString type = page == -1 ? "Favorites" : "Desktop";

    QSettings settings("JingLauncher", "Position");

    settings.beginGroup(type);
    settings.setValue(storageId, QString::number(page) + "," + QString::number(index));
    settings.endGroup();
}

void ListModelManager::loadPositions()
{
    QSettings settings("JingLauncher", "Position");

    settings.beginGroup("Desktop");
    QStringList desktopKeys = settings.allKeys();
    for (int i = 0 ; i < desktopKeys.size(); i++ ) {
        QStringList positionlist = settings.value(desktopKeys.at(i)).toString().split(',');

        int page = positionlist.at(0).toInt();
        int itemIndex = positionlist.at(1).toInt();

        LauncherItem *appItem = new LauncherItem(this);
        appItem->setStorageId(desktopKeys.at(i));
        appItem->setItemIndex(itemIndex);
        appItem->setPageIndex(page);
        appItem->setLocation(page == -1 ? Favorites : Desktop);
        appItem->setType(LauncherItem::None);

        if(applicationModelMap.contains(page)) {
            applicationModelMap[page]->append(appItem);
        } else {
            BaseModel<LauncherItem*> *pageModel = new BaseModel<LauncherItem*>;
            applicationModelMap[page] = pageModel;
            pageModel->append(appItem);
        }
        showIconsMap[appItem->storageId()] = 0;
    }
    settings.endGroup();

    settings.beginGroup("Favorites");
    QStringList favoritesKeys = settings.allKeys();
    for (int i = 0 ; i < favoritesKeys.size(); i++ ) {
        QStringList positionlist = settings.value(favoritesKeys.at(i)).toString().split(',');

        int page = positionlist.at(0).toInt();
        int itemIndex = positionlist.at(1).toInt();

        LauncherItem *appItem = new LauncherItem(this);
        appItem->setStorageId(favoritesKeys.at(i));
        appItem->setItemIndex(itemIndex);
        appItem->setPageIndex(page);
        appItem->setLocation(page == -1 ? Favorites : Desktop);
        appItem->setType(LauncherItem::None);

        if(applicationModelMap.contains(page)) {
            applicationModelMap[page]->append(appItem);
        } else {
            BaseModel<LauncherItem*> *pageModel = new BaseModel<LauncherItem*>;
            applicationModelMap[page] = pageModel;
            pageModel->append(appItem);
        }
        showIconsMap[appItem->storageId()] = 0;
    }
    settings.endGroup();
}

void ListModelManager::removePosition(const QString &storageId, const int &page)
{
    QString type = page == -1 ? "Favorites" : "Desktop";

    QSettings settings("JingLauncher", "Position");

    settings.beginGroup(type);
    settings.remove(storageId);
    settings.endGroup();
}

void ListModelManager::refreshLocation(const int &page)
{
    if(!applicationModelMap.contains(page))
        return;

    BaseModel<LauncherItem*>* listModel =  applicationModelMap[page];

    if(listModel == nullptr)
        return;

    for(int i = 0; i < listModel->size(); i++) {
        listModel->at(i)->setItemIndex(i);
        writePositions(listModel->at(i)->storageId(), page, i);
    }

    emit launcherPageModelChanged();
}

void ListModelManager::replaceIconPosition()
{
    for(int i = 0; i < applicationModelMap.keys().size(); i ++) {

        BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

        if(listModel == nullptr)
            continue; 
                                
        for(int j = 0; j < listModel->size() - 1; j++) {
            swapPosition(listModel, j);
        }
    }
}

void ListModelManager::swapPosition(BaseModel<LauncherItem*>* listModel, int index)
{
    if(listModel->at(index)->itemIndex() > listModel->at(index + 1)->itemIndex()) {
        listModel->swap(index, index+1);
    }
    if(index - 1 < 0)
        return;
    else {
        swapPosition(listModel, index - 1);
    }
}

int ListModelManager::getDesktopMaxIconNum()
{
    return DESKTOP_MAX_ICON_NUM;
}

int ListModelManager::getFavoriteMaxIconNum()
{
    return FAVORITE_MAX_ICON_NUM;
}

void ListModelManager::onStarted(const QUrl &_url)
{
    Q_UNUSED(_url);
    qDebug() << __FILE__ << __FUNCTION__ << " url:"  << _url;
}

void ListModelManager::onCompleted()
{
    qDebug() << __FILE__ << __FUNCTION__;
}

void ListModelManager::onCompletedUrl(const QUrl &_url)
{
    Q_UNUSED(_url);
    qDebug() << __FILE__ << __FUNCTION__ << " url:"  << _url;
}

void ListModelManager::onCanceled()
{
    qDebug() << __FILE__ << __FUNCTION__;
}

void ListModelManager::onCanceled(const QUrl &_url)
{
    Q_UNUSED(_url);
    qDebug() << __FILE__ << __FUNCTION__ << " url:"  << _url;
}

void ListModelManager::onRedirection(const QUrl &_url)
{
    Q_UNUSED(_url);
    qDebug() << __FILE__ << __FUNCTION__ << " url:"  << _url;
}

void ListModelManager::onRedirection(const QUrl &oldUrl, const QUrl &newUrl)
{
    Q_UNUSED(oldUrl);
    Q_UNUSED(newUrl);
    qDebug() << __FILE__ << __FUNCTION__ << " oldUrl:"  << oldUrl << "   newUrl: " << newUrl;
}

void ListModelManager::onClear()
{
    qDebug() << __FILE__ << __FUNCTION__;
}

void ListModelManager::onClear(const QUrl &_url)
{
    Q_UNUSED(_url);
    qDebug() << __FILE__ << __FUNCTION__ << " url:"  << _url;
}

void ListModelManager::onNewItems(const KFileItemList &fileItems)
{    
    qDebug() <<  __FILE__ << __FUNCTION__ <<  "-- items:  " << fileItems.size() ;

    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    // This is only temporary to get a clue what those apps' desktop files are called
    // I'll remove it once I've done a blacklist
    QStringList bl;
    QStringList pb3;
    QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    KFileItem fileItem;
    foreach (fileItem, fileItems) {
        if(!fileItem.isDesktopFile()) {
            continue;
        }
        const KDesktopFile file(fileItem.url().path());
        
        if (file.noDisplay()) {
            continue;
        }
        if (!file.tryExec()) {
            continue;
        }

        if (file.hasApplicationType() &&
                !blacklist.contains(fileItem.name()) &&
                file.desktopGroup().readEntry("Terminal", "false") == "false") {
            
            if (file.desktopGroup().readEntry("PanelBehavor").toInt() == 3) {
                if(fileItem.name().endsWith(".desktop")) {
                    pb3 << fileItem.name().remove(".desktop");
                } else {
                    pb3 << fileItem.name();
                }
            }
            
            // bl << file->name();
            
            QString execPath = file.desktopGroup().readEntry("Exec");
            if (execPath.contains(" ")) {
                QStringList values = execPath.split(" ");
                if (values.size() >= 2) {
                    execPath = values.at(values.size() - 2);
                } else {
                    execPath = values.at(values.size() - 1);
                }
            }
            int initFlag = false;

            for(int i = 0; i < applicationModelMap.keys().size(); i ++) {
                
                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

                if(listModel == nullptr)
                    continue; 

                for(int j = 0; j < listModel->size(); j++) {

                    if(listModel->at(j)->type() != LauncherItem::None)
                        continue; 

                    if(listModel->at(j)->storageId() == fileItem.name()) {
                        listModel->at(j)->setName(file.readName());
                        listModel->at(j)->setIcon(file.readIcon());
                        listModel->at(j)->setEntryPath(file.desktopGroup().readEntry("Exec"));
                        listModel->at(j)->setStartupNotify(file.desktopGroup().readEntry("StartupNotify") == "true" ? true: false);
                        listModel->at(j)->setType(LauncherItem::App);
                        listModel->at(j)->setExecName(execPath.split("/").last());
                        listModel->at(j)->setIsSystemApp((file.desktopGroup().readEntry("PanelBehavor").toInt() == 3 || fileItem.name() == TERMINAL_DESKTOP));
                        initFlag = true;
                        break;
                    }
                }
                if(initFlag)
                    break;
            }
            
            if(showIconsMap.contains(fileItem.name())) {
                continue;
            }

            LauncherItem* data = new LauncherItem(this);
            data->setName(file.readName());
            data->setIcon(file.readIcon());
            data->setStorageId(fileItem.name());
            data->setEntryPath(file.desktopGroup().readEntry("Exec"));
            data->setStartupNotify(file.desktopGroup().readEntry("StartupNotify") == "true" ? true: false);
            data->setType(LauncherItem::App);
            data->setLocation(Desktop);
            data->setExecName(execPath.split("/").last());
            data->setIsSystemApp((file.desktopGroup().readEntry("PanelBehavor").toInt() == 3 || fileItem.name() == TERMINAL_DESKTOP));

            if(applicationModelMap.keys().size() == 1 && applicationModelMap.contains(-1)) {
                BaseModel<LauncherItem*> *firstPageModel = new BaseModel<LauncherItem*>;
                applicationModelMap[0] = firstPageModel;
            }

            int mapSize = applicationModelMap.keys().size();

            for(int i = 0; i < applicationModelMap.keys().size(); i ++) {

                if(applicationModelMap.keys().at(i) == -1)
                    continue;

                BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];
                
                if(listModel == nullptr)
                    continue; 

                if(listModel->size() < DESKTOP_MAX_ICON_NUM) {
                    data->setPageIndex(applicationModelMap.keys().at(i));
                    data->setItemIndex(listModel->size());
                    showIconsMap[data->storageId()] = applicationModelMap.keys().at(i);
                    listModel->append(data);
                    writePositions(data->storageId(), data->pageIndex(), data->itemIndex());
                    break;
                } else {
                    if(i == applicationModelMap.keys().size() -1) {
                        int currentPageIndex = mapSize - 1;
                        BaseModel<LauncherItem*> *m_applicationModel = new BaseModel<LauncherItem*>;
                        applicationModelMap[currentPageIndex] = m_applicationModel;
                        data->setPageIndex(currentPageIndex);
                        data->setItemIndex(applicationModelMap[currentPageIndex]->size());
                        showIconsMap[data->storageId()] = currentPageIndex;
                        m_applicationModel->append(data);
                        writePositions(data->storageId(), data->pageIndex(), data->itemIndex());
                        break;
                    }
                }
            }
        }
    }

    panelBehavorList << pb3 << QStringLiteral("org.kde.plasmashell");

    blgroup.writeEntry("belowPanel", pb3);
    cfg->sync();

    emit countChanged();

    QList<int> model = applicationModelMap.keys();
    for(int i = 0; i < model.size(); i++) {
        if(model.at(i) == -1)
            continue;
        BaseModel<LauncherItem*>* listModel =  applicationModelMap[model.at(i)];
        setLauncherPageModel(listModel);
    }
}

void ListModelManager::onItemsAdded(const QUrl &directoryUrl, const KFileItemList &items)
{
    Q_UNUSED(directoryUrl);

    qDebug() <<  __FILE__ << __FUNCTION__ << "-- directoryUrl:  " << directoryUrl << "-- items : " << items.size();
    onNewItems(items);
}

void ListModelManager::onItemsFilteredByMime(const KFileItemList &items)
{
    Q_UNUSED(items);
    qDebug() << __FILE__ << __FUNCTION__ << "- items:  " << items.size() ;
}

void ListModelManager::onItemsDeleted(const KFileItemList &items)
{
    qDebug() << __FILE__ << __FUNCTION__ << " items:"  << items.size();

    KFileItem item;

    foreach (item, items) {
        if(item.isDesktopFile()) {
            const KDesktopFile file(item.url().path());
            
            QList<int> keysList = applicationModelMap.keys();

            for(int i = 0; i < keysList.size(); i++) {
                BaseModel<LauncherItem*>* listModel =  applicationModelMap[keysList.at(i)];

                if(listModel == nullptr)
                    return;

                for(int i = 0; i < listModel->size(); i++) {
                    if(listModel->at(i)->storageId() == item.name()) {
                        removeLauncherItem(listModel->at(i));
                        return;
                    }
                }
            }
        }
    }
}

void ListModelManager::onRefreshItems(const QList<QPair<KFileItem, KFileItem> > &items)
{
    Q_UNUSED(items);
    qDebug() << __FILE__ << __FUNCTION__ << " items:"  << items.size();
}

void ListModelManager::onInfoMessage(const QString &msg)
{
    Q_UNUSED(msg);
    qDebug() << __FILE__ << __FUNCTION__ << " msg:"  << msg;
}

void ListModelManager::onPercent(int percent)
{
    Q_UNUSED(percent);
    qDebug() << __FILE__ << __FUNCTION__ << " percent:"  << percent;
}

void ListModelManager::onTotalSize(KIO::filesize_t size)
{
    Q_UNUSED(size);
    qDebug() << __FILE__ << __FUNCTION__ << " size:"  << size;
}

void ListModelManager::onProcessedSize(KIO::filesize_t size)
{
    Q_UNUSED(size);
    qDebug() << __FILE__ << __FUNCTION__ << " size:"  << size;
}

void ListModelManager::onSpeed(int bytes_per_second)
{
    Q_UNUSED(bytes_per_second);
    qDebug() << __FILE__ << __FUNCTION__ << " bytes_per_second:"  << bytes_per_second;
}

QUrl ListModelManager::resolve(const QString& url)
{
    QUrl resolvedUrl;

    if (url.startsWith(QLatin1Char('~'))) {
        resolvedUrl = QUrl::fromLocalFile(KShell::tildeExpand(url));
    } else {
        resolvedUrl = QUrl::fromUserInput(url);
    }

    return resolvedUrl;
}

void ListModelManager::openWithApp(const QString &exec, const QStringList &urls)
{
    if(!runAppActive)
        return;
        
    runAppActive = false;
    QTimer::singleShot(800, this, SLOT(updateRunAppState()));

    if (exec.isEmpty()) {
        return;
    }

    QString mStorageId;

    for(int i = 0; i < applicationModelMap.keys().size(); i ++) {

        BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

        if(listModel == nullptr)
            continue; 
                                
        for(int j = 0; j < listModel->size() - 1; j++) {
            if(exec.contains(listModel->at(j)->storageId())) {
                mStorageId = listModel->at(j)->storageId();
                if(listModel->at(j)->window() != nullptr) {
                    listModel->at(j)->window()->requestActivate();
                    return;
                }
            }
        }
    }

    KService service(exec);
    KService::Ptr servicePtr(new KService(service)); // clone
    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(servicePtr);

    connect(job, &KIO::ApplicationLauncherJob::finished, this, [this, job, mStorageId]() {
        for(int i = 0; i < applicationModelMap.keys().size(); i++) {
            BaseModel<LauncherItem*>* listModel =  applicationModelMap[applicationModelMap.keys().at(i)];

            if(listModel == nullptr)
                break;

            for(int i = 0; i < listModel->size(); i++) {

                if (listModel->at(i)->storageId() == mStorageId) {
                    listModel->at(i)->setAppPid(job->pid());
                    break;
                }
            }
        }
    });
    
    job->setUrls(QUrl::fromStringList(urls));
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();
}


#include "moc_listmodelmanager.cpp"
