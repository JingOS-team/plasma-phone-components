/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>
 *
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

#ifndef PHONEPANEL_H
#define PHONEPANEL_H

#include <QFutureWatcher>
#include <Plasma/Containment>

#include <KSharedConfig>
#include <KConfigWatcher>
#include <gst/gst.h>
#include "kscreeninterface.h"
#include "screenshotinterface.h"


namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
class PlasmaWindow;
class PlasmaWindowModel;
class PlasmaShell;
class PlasmaShellSurface;
class Surface;
}
}

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool autoRotateEnabled READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged);
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged);
    Q_PROPERTY(bool udiskInserted READ udiskInserted NOTIFY udiskInsertChanged);
    Q_PROPERTY(bool soundInserted READ soundInserted NOTIFY soundInsertChanged);
    Q_PROPERTY(bool alarmVisible READ alarmVisible NOTIFY alarmStatusChanged);
    //[liubangguo]Active window manager
    Q_PROPERTY(bool allMinimized READ allMinimized NOTIFY allMinimizedChanged)
    Q_PROPERTY(bool hasCloseableActiveWindow READ hasCloseableActiveWindow NOTIFY hasCloseableActiveWindowChanged)
    //[liubangguo]Scheme Color
    Q_PROPERTY(bool isDarkColorScheme READ isDarkColorScheme NOTIFY colorSchemeChanged)
public:
    PhonePanel( QObject *parent, const QVariantList &args );
    ~PhonePanel() override;

    //[liubangguo]Active window manager
    Q_INVOKABLE void closeActiveWindow();
    Q_INVOKABLE void initializeConfigData();
    bool isShowingDesktop() const {
        return m_showingDesktop;
    }
    void requestShowingDesktop(bool showingDesktop);

    bool allMinimized() const;
    bool hasCloseableActiveWindow() const;

    QString activeWindowDesktopName() {
        return m_activeWindowDesktopName;
    }
    QString setActiveWindowDesktopName(const QString &activeWindowDesktopName) {
        if(m_activeWindowDesktopName == activeWindowDesktopName)
            return m_activeWindowDesktopName;
        m_activeWindowDesktopName = activeWindowDesktopName;
        emit activeWindowDesktopNameChanged();
        return m_activeWindowDesktopName;
    }
public Q_SLOTS:
    void forgetActiveWindow();

Q_SIGNALS:
    void showingDesktopChanged(bool);
    void hasCloseableActiveWindowChanged();
    void panelChanged();
    void allMinimizedChanged();
    void activeWindowDesktopNameChanged();
    void setToDefaultVolume(int defaultVolume);
    //end


public Q_SLOTS:
    void executeCommand(const QString &command);
    void toggleTorch();
    void takeScreenshot();
    void runApplication(const QString& packageName);

    bool autoRotate();
    void setAutoRotate(bool value);
    
    bool isSystem24HourFormat();
    bool isDarkColorScheme();

    bool udiskInserted();
    bool soundInserted();

    void kcmClockUpdated();
    void handleFinished();
    bool alarmVisible();
    void alarmVisibleChanged(bool);

    void slotDeviceAdded(QString);
    void slotDeviceRemoved(QString);

signals:
    void autoRotateChanged(bool value);
    void isSystem24HourFormatChanged();
    void udiskInsertChanged(bool);
    void soundInsertChanged(bool);
    void alarmStatusChanged(bool);
    void colorSchemeChanged();

private:
    void initWayland();
    void initWindowManagement();
    void updateActiveWindow();

private:
    GstElement* m_pipeline;
    GstElement* m_sink;
    GstElement* m_source;
    bool m_running = false;
    bool m_udiskInsert = false;
    bool m_soundInsert = false;
    bool m_alarmVisible = false;
    bool m_takingScreenShot = false;

    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;

    org::kde::KScreen *m_kscreenInterface;
    org::kde::kwin::Screenshot *m_screenshotInterface;

    QFutureWatcher<void> futureWatcher;
    QFuture<void> m_future;

    QString m_strScreenShot;
    bool m_initWatcherFlag;

    //[liubangguo]Active window manager
    bool m_showingDesktop = false;
    bool m_allMinimized = true;
    QString m_activeWindowDesktopName;
    KWayland::Client::PlasmaShellSurface *m_shellSurface = nullptr;
    KWayland::Client::Surface *m_surface = nullptr;
    KWayland::Client::PlasmaShell *m_shellInterface = nullptr;
    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    KWayland::Client::PlasmaWindowModel *m_windowModel = nullptr;
    QPointer<KWayland::Client::PlasmaWindow> m_activeWindow;
    QTimer *m_activeTimer;

};

#endif
