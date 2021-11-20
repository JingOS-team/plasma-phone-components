/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *   Copyright (C) 2018 Bhushan Shah <bshah@kde.org>                       *
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>
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

#include "phonepanel.h"

#include <qplatformdefs.h>
#include <fcntl.h>
#include <unistd.h>

#include <KLocalizedString>
#include <KConfigGroup>
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KServiceGroup>

#include <QFuture>

#include <QDateTime>
#include <QDBusPendingReply>
#include <QFile>
#include <QDebug>
#include <QStandardPaths>
#include <QProcess>
#include <QtConcurrent/QtConcurrent>
#include <QScreen>
#include <QQmlEngine> 
#include <QtQml>
#include <QDebug>
#include <QDBusConnection>
#include <KNotification>

#include <solid/devicenotifier.h>
#include <solid/device.h>
#include <solid/deviceinterface.h>
#include <solid/battery.h>
#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/plasmawindowmodel.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

#include "mediamanager.h"
#include "hotkeysmanager.h"

#define FORMAT24H "HH:mm:ss"

constexpr int SCREENSHOT_DELAY = 50;
static const QString s_kwinService = QStringLiteral("org.kde.KWin");
constexpr int ACTIVE_WINDOW_UPDATE_INVERVAL = 250;

PhonePanel::PhonePanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args),m_initWatcherFlag(true)
    , m_windowManagement(nullptr)
{
    qmlRegisterType<MediaManager>("org.kde.phone.jingos.mediamanager", 1, 0, "MediaManager");
    qmlRegisterType<HotkeysManager>("org.kde.phone.jingos.hotkeysmanager", 1, 0, "HotkeysManager");

    m_kscreenInterface = new org::kde::KScreen(QStringLiteral("org.kde.kded5"), QStringLiteral("/modules/kscreen"), QDBusConnection::sessionBus(), this);
    m_screenshotInterface = new org::kde::kwin::Screenshot(QStringLiteral("org.kde.KWin"), QStringLiteral("/Screenshot"), QDBusConnection::sessionBus(), this);
    
    m_localeConfig = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    m_localeConfigWatcher = KConfigWatcher::create(m_localeConfig);

    QDBusConnection::sessionBus().connect(QString(), QString("/org/kde/kcmshell_clock"),
                                          QString("org.kde.kcmshell_clock"), QString("clockUpdated"), this,
                                          SLOT(kcmClockUpdated()));

    QDBusConnection::sessionBus().connect(QString(), QString("/org/jingos/screenshot"),
                                          QString("org.jingos.screenshot"), QString("screenshot"), this, SLOT(takeScreenshot()));

    //添加闹钟dbus响应
    QDBusConnection::sessionBus().connect(QString(), QString("/jingos/alarm/statusbaricon"),
                                          QString("jingos.alarm.statusbaricon"), QString("getVisible"), this,
                                          SLOT(alarmVisibleChanged(bool)));

    
    // watch for changes to locale config, to update 12/24 hour time
    connect(m_localeConfigWatcher.data(), &KConfigWatcher::configChanged,
            this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        qWarning() << group.name();
        if (group.name() == "Locale") {
            // we have to reparse for new changes (from system settings)
            m_localeConfig->reparseConfiguration();
            Q_EMIT isSystem24HourFormatChanged();
        }
    });
    connect(&futureWatcher, SIGNAL(finished()), this, SLOT(handleFinished()));

    QList<Solid::Device> deviceList = Solid::Device::listFromType(Solid::DeviceInterface::StorageDrive);

    if(deviceList.count() > 1){
        m_udiskInsert=true;
    }

    connect(Solid::DeviceNotifier::instance(), &Solid::DeviceNotifier::deviceAdded,
            this,                              &PhonePanel::slotDeviceAdded);
    connect(Solid::DeviceNotifier::instance(), &Solid::DeviceNotifier::deviceRemoved,
            this,                              &PhonePanel::slotDeviceRemoved);

    //[liubangguo]Active window managment
    initWindowManagement();
}

PhonePanel::~PhonePanel() = default;

void PhonePanel::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    QProcess::startDetached(command);
}

void PhonePanel::initializeConfigData()
{
    KSharedConfig::Ptr volumeConfig = KSharedConfig::openConfig(QStringLiteral("statuspanel_default.ini"), KConfig::SimpleConfig);
    KConfigGroup defaultVolume = KConfigGroup(volumeConfig, "volume");

    int value = defaultVolume.readEntry("default",50);
    if(value == 50){
        defaultVolume.writeEntry("default",30000);
        emit setToDefaultVolume(30000);
    }
    volumeConfig->sync();
}

