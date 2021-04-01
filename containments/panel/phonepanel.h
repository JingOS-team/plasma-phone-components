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


#include <Plasma/Containment>

#include <KSharedConfig>
#include <KConfigWatcher>
#include <gst/gst.h>
#include "kscreeninterface.h"
#include "screenshotinterface.h"

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool autoRotateEnabled READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged);
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged);
public:
    PhonePanel( QObject *parent, const QVariantList &args );
    ~PhonePanel() override;

public Q_SLOTS:
    void executeCommand(const QString &command);
    void toggleTorch();
    void takeScreenshot();

    bool autoRotate();
    void setAutoRotate(bool value);
    
    bool isSystem24HourFormat();

    void kcmClockUpdated();

signals:
    void autoRotateChanged(bool value);
    void isSystem24HourFormatChanged();

private:
    GstElement* m_pipeline;
    GstElement* m_sink;
    GstElement* m_source;
    bool m_running = false;
    
    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;

    org::kde::KScreen *m_kscreenInterface;
    org::kde::kwin::Screenshot *m_screenshotInterface;
};

#endif
