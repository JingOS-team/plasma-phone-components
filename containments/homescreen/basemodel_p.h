/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#ifndef BASEMODEL_P_H
#define BASEMODEL_P_H

#include <QMutex>

#include "basemodel.h"

namespace Internal {

class BaseModelPrivate
{
    Q_DECLARE_PUBLIC(BaseModel)

public:
    BaseModelPrivate();
    virtual ~BaseModelPrivate();
protected:
    BaseModel *q_ptr;

protected:
    bool countEnabled;
    int  count;
};

} // namespace Internal

#endif // BASEMODEL_P_H