void PhonePanel::toggleTorch()
{
    if (!m_running) {
        gst_init(nullptr, nullptr);
        // create elements
        m_source = gst_element_factory_make("droidcamsrc", "source");
        m_sink = gst_element_factory_make("fakesink", "sink");
        m_pipeline = gst_pipeline_new("torch-pipeline");
        if (!m_pipeline || !m_source || !m_sink) {
            qDebug() << "Failed to turn on torch: failed to create elements";
            return;
        }
        gst_bin_add_many(GST_BIN(m_pipeline), m_source, m_sink, NULL);
        if (gst_element_link(m_source, m_sink) != TRUE) {
            qDebug() << "Failed to turn on torch: failed to link source and sink";
            g_object_unref(m_pipeline);
            return;
        }
        g_object_set(m_source, "mode", 2, NULL);
        g_object_set(m_source, "video-torch", TRUE, NULL);
        if (gst_element_set_state(m_pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
            qDebug() << "Failed to turn on torch: failed to start pipeline";
            g_object_unref(m_pipeline);
            return;
        }
        m_running = true;
    } else {
        gst_element_set_state(m_pipeline, GST_STATE_NULL);
        gst_object_unref(m_pipeline);
        m_running = false;
    }
}

bool PhonePanel::autoRotate()
{
    QDBusPendingReply<bool> reply = m_kscreenInterface->getAutoRotate();
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Getting auto rotate failed:" << reply.error().name() << reply.error().message();
        return false;
    } else {
        return reply.value();
    }
}

void PhonePanel::setAutoRotate(bool value)
{
    QDBusPendingReply<> reply = m_kscreenInterface->setAutoRotate(value);
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Setting auto rotate failed:" << reply.error().name() << reply.error().message();
    } else {
        emit autoRotateChanged(value);
    }
}


void PhonePanel::takeScreenshot()
{
    if (m_takingScreenShot) {
        return;
    }
    m_takingScreenShot = true;

    // wait ~50 ms to wait for rest of animations
    QTimer::singleShot(SCREENSHOT_DELAY,[=]() {

        // screenshot fullscreen currently doesn't work on all devices -> we need to use screenshot area
        // this won't work with multiple screens
        QSize screenSize = QGuiApplication::primaryScreen()->size();
        QDBusPendingReply<QString> reply = m_screenshotInterface->screenshotFullscreen(false);
        auto *watcher = new QDBusPendingCallWatcher(reply, this);

        connect(watcher, &QDBusPendingCallWatcher::finished, this, [=](QDBusPendingCallWatcher *watcher) {

            auto takeScreenShot =  [=]() {
                QDBusPendingReply<QString> reply = *watcher;

                if (reply.isError()) {
                    qWarning() << "Creating the screenshot failed:" << reply.error().name() << reply.error().message();
                    m_strScreenShot=i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file","Creating the screenshot failed");
                    handleFinished();
                } else {
                    QString filePath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
                    if (filePath.isEmpty()) {
                        qWarning() << "Couldn't find a writable location for the screenshot! The screenshot is in /tmp.";
                        m_strScreenShot=i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file","Couldn't find a writable location for the screenshot! The screenshot is in /tmp.");
                        handleFinished();
                        return;
                    }

                    QDir picturesDir(filePath);
                    if (!picturesDir.mkpath(QStringLiteral("Screenshots"))) {
                        qWarning() << "Couldn't create folder at"
                                << picturesDir.path() + QStringLiteral("/Screenshots")
                                << "to take screenshot.";
                        m_strScreenShot=i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file","Couldn't create folder at Screenshots");
                        handleFinished();
                        return;
                    }

                    filePath += QStringLiteral("/Screenshots/Screenshot_%1.jpg")
                            .arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss")));

                    const QString currentPath = reply.argumentAt<0>();
                    m_future=QtConcurrent::run(QThreadPool::globalInstance(), [=]() {
                        QFile screenshotFile(currentPath);
                        if (!screenshotFile.rename(filePath)) {
                            qWarning() << "Couldn't move screenshot into Pictures folder:"
                                    << screenshotFile.errorString();
                            m_strScreenShot=i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file","Couldn't move screenshot into Pictures folder");
                        }
                        m_strScreenShot=i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file","Screenshot saved to: %1",filePath);
                        qDebug() << "Successfully saved screenshot at" << filePath;
                    });
                    futureWatcher.setFuture(m_future);

                }
                watcher->deleteLater();

            };
            std::thread screenShotThread(takeScreenShot);
            screenShotThread.detach();
        });
    });
}

void PhonePanel::runApplication(const  QString& packageName)
{
    if (packageName.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(packageName);
    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(service);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();
}
void PhonePanel::handleFinished()
{
    if(!m_strScreenShot.isEmpty()){
        KNotification::event(KNotification::Notification,
                             i18ndc("plasma-phone-components","Notification caption that a screenshot got saved to file", "Screenshot"),
                             m_strScreenShot,
                             QStringLiteral("spectacle"));
        m_strScreenShot="";
    }
    m_takingScreenShot = false;
}

bool PhonePanel::isSystem24HourFormat()
{
    KConfigGroup localeSettings = KConfigGroup(m_localeConfig, "Locale");
    
    QString timeFormat = localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H));
    return timeFormat == QStringLiteral(FORMAT24H);
}

