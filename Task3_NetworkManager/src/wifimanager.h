// src/wifimanager.h
#ifndef WIFIMANAGER_H
#define WIFIMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QMap>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusObjectPath>

class WiFiManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool wifiEnabled
                   READ getWifiEnabled
                       WRITE setWifiEnabled
                           NOTIFY wifiEnabledChanged)

    Q_PROPERTY(bool isScanning
                   READ getIsScanning
                       NOTIFY isScanningChanged)

    Q_PROPERTY(QString connectedNetwork
                   READ getConnectedNetwork
                       NOTIFY connectedNetworkChanged)

    Q_PROPERTY(QVariantList networks
                   READ getNetworks
                       NOTIFY networksChanged)

public:
    explicit WiFiManager(QObject *parent = nullptr);
    ~WiFiManager();

    // Property getters
    bool getWifiEnabled() const;
    bool getIsScanning() const;
    QString getConnectedNetwork() const;
    QVariantList getNetworks() const;

    // Property setter
    void setWifiEnabled(bool enabled);

    // Methods callable from QML
    Q_INVOKABLE void scanNetworks();
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void disconnectFromNetwork();

signals:
    // Property change notifications
    void wifiEnabledChanged(bool enabled);
    void isScanningChanged(bool scanning);
    void connectedNetworkChanged(const QString &ssid);
    void networksChanged();

    // Action notifications
    void connectionSuccess(const QString &ssid);
    void connectionFailed(const QString &message);
    void disconnected();
    void errorOccurred(const QString &message);

private slots:
    /*
     * D-Bus Signal Handlers
     *
     * These slots are called automatically when NetworkManager
     * sends signals over D-Bus. We connect to these in the constructor.
     */

    // Called when NetworkManager properties change (e.g., WirelessEnabled)
    void onNMPropertiesChanged(QString interface,
                               QVariantMap changedProperties,
                               QStringList invalidatedProperties);

    // Called when WiFi device properties change (e.g., LastScan, ActiveAccessPoint)
    void onDevicePropertiesChanged(QString interface,
                                   QVariantMap changedProperties,
                                   QStringList invalidatedProperties);

    // Called when a new access point appears
    void onAccessPointAdded(QDBusObjectPath path);

    // Called when an access point disappears
    void onAccessPointRemoved(QDBusObjectPath path);

private:
    // State
    bool m_wifiEnabled;
    bool m_isScanning;
    QString m_connectedNetwork;
    QString m_wirelessDevicePath;

    // Cache of access points: path -> info map
    QMap<QString, QVariantMap> m_accessPointCache;

    // Network list for QML (sorted by signal strength)
    QVariantList m_networks;

    // D-Bus
    QDBusConnection m_systemBus;
    QDBusInterface *m_nmInterface;

    // Private methods
    bool initializeDBus();
    QString findWirelessDevice();
    void connectToDBusSignals();
    void loadInitialAccessPoints();
    void updateActiveConnection();
    void rebuildNetworksList();
    QVariantMap getAccessPointInfo(const QString &apPath);
    QString findSavedConnection(const QString &ssid);
};

#endif // WIFIMANAGER_H
