// src/bluetoothmanager.h
#ifndef BLUETOOTHMANAGER_H
#define BLUETOOTHMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QMap>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusObjectPath>

class BluetoothManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool bluetoothEnabled
                   READ getBluetoothEnabled
                       WRITE setBluetoothEnabled
                           NOTIFY bluetoothEnabledChanged)

    // Reflects BlueZ's Discovering state (read-only, we don't control it)
    Q_PROPERTY(bool isDiscovering
                   READ getIsDiscovering
                       NOTIFY isDiscoveringChanged)

    Q_PROPERTY(QVariantList devices
                   READ getDevices
                       NOTIFY devicesChanged)


    Q_PROPERTY(bool isConnecting
                   READ getIsConnecting
                       NOTIFY isConnectingChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);
    ~BluetoothManager();

    // Property getters
    bool getBluetoothEnabled() const;
    bool getIsDiscovering() const;
    QVariantList getDevices() const;
    bool getIsConnecting() const;

    // Property setter
    void setBluetoothEnabled(bool enabled);

    // Methods callable from QML
    Q_INVOKABLE void refreshDevices();
    Q_INVOKABLE void connectToDevice(const QString &address);
    Q_INVOKABLE void disconnectFromDevice(const QString &address);
    Q_INVOKABLE void pairDevice(const QString &address);
    Q_INVOKABLE void removeDevice(const QString &address);

signals:
    // Property change notifications
    void bluetoothEnabledChanged(bool enabled);
    void isDiscoveringChanged(bool discovering);
    void isConnectingChanged(bool connecting);
    void devicesChanged();

    // Action notifications
    void deviceConnected(const QString &name);
    void deviceDisconnected(const QString &name);
    void devicePaired(const QString &name);
    void errorOccurred(const QString &message);

private slots:
    // D-Bus signal handlers
    void onAdapterPropertiesChanged(QString interface,
                                    QVariantMap changedProperties,
                                    QStringList invalidatedProperties);

    void onInterfacesAdded(QDBusObjectPath path,
                           QMap<QString, QVariantMap> interfaces);

    void onInterfacesRemoved(QDBusObjectPath path,
                             QStringList interfaces);

    void onDevicePropertiesChanged(QString interface,
                                   QVariantMap changedProperties,
                                   QStringList invalidatedProperties);

private:
    // State
    bool m_bluetoothEnabled;
    bool m_isDiscovering;
    bool m_isConnecting = false;
    QString m_adapterPath;

    // Cache of devices
    QMap<QString, QVariantMap> m_deviceCache;
    QVariantList m_devices;

    // D-Bus
    QDBusConnection m_systemBus;
    QDBusInterface *m_adapterInterface;

    // Private methods
    bool initializeDBus();
    QString findAdapter();
    void connectToDBusSignals();
    void loadDevices();
    void rebuildDevicesList();
    QVariantMap getDeviceInfo(const QString &devicePath);
    QString addressToPath(const QString &address);
};

#endif // BLUETOOTHMANAGER_H
