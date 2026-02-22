#ifndef DOWNLOADERMODEL_H
#define DOWNLOADERMODEL_H
#include <QAbstractListModel>
#include "parser/KhinsiderParser.h"


class DownloaderModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QString bulkUrlBuffer READ bulkUrlBuffer WRITE setBulkUrlBuffer NOTIFY bulkUrlBufferChanged)
    Q_PROPERTY(int selectedQueueIndex READ selectedQueueIndex WRITE setSelectedQueueIndex NOTIFY selectedQueueIndexChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        StatusRole,
        ProgressRole,
        SpeedRole,
        SizeRole,
        StateRole,
        DownloadedSongsRole,
        TotalSongsRole
    };

    explicit DownloaderModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Album *getAlbumAt(int index) const;

    Q_INVOKABLE double totalProgress() const;

    Q_INVOKABLE qint64 totalDownloadedSize() const;

    Q_INVOKABLE qint64 totalSpeed() const;

    Q_INVOKABLE qint64 totalSize() const;

    Q_INVOKABLE int totalDownloadedSongs() const;

    Q_INVOKABLE int totalSongs() const;
    Q_INVOKABLE void appendBulkUrlBuffer(const QString &urls);
    Q_INVOKABLE bool hasSelectedQueueItem() const;
    Q_INVOKABLE void cancelSelectedAlbum();
    Q_INVOKABLE void retrySelectedAlbum();
    QString bulkUrlBuffer() const { return m_bulkUrlBuffer; }
    int selectedQueueIndex() const { return m_selectedQueueIndex; }

public slots:
    void cancelAllDownloads();

    void cancelAlbum(int index);

    void retryAlbum(int index);

    void setAlbums(const QVector<Album *> &albums);

    void insertAlbum(Album *album);
    void setBulkUrlBuffer(const QString &buffer);
    void setSelectedQueueIndex(int index);

signals:
    void albumCancelRequested(Album *album);

    void albumRetryRequested(Album *album);

    void totalsChanged();

    void addToDownloadList(const QString &List);
    void bulkUrlBufferChanged();
    void selectedQueueIndexChanged();

private:
    QVector<Album *> m_albums;
    QString m_bulkUrlBuffer;
    int m_selectedQueueIndex = -1;
};

#endif // DOWNLOADERMODEL_H
