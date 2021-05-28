/***************************************************************************
 *   Copyright (C) 2021 Wang Rui <wangrui@jingos.com>                      *
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

#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

#include <QObject>
#include "basemodel.h"
#include "launcheritem.h"
#include "type.h"

class ApplicationListModel : public QObject
{
    Q_OBJECT

public:
    explicit ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel();

    void setAppData(ApplicationData data);
};

#endif // APPLICATIONLISTMODEL_H