bool PhonePanel::udiskInserted()
{
    return m_udiskInsert;
}

bool PhonePanel::soundInserted()
{
    return m_soundInsert;
}


bool PhonePanel::isDarkColorScheme()
{

    KSharedConfig::Ptr m_colorSchemeConfig = KSharedConfig::openConfig(QStringLiteral("jingosThemeGlobals"), KConfig::SimpleConfig);
    KConfigGroup colorSettings = KConfigGroup(m_colorSchemeConfig, "JINGOS");

    QString colorScheme = colorSettings.readEntry("ColorScheme","jingosLight");
    return colorScheme == QStringLiteral("jingosDark");
}

void PhonePanel::slotDeviceAdded(QString message)
{
    if(message.contains("input") || message.contains("mouse")|| message.contains("net") || message.contains("keyboard"))
        return;

    if(message.contains("sound")){
        m_soundInsert = true;
        emit soundInsertChanged(true);
        return;
    }
    m_udiskInsert = true;
    Q_EMIT udiskInsertChanged(true);
}

void PhonePanel::slotDeviceRemoved(QString message)
{
    if(message.contains("input") || message.contains("mouse") || message.contains("net") || message.contains("keyboard"))
        return;
    if(message.contains("sound")){
        m_soundInsert = false;
        emit soundInsertChanged(false);
        return;
    }
    m_udiskInsert = false;
    Q_EMIT udiskInsertChanged(false);
}

void PhonePanel::kcmClockUpdated()
{
    m_localeConfig->reparseConfiguration();
    Q_EMIT isSystem24HourFormatChanged();
}

void PhonePanel::alarmVisibleChanged(bool visble)
{
    m_alarmVisible = visble;
    Q_EMIT alarmStatusChanged(visble);
}

bool PhonePanel::alarmVisible()
{
    return m_alarmVisible;
}

void PhonePanel::initWindowManagement()
{
    setHasConfigurationInterface(true);
    initWayland();
}

void PhonePanel::initWayland()
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
        connect(m_windowManagement, &PlasmaWindowManagement::showingDesktopChanged, this,
                [this] (bool showing) {
            if (showing == m_showingDesktop) {
                return;
            }
            m_showingDesktop = showing;
            emit showingDesktopChanged(m_showingDesktop);
        }
        );


        connect(m_windowManagement,&KWayland::Client::PlasmaWindowManagement::showingDesktopChanged,
                this,[this]() -> void {
                    m_allMinimized = m_windowManagement->isShowingDesktop();
                    emit allMinimizedChanged();
                });
    }
    );

    registry->setup();
    connection->roundtrip();
}



void PhonePanel::updateActiveWindow()
{
    if (!m_windowManagement || m_activeWindow == m_windowManagement->activeWindow()) {
        return;
    }
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &PhonePanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
                   this, &PhonePanel::forgetActiveWindow);
    }
    m_activeWindow = m_windowManagement->activeWindow();

    if (m_activeWindow) {
        setActiveWindowDesktopName(m_activeWindow->appId());
        connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &PhonePanel::hasCloseableActiveWindowChanged);
        connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
                this, &PhonePanel::forgetActiveWindow);
    }

    bool newAllMinimized = true;
    for (auto *w : m_windowManagement->windows()) {
        if (!w->isMinimized() && !w->skipTaskbar() && !w->isFullscreen() /*&& w->appId() != QStringLiteral("org.kde.plasmashell")*/) {
            qDebug() << "updateActiveWindow:" << w->appId() << " " << w->pid();
            newAllMinimized = false;
            break;
        }
    }

    m_allMinimized = newAllMinimized;
    emit allMinimizedChanged();
    // TODO: connect to closeableChanged, not needed right now as KWin doesn't provide this changeable
    emit hasCloseableActiveWindowChanged();
}

bool PhonePanel::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable() /*&& !m_activeWindow->isMinimized()*/;
}

void PhonePanel::forgetActiveWindow()
{
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &PhonePanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
                   this, &PhonePanel::forgetActiveWindow);
    }
    m_activeWindow.clear();
    emit hasCloseableActiveWindowChanged();
}

void PhonePanel::closeActiveWindow()
{
    if (m_activeWindow) {
        m_activeWindow->requestClose();
    }
}

bool PhonePanel::allMinimized() const {
    return m_allMinimized;
}



K_EXPORT_PLASMA_APPLET_WITH_JSON(quicksettings, PhonePanel, "metadata.json")

#include "phonepanel.moc"
