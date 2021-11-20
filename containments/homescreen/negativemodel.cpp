/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "negativemodel.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrentRun>
#include <QThreadPool>

#define NEGATIVE_LIB "libjing_android_proxy.so"
#define NEGATIVE_TIMEOUT "SetTimeout"
#define NEGATIVE_TIMEOUT_SIZE 1000

NegativeModel::NegativeModel(QObject *parent)
    :QAbstractListModel(parent)
{
    watcher = new QFutureWatcher<QList<NegativeData>>;
    connect(watcher, &QFutureWatcher<QList<NegativeData>>::finished, [&]()
    {
        refreshModelData(watcher->result());
    });
//    loadNegativeData();
    fileWatcher = new QFutureWatcher<QList<FileData>>;
    connect(fileWatcher, &QFutureWatcher<QList<FileData>>::finished, [&]()
    {
        refreshFileModelData(fileWatcher->result());
    });
    loadDocData();
}

NegativeModel::~NegativeModel()
{
}

QHash<int, QByteArray> NegativeModel::roleNames() const
{
    QHash<int, QByteArray> roleNames { { NegativeModel::ModelDataRole, "modelData" },
                                       { NegativeModel::Data_Image, "data_image"},
                                       { NegativeModel::Data_FilePath, "data_filepath"},
                                       { NegativeModel::Data_FileName, "data_filename"},
                                       { NegativeModel::Data_FileSize, "data_filesize"}
                                     };

    return roleNames;
}
int NegativeModel::rowCount(const QModelIndex &parent) const
{
//    return parent.isValid() ? 0 : m_negativeDatas.size();
    return parent.isValid() ? 0 : m_fileDatas.size();
}

QVariant NegativeModel::data(const QModelIndex &index, int role) const
{
    int indexValue = index.row();
//    if (m_negativeDatas.size() <= indexValue) {
//        return QVariant();
//    }
//    NegativeData data = m_negativeDatas.at(indexValue);
//    if (role == NegativeModel::Data_Image) {
//        qDebug() << Q_FUNC_INFO << " image base64:" << data.image;
//        return data.image;
//    } else if (role == NegativeModel::Data_FilePath) {
//        qDebug() << Q_FUNC_INFO << " Data_filePath :" << data.filePath;
//        return data.filePath;
//    }
    if (m_fileDatas.size() <= indexValue) {
        return QVariant();
    }
    FileData data = m_fileDatas.at(indexValue);
    if (role == NegativeModel::Data_Image) {
        return data.image;
    } else if (role == NegativeModel::Data_FilePath) {
        return data.filePath;
    } else if (role == NegativeModel::Data_FileName) {
        return data.fileName;
    } else if (role == NegativeModel::Data_FileSize) {
        return data.size;
    }

    return QVariant();
}

void NegativeModel::setNoteAppName(QString noteName)
{
    if(noteName == m_noteAppName){
        return;
    }
    m_noteAppName = noteName;
    emit noteAppNameChanged();
}

void NegativeModel::setNoteIcon(QString noteIcon)
{
    if (noteIcon.isNull()) {
        return;
    }
    m_noteIcon = noteIcon;
    emit noteIconChanged();
}
void NegativeModel::refreshFileModelData(QList<FileData> datas)
{
    beginResetModel();
    m_fileDatas.clear();
    m_fileDatas = datas;
    endResetModel();
}

void NegativeModel::refreshModelData(QList<NegativeData> datas)
{
    qDebug() << Q_FUNC_INFO << " images size::" << datas.size() << " m_negativeDatas.size():" <<m_negativeDatas.size();
    if(m_negativeDatas.size() > 0 && datas.size() <= 0){
        return ;
    }

    m_negativeDatas.clear();
    beginResetModel();
    if (datas.size() > 1) {
        foreach (NegativeData item, datas) {
            if(m_negativeDatas.size() < 3){
                m_negativeDatas.append(item);
            } else {
                break;
            }
        }
    }
    while (m_negativeDatas.size() < 3) {
        NegativeData emptyNegative;
        if (datas.size() > 0) {
            emptyNegative = datas.at(datas.size()-1);
        }
        m_negativeDatas.append(emptyNegative);
    }

    endResetModel();
}

void NegativeModel::runNoteApp(int index)
{
    qDebug() << Q_FUNC_INFO << " index::" << index;

    void *handle = dlopen (NEGATIVE_LIB, RTLD_NOW);
    if (!handle) {
        qDebug()<< Q_FUNC_INFO << "dlopen: error:::"<< dlerror();
        return ;
    }
    void (*func_setTimeout_name)(int);

    *(void**)(&func_setTimeout_name)= dlsym(handle, NEGATIVE_TIMEOUT);
    func_setTimeout_name(NEGATIVE_TIMEOUT_SIZE);
    if (index == -1) {
        int (*func_startApp_name)(const std::string&,const std::string&);
        func_startApp_name =  reinterpret_cast<int (*)(const std::string&,const std::string&)>(dlsym(handle, "StartApp"));
        func_startApp_name("com.asa.jingnote","");
        qDebug()<< Q_FUNC_INFO << "dlsym: StartApp::com.asa.jingnote:";
    } else {
        NegativeData itemData = m_negativeDatas.at(index);
        QString startJsonStr = itemData.noteJsonObjectStr;
        if(startJsonStr != "") {
            const std::string startJsonStdStr = startJsonStr.toStdString();
            int (*func_startAppFromWidget_name)(const std::string&);
            func_startAppFromWidget_name =  reinterpret_cast<int (*)(const std::string&)>(dlsym(handle, "StartAppFromWidget"));
            func_startAppFromWidget_name(startJsonStdStr);
        }
        qDebug()<< Q_FUNC_INFO << "dlsym: func_startAppFromWidget_name:::" << startJsonStr;
    }
    dlclose(handle);
}

