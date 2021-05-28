#include "eventfilter.h"
#include <QEvent>
#include <QDebug>
EventFilter::EventFilter()
{

}

bool EventFilter::eventFilter(QObject *obj, QEvent *event)
{
    return QObject::eventFilter(obj, event);
}
