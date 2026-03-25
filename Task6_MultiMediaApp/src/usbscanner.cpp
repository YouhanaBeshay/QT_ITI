#include "usbscanner.h"
#include <QDirIterator>
#include <QFileInfo>


UsbScanner::UsbScanner(QObject *parent)
    : QObject{parent}
{}

bool UsbScanner::isAudioFile(const QString &fileName)
{
    static QStringList filters = {
        ".mp3", ".wav", ".flac", ".ogg",
        ".aac", ".m4a", ".wma", ".opus"
    };

    for (const QString &ext : filters) {
        if (fileName.endsWith(ext, Qt::CaseInsensitive))
            return true;
    }
    return false;
}

//================== Audio functions =======================
QVariantList UsbScanner::getUsbAudioFiles()
{
    QVariantList result;

    QString rootPath = "/media";

    QDirIterator it(rootPath,
                    QDir::Files,
                    QDirIterator::Subdirectories);

    while (it.hasNext()) {
        QString filePath = it.next();
        QFileInfo info(filePath);

        if (isAudioFile(info.fileName())) {
            QVariantMap track;
            track["title"] = info.fileName();
            track["url"] = "file://" + filePath;

            result.append(track);
        }
    }

    return result;
}

//================== Video functions =======================

bool UsbScanner::isVideoFile(const QString &fileName){
    static QStringList filters = {
        ".mp4", ".mov", ".mkv", ".webm",
        ".avi", ".mpg", ".ogg", ".flv"
    };

    for (const QString &ext : filters) {
        if (fileName.endsWith(ext, Qt::CaseInsensitive))
            return true;
    }
    return false;
}


QVariantList UsbScanner::getUsbVideoFiles()
{
    QVariantList result;

    QString rootPath = "/media";

    QDirIterator it(rootPath,
                    QDir::Files,
                    QDirIterator::Subdirectories);

    while (it.hasNext()) {
        QString filePath = it.next();
        QFileInfo info(filePath);

        if (isVideoFile(info.fileName())) {
            QVariantMap video;
            video["title"] = info.fileName();
            video["url"] = "file://" + filePath;

            result.append(video);
        }
    }

    return result;
}