void NegativeModel::loadNegativeData()
{
    const auto func = [=]() -> QList<NegativeData>
    {
        QList<NegativeData> m_thread_datas;
        void *handle = dlopen (NEGATIVE_LIB, RTLD_NOW);
        if (!handle) {
            qDebug() << Q_FUNC_INFO << "dlopen: error:::%s "<< dlerror();
            return m_thread_datas;
        }
        void (*func_setTimeout_name)(int);
        int (*func_getinfo_name)(std::string&);

        *(void**)(&func_setTimeout_name)= dlsym(handle, NEGATIVE_TIMEOUT);
        func_setTimeout_name(NEGATIVE_TIMEOUT_SIZE);
        if(dlerror() != NULL){
            qDebug() << Q_FUNC_INFO << "dlsym:setTimeout error: " << dlerror();
        }
        qDebug() << Q_FUNC_INFO << " SetTimeout:: end";

        func_getinfo_name =  reinterpret_cast<int (*)(std::string&)>(dlsym(handle, "GetAllWidgetInfo"));

        std::string ajs;
        func_getinfo_name(ajs);
        QString negativeStr = QString::fromStdString(ajs);
        auto json = QJsonDocument::fromJson(QByteArray::fromStdString(ajs)).object();
        qDebug() << Q_FUNC_INFO << " json::"<<json;
        if (json.empty()) {
            qDebug()<<Q_FUNC_INFO << " stream json.empty():" << negativeStr;
            m_negativeJsonArray = QJsonDocument::fromJson(QByteArray::fromStdString(ajs)).array();
            return m_thread_datas;
        }

        dlclose(handle);

        QString pkgName = json.value("pkg_name").toString();
        setNoteAppName(pkgName);

        auto appList = json.value(QString::fromUtf8("widgetBeans")).toArray();
        qDebug() << Q_FUNC_INFO << " appList::"<<appList.size();
        if (appList.size() < 1) {
            return m_thread_datas;
        }

        for (int i = 0; i < appList.size(); i++) {
            NegativeData itemData;
            auto appObj = appList.at(i).toObject();
            QString strJson(QJsonDocument(appObj).toJson());
            itemData.noteJsonObjectStr = strJson;
            qDebug() << Q_FUNC_INFO << " thread datas:" << itemData.noteJsonObjectStr;

            QString thumbStr = appObj.value("base64").toString();
            if(thumbStr != "") {
                itemData.image = thumbStr;
            }
            QString scheme = appObj.value("scheme").toString();
            QString filePath = appObj.value("file_path").toString();
            itemData.scheme = scheme;
            itemData.filePath = filePath;
            m_thread_datas.append(itemData);
        }

        m_negativeJsonArray = appList;
        return m_thread_datas;
    };
    QFuture<QList<NegativeData>> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void NegativeModel::loadDocData()
{
    const auto func = [=]() -> QList<FileData>
    {
        QList<FileData> m_thread_datas;
        QProcess balooProcess;
        balooProcess.start("baloosearch -l 6 type:document");
        if (!balooProcess.waitForStarted())
        {
            return m_thread_datas;
        }
        balooProcess.closeWriteChannel();
        if (!balooProcess.waitForFinished())
        {
            return m_thread_datas;
        }
        QByteArray bateArray = balooProcess.readAll();
        QString result = QString(bateArray);
        QStringList pathList = result.split(QLatin1Char('\n'), Qt::SkipEmptyParts);//以“\n”为间隔，分割返回的数据
        int count = 0;
        foreach (const QString &path, pathList) {
            if(count > 5) {
                break;
            }
            QFileInfo file(path);
            FileData fileData;
            if (!file.exists()) {
                continue;
            }
            fileData.fileName = file.fileName().remove(file.fileName().lastIndexOf("."), file.fileName().size());
            fileData.filePath = file.absoluteFilePath();
            fileData.size = sizeFormat(file.size());
            fileData.image = getIconName(file.suffix());
            m_thread_datas.append(fileData);
            qDebug()<< Q_FUNC_INFO << " fileName:"
                    << fileData.fileName
                    <<" filePath:" << fileData.filePath
                   <<" fileSize:" << fileData.size
                  <<" fileImage:" << fileData.image;
            count ++ ;
        }
        while (m_thread_datas.size() < 6 && m_thread_datas.size() > 0) {
            FileData fileData;
            m_thread_datas.append(fileData);
        }
        return m_thread_datas;
    };
    QFuture<QList<FileData>> t1 = QtConcurrent::run(func);
    fileWatcher->setFuture(t1);
}

QString NegativeModel::sizeFormat(quint64 size)
{
    qreal calc = size;
    QStringList list;
    list << "KB" << "MB" << "GB" << "TB";

    QStringListIterator i(list);
    QString unit("B");

    while(calc >= 1024.0 && i.hasNext())
    {
        unit = i.next();
        calc /= 1024.0;
    }

    return QString().setNum(calc, 'f', 2) + " " + unit;
}

QString NegativeModel::getIconName(QString suffix)
{
    QString imageSource = "";
    if (suffix.indexOf("text") != -1) {
        imageSource = "../../image/text.svg";
    } else if (suffix.indexOf("doc") != -1) {
        imageSource = "../../image/word.svg";
    } else if (suffix.indexOf("ppt") != -1) {
        imageSource = "../../image/ppt.svg";
    } else if (suffix.indexOf("xls") != -1) {
        imageSource = "../../image/excel.svg";
    } else if (suffix.indexOf("pdf") != -1) {
        imageSource = "../../image/pdf.svg";
    } else {
        imageSource = "../../image/text.svg";
    }
    return imageSource;
}
