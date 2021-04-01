/***************************************************************************
 *   Copyright (C) 2021 Rui Wang <wangrui@jingos.com>                      *
 *                                                                         *
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

#include "basemodel.h"
#include "basemodel_p.h"

namespace Internal {

// class BaseModel

BaseModel::BaseModel(QObject *parent)
    : QAbstractListModel(parent)
    , d_ptr(new BaseModelPrivate())
{
    d_ptr->q_ptr = this;
}

BaseModel::~BaseModel()
{
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
#ifdef Q_COMPILER_INITIALIZER_LISTS
    QHash<int, QByteArray> roleNames { { BaseModel::ModelDataRole, "modelData" } };
#else
    QHash<int, QByteArray> roleNames;
    roleNames[BaseModel::ModelDataRole] = "modelData";
#endif // Q_COMPILER_INITIALIZER_LISTS

    return roleNames;
}

void BaseModel::_q_resetCount()
{
    Q_D(BaseModel);

    if (d->countEnabled) {
        int count = rowCount();
        if (count != d->count) {
            d->count = count;
            emit countChanged();
        }
    }
}

bool BaseModel::isCountEnabled() const
{
    Q_D(const BaseModel);

    return d->countEnabled;
}

void BaseModel::setCountEnabled(bool y)
{
    Q_D(BaseModel);

    if (y != d->countEnabled) {
        d->countEnabled = y;
        if (!d->countEnabled) {
            d->count = -1;
        }
        emit countEnabledChanged();
    }
}

// class BaseModelPrivate

BaseModelPrivate::BaseModelPrivate()
    : q_ptr(nullptr)
    , countEnabled(false)
    , count(-1)
{
}

BaseModelPrivate::~BaseModelPrivate()
{
}

} // namespace Internal

