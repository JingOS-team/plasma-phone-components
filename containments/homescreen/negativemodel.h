/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
#ifndef NEGATIVEMODEL_H
#define NEGATIVEMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QImage>
#include <dlfcn.h>
#include <QFutureWatcher>
#include <QFuture>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QProcess>
#include <QFileInfo>

struct NegativeData{
    QString image;
    QString noteJsonObjectStr;
    QString scheme;
    QString filePath;
};
struct FileData{
    QString image;
    QString fileName;
    QString size;
    QString filePath;
};
class NegativeModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString noteAppName READ noteAppName NOTIFY noteAppNameChanged)
    Q_PROPERTY(QString noteIcon READ noteIcon NOTIFY noteIconChanged)
public:
    explicit NegativeModel(QObject *parent = nullptr);
    virtual ~NegativeModel();

    enum ModelDataRoles {
        ModelDataRole = 1,
        Data_Image = 2,
        Data_FilePath = 3,
        Data_FileName = 4,
        Data_FileSize = 5
    };
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QString noteAppName() {
        return m_noteAppName;
    };
    QString noteIcon() {
        return m_noteIcon;
    }

    void setNoteAppName(QString noteName);
    void setNoteIcon(QString noteIcon);

    void refreshModelData(QList<NegativeData> images);
    void refreshFileModelData(QList<FileData> files);
    Q_INVOKABLE void loadNegativeData();
    Q_INVOKABLE void runNoteApp(int index);
    Q_INVOKABLE void loadDocData();
private:
    QString getIconName(QString suffix);
    QString sizeFormat(quint64 size);
Q_SIGNALS:
   void noteAppNameChanged();
   void noteIconChanged();

private:
    QList<NegativeData> m_negativeDatas;
    QList<FileData> m_fileDatas;
    QFutureWatcher<QList<NegativeData>> *watcher;
    QFutureWatcher<QList<FileData>> *fileWatcher;
    QString m_noteAppName;
    QString m_noteIcon;
    QJsonArray m_negativeJsonArray;
signals:

};

#endif // NEGATIVEMODEL_H
