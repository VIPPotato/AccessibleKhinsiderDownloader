#ifndef SEARCHRESULTMODEL_H
#define SEARCHRESULTMODEL_H
#include <QAbstractListModel>
#include <QTimer>

#include "parser/Album.h"

class SearchResultModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        AlbumLinkRole,
    };

    explicit SearchResultModel(QObject *parent = nullptr)
        : QAbstractListModel(parent) {
        m_selectionDebounceTimer.setSingleShot(true);
        m_selectionDebounceTimer.setInterval(150);
        connect(&m_selectionDebounceTimer, &QTimer::timeout, this, [this]() {
            QSharedPointer<Album> album = getAlbumAt(m_selectedIndex);
            if (album) {
                emit albumSelected(album);
            }
        });
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        return m_albums.count();
    }

    QSharedPointer<Album> getAlbumAt(int index) const {
        if (index >= 0 && index < m_albums.count())
            return m_albums.at(index);
        return nullptr;
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!index.isValid() || index.row() >= m_albums.count())
            return QVariant();

        auto album = m_albums.at(index.row());

        switch (role) {
            case NameRole:
                return album->name();
            case AlbumLinkRole:
                return album->albumLink();
        }

        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[NameRole] = "name";
        roles[AlbumLinkRole] = "albumLink";
        return roles;
    }

    void setAlbums(const QVector<QSharedPointer<Album> > &albums) {
        beginResetModel();
        m_albums = albums;
        endResetModel();
    }

    int selectedIndex() const { return m_selectedIndex; }
    QVector<QSharedPointer<Album> > &albums() { return m_albums; }
    Q_INVOKABLE int findIndexByNamePrefix(const QString &prefix, int startIndex = 0) const {
        const QString needle = prefix.trimmed();
        if (needle.isEmpty() || m_albums.isEmpty()) {
            return -1;
        }

        const int count = m_albums.count();
        int start = startIndex;
        if (start < 0 || start >= count) {
            start = 0;
        }

        for (int offset = 0; offset < count; ++offset) {
            const int idx = (start + offset) % count;
            if (m_albums.at(idx)->name().startsWith(needle, Qt::CaseInsensitive)) {
                return idx;
            }
        }

        return -1;
    }

public slots:
    void onSearchResultsReceived(const QVector<QSharedPointer<Album> > &result) {
        m_selectionDebounceTimer.stop();
        m_selectedIndex = -1;
        setAlbums(result);
        emit searchCompleted();
    }

    void setSelectedIndex(int index) {
        int normalizedIndex = -1;
        if (index >= 0 && index < m_albums.count()) {
            normalizedIndex = index;
        }

        if (normalizedIndex == m_selectedIndex) {
            return;
        }

        m_selectedIndex = normalizedIndex;
        emit selectedIndexChanged();

        m_selectionDebounceTimer.stop();
        if (m_selectedIndex >= 0) {
            m_selectionDebounceTimer.start();
        }
    }

signals:
    void searchStarted();

    void searchCompleted();

    void performSearch(const QString &query);

    void requestAddAlbums(QVector<QSharedPointer<Album> > albums, DownloadQuality quality);

    void selectedIndexChanged();

    void albumSelected(QSharedPointer<Album> album);

private:
    QVector<QSharedPointer<Album> > m_albums;
    int m_selectedIndex = -1;
    QTimer m_selectionDebounceTimer;
};
#endif //SEARCHRESULTMODEL_H
