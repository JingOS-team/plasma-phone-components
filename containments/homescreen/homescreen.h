/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *   Copyright (C) 2021 Wang Rui <wangrui@jingos.com>
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

#ifndef HOMESCREEN_H
#define HOMESCREEN_H


#include <Plasma/Containment>

class QQuickItem;
class ListModelManager;
class NegativeModel;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(ListModelManager *listModelManager READ listModelManager CONSTANT)
    Q_PROPERTY(NegativeModel *negativeModel READ negativeModel CONSTANT)
public:
    HomeScreen( QObject *parent, const QVariantList &args );
    ~HomeScreen() override;

    void configChanged() override;

    ListModelManager *listModelManager();
    NegativeModel *negativeModel();

    Q_INVOKABLE void stackBefore(QQuickItem *item1, QQuickItem *item2);
    Q_INVOKABLE void stackAfter(QQuickItem *item1, QQuickItem *item2);

protected:
   // void configChanged() override;

private:
    ListModelManager *m_listModelManager = nullptr;
    NegativeModel *m_negativeModel = nullptr;
};

#endif
