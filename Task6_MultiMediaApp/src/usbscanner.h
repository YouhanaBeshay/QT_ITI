#ifndef USBSCANNER_H
#define USBSCANNER_H

#include <QObject>
#include <QStringList>
#include <QVariantList>

class UsbScanner : public QObject
{
    Q_OBJECT
public:
    explicit UsbScanner(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getUsbAudioFiles();
    Q_INVOKABLE QVariantList getUsbVideoFiles();

signals:


private:
    bool isAudioFile(const QString &fileName);
    bool isVideoFile(const QString &fileName);

};

#endif // USBSCANNER_H
