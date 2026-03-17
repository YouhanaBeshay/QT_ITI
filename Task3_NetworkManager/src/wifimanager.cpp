// src/wifimanager.cpp
#include "wifimanager.h"

#include <QDBusReply>
#include <QDBusArgument>
#include <QDBusVariant>
#include <QDBusMessage>
#include <QDebug>
#include <algorithm>

/*
 * D-Bus Constants
 */
namespace NM {
// Service name
constexpr const char* SERVICE = "org.freedesktop.NetworkManager";

// Object paths
constexpr const char* PATH = "/org/freedesktop/NetworkManager";
constexpr const char* SETTINGS_PATH = "/org/freedesktop/NetworkManager/Settings";

// Interfaces
constexpr const char* INTERFACE = "org.freedesktop.NetworkManager";
constexpr const char* DEVICE_INTERFACE = "org.freedesktop.NetworkManager.Device";
constexpr const char* WIRELESS_INTERFACE = "org.freedesktop.NetworkManager.Device.Wireless";
constexpr const char* AP_INTERFACE = "org.freedesktop.NetworkManager.AccessPoint";
constexpr const char* SETTINGS_INTERFACE = "org.freedesktop.NetworkManager.Settings";
constexpr const char* CONNECTION_INTERFACE = "org.freedesktop.NetworkManager.Settings.Connection";
constexpr const char* PROPS_INTERFACE = "org.freedesktop.DBus.Properties";

// Property names
constexpr const char* PROP_WIRELESS_ENABLED = "WirelessEnabled";
constexpr const char* PROP_DEVICE_TYPE = "DeviceType";
constexpr const char* PROP_LAST_SCAN = "LastScan";
constexpr const char* PROP_ACTIVE_AP = "ActiveAccessPoint";
constexpr const char* PROP_ACTIVE_CONN = "ActiveConnection";

// Signal names
constexpr const char* SIGNAL_PROPS_CHANGED = "PropertiesChanged";
constexpr const char* SIGNAL_AP_ADDED = "AccessPointAdded";
constexpr const char* SIGNAL_AP_REMOVED = "AccessPointRemoved";

// Method names
constexpr const char* METHOD_GET_DEVICES = "GetAllDevices";
constexpr const char* METHOD_GET_APS = "GetAccessPoints";
constexpr const char* METHOD_REQUEST_SCAN = "RequestScan";
constexpr const char* METHOD_LIST_CONNECTIONS = "ListConnections";
constexpr const char* METHOD_GET_SETTINGS = "GetSettings";
constexpr const char* METHOD_ACTIVATE_CONNECTION = "ActivateConnection";
constexpr const char* METHOD_ADD_AND_ACTIVATE = "AddAndActivateConnection";
constexpr const char* METHOD_DEACTIVATE_CONNECTION = "DeactivateConnection";
}

// ============================================================================
// CONSTRUCTOR & DESTRUCTOR
// ============================================================================

WiFiManager::WiFiManager(QObject *parent)
    : QObject(parent)
    , m_wifiEnabled(false)
    , m_isScanning(false)
    , m_systemBus(QDBusConnection::systemBus())
    , m_nmInterface(nullptr)
{
    qDebug() << "WiFiManager: Initializing...";

    if (!initializeDBus()) {
        qWarning() << "WiFiManager: Initialization failed!";
        return;
    }

    // Connect to D-Bus signals to receive notifications
    connectToDBusSignals();

    // Load current access points
    if (m_wifiEnabled) {
        loadInitialAccessPoints();
    }

    // Get current connection status
    updateActiveConnection();

    qDebug() << "WiFiManager: Ready!";
    qDebug() << "  WiFi enabled:" << m_wifiEnabled;
    qDebug() << "  Connected to:" << m_connectedNetwork;
    qDebug() << "  Networks found:" << m_networks.count();
}

WiFiManager::~WiFiManager()
{
    delete m_nmInterface;
}

// ============================================================================
// INITIALIZATION
// ============================================================================

bool WiFiManager::initializeDBus()
{
    // Check D-Bus connection
    if (!m_systemBus.isConnected()) {
        qWarning() << "Cannot connect to D-Bus system bus";
        emit errorOccurred("Cannot connect to system bus");
        return false;
    }
    qDebug() << "  Connected to D-Bus";

    // Create NetworkManager interface
    m_nmInterface = new QDBusInterface(
        NM::SERVICE,
        NM::PATH,
        NM::INTERFACE,
        m_systemBus,
        this
        );

    if (!m_nmInterface->isValid()) {
        qWarning() << "NetworkManager interface invalid";
        emit errorOccurred("Cannot connect to NetworkManager");
        return false;
    }
    qDebug() << "  NetworkManager interface OK";

    // Find wireless device
    m_wirelessDevicePath = findWirelessDevice();
    if (m_wirelessDevicePath.isEmpty()) {
        qWarning() << "No WiFi device found";
        emit errorOccurred("No WiFi device found");
        return false;
    }
    qDebug() << "  WiFi device:" << m_wirelessDevicePath;

    // Get initial WiFi enabled state
    // Using property() is simpler than calling through Properties interface
    m_wifiEnabled = m_nmInterface->property(NM::PROP_WIRELESS_ENABLED).toBool();

    return true;
}

QString WiFiManager::findWirelessDevice()
{
    QDBusReply<QList<QDBusObjectPath>> reply =
        m_nmInterface->call(NM::METHOD_GET_DEVICES);

    if (!reply.isValid()) {
        qWarning() << "GetAllDevices failed:" << reply.error().message();
        return QString();
    }

    for (const QDBusObjectPath &devicePath : reply.value()) {
        QDBusInterface device(
            NM::SERVICE,
            devicePath.path(),
            NM::DEVICE_INTERFACE,
            m_systemBus
            );

        // DeviceType 2 = WiFi
        if (device.property(NM::PROP_DEVICE_TYPE).toUInt() == 2) {
            return devicePath.path();
        }
    }

    return QString();
}

/*
 * Connect to D-Bus Signals
 *
 * This is the key improvement! We subscribe to signals so NetworkManager
 * notifies us when things change, instead of us having to poll.
 *
 * m_bus.connect() parameters:
 *   1. Service name
 *   2. Object path
 *   3. Interface name
 *   4. Signal name
 *   5. Receiver object (this)
 *   6. Slot to call (must use SLOT() macro)
 */
void WiFiManager::connectToDBusSignals()
{
    // 1. Listen for NetworkManager property changes (WiFi enabled/disabled)
    m_systemBus.connect(
        NM::SERVICE,                    // Service
        NM::PATH,                       // Path: /org/freedesktop/NetworkManager
        NM::PROPS_INTERFACE,            // Interface: org.freedesktop.DBus.Properties
        NM::SIGNAL_PROPS_CHANGED,       // Signal: PropertiesChanged
        this,                           // Receiver
        SLOT(onNMPropertiesChanged(QString, QVariantMap, QStringList))
        );
    qDebug() << "  Listening for NetworkManager property changes";

    // 2. Listen for WiFi device property changes (scan finished, active AP changed)
    m_systemBus.connect(
        NM::SERVICE,
        m_wirelessDevicePath,           // Path: /org/freedesktop/NetworkManager/Devices/X
        NM::PROPS_INTERFACE,
        NM::SIGNAL_PROPS_CHANGED,
        this,
        SLOT(onDevicePropertiesChanged(QString, QVariantMap, QStringList))
        );
    qDebug() << "  Listening for device property changes";

    // 3. Listen for new access points
    m_systemBus.connect(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::WIRELESS_INTERFACE,         // Interface: ...Device.Wireless
        NM::SIGNAL_AP_ADDED,            // Signal: AccessPointAdded
        this,
        SLOT(onAccessPointAdded(QDBusObjectPath))
        );
    qDebug() << "  Listening for new access points";

    // 4. Listen for removed access points
    m_systemBus.connect(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::WIRELESS_INTERFACE,
        NM::SIGNAL_AP_REMOVED,
        this,
        SLOT(onAccessPointRemoved(QDBusObjectPath))
        );
    qDebug() << "  Listening for removed access points";
}

// ============================================================================
// D-BUS SIGNAL HANDLERS
// ============================================================================

/*
 * Called when NetworkManager properties change
 *
 * We care about: WirelessEnabled
 * This fires when WiFi is toggled from system settings, another app, etc.
 */
void WiFiManager::onNMPropertiesChanged(QString interface,
                                        QVariantMap changedProperties,
                                        QStringList invalidatedProperties)
{
    Q_UNUSED(interface)
    Q_UNUSED(invalidatedProperties)

    // Check if WirelessEnabled changed
    if (changedProperties.contains(NM::PROP_WIRELESS_ENABLED)) {
        bool enabled = changedProperties[NM::PROP_WIRELESS_ENABLED].toBool();

        if (m_wifiEnabled != enabled) {
            m_wifiEnabled = enabled;
            qDebug() << "WiFi enabled changed (external):" << enabled;
            emit wifiEnabledChanged(enabled);

            // If WiFi was just enabled, load access points
            if (enabled) {
                loadInitialAccessPoints();
                scanNetworks();
            } else {
                // Clear the list when WiFi is disabled
                m_accessPointCache.clear();
                rebuildNetworksList();
            }
        }
    }
}

/*
 * Called when WiFi device properties change
 *
 * We care about:
 * - LastScan: indicates scan finished
 * - ActiveAccessPoint: indicates connection changed
 */
void WiFiManager::onDevicePropertiesChanged(QString interface,
                                            QVariantMap changedProperties,
                                            QStringList invalidatedProperties)
{
    Q_UNUSED(invalidatedProperties)

    // Only care about Wireless interface
    if (interface != NM::WIRELESS_INTERFACE) {
        return;
    }

    // Check if scan finished
    if (changedProperties.contains(NM::PROP_LAST_SCAN)) {
        if (m_isScanning) {
            m_isScanning = false;
            qDebug() << "Scan finished (detected via LastScan)";
            emit isScanningChanged(false);
        }
    }

    // Check if active connection changed
    if (changedProperties.contains(NM::PROP_ACTIVE_AP)) {
        qDebug() << "Active access point changed";
        updateActiveConnection();
        rebuildNetworksList();  // Update "connected" status in list
    }
}

/*
 * Called when a new access point is discovered
 */
void WiFiManager::onAccessPointAdded(QDBusObjectPath path)
{
    QString apPath = path.path();
    qDebug() << "Access point added:" << apPath;

    // Get info about this AP and add to cache
    QVariantMap info = getAccessPointInfo(apPath);
    if (!info.isEmpty()) {
        m_accessPointCache.insert(apPath, info);
        rebuildNetworksList();
    }
}

/*
 * Called when an access point disappears
 */
void WiFiManager::onAccessPointRemoved(QDBusObjectPath path)
{
    QString apPath = path.path();
    qDebug() << "Access point removed:" << apPath;

    // Remove from cache and rebuild list
    if (m_accessPointCache.remove(apPath) > 0) {
        rebuildNetworksList();
    }
}

// ============================================================================
// PROPERTY GETTERS & SETTERS
// ============================================================================

bool WiFiManager::getWifiEnabled() const
{
    return m_wifiEnabled;
}

bool WiFiManager::getIsScanning() const
{
    return m_isScanning;
}

QString WiFiManager::getConnectedNetwork() const
{
    return m_connectedNetwork;
}

QVariantList WiFiManager::getNetworks() const
{
    return m_networks;
}

void WiFiManager::setWifiEnabled(bool enabled)
{
    if (m_wifiEnabled == enabled) {
        return;
    }

    qDebug() << "Setting WiFi enabled to:" << enabled;

    // Set the property directly on the interface
    // This is simpler than going through Properties.Set()
    bool success = m_nmInterface->setProperty(NM::PROP_WIRELESS_ENABLED, enabled);

    if (!success) {
        qWarning() << "Failed to set WirelessEnabled";
        emit errorOccurred("Failed to toggle WiFi");
    }
    // Note: We don't update m_wifiEnabled here!
    // We wait for the PropertiesChanged signal to confirm the change
}

// ============================================================================
// SCANNING
// ============================================================================

void WiFiManager::scanNetworks()
{
    if (!m_wifiEnabled) {
        qDebug() << "Cannot scan: WiFi is disabled";
        return;
    }

    if (m_isScanning) {
        qDebug() << "Already scanning";
        return;
    }

    qDebug() << "Requesting WiFi scan...";
    m_isScanning = true;
    emit isScanningChanged(true);

    // Create interface to wireless device
    QDBusInterface wireless(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::WIRELESS_INTERFACE,
        m_systemBus
        );

    // Request scan with empty options
    wireless.call(NM::METHOD_REQUEST_SCAN, QVariantMap());

    // Note: We don't wait with a timer anymore!
    // The onDevicePropertiesChanged slot will be called when LastScan changes
}

void WiFiManager::loadInitialAccessPoints()
{
    qDebug() << "Loading initial access points...";

    QDBusInterface wireless(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::WIRELESS_INTERFACE,
        m_systemBus
        );

    QDBusReply<QList<QDBusObjectPath>> reply =
        wireless.call(NM::METHOD_GET_APS);

    if (!reply.isValid()) {
        qWarning() << "GetAccessPoints failed:" << reply.error().message();
        return;
    }

    // Clear cache and load all APs
    m_accessPointCache.clear();

    for (const QDBusObjectPath &apPath : reply.value()) {
        QVariantMap info = getAccessPointInfo(apPath.path());
        if (!info.isEmpty()) {
            m_accessPointCache.insert(apPath.path(), info);
        }
    }

    rebuildNetworksList();
    qDebug() << "Loaded" << m_accessPointCache.count() << "access points";
}

QVariantMap WiFiManager::getAccessPointInfo(const QString &apPath)
{
    QDBusInterface ap(
        NM::SERVICE,
        apPath,
        NM::AP_INTERFACE,
        m_systemBus
        );

    if (!ap.isValid()) {
        return QVariantMap();
    }

    // Get SSID (comes as byte array)
    QByteArray ssidBytes = ap.property("Ssid").toByteArray();
    QString ssid = QString::fromUtf8(ssidBytes);

    // Skip hidden networks
    if (ssid.isEmpty()) {
        return QVariantMap();
    }

    // Get other properties
    uint strength = ap.property("Strength").toUInt();
    uint frequency = ap.property("Frequency").toUInt();
    uint rsnFlags = ap.property("RsnFlags").toUInt();
    uint wpaFlags = ap.property("WpaFlags").toUInt();

    bool secured = (rsnFlags != 0 || wpaFlags != 0);
    bool connected = (ssid == m_connectedNetwork);

    return QVariantMap{
        {"ssid", ssid},
        {"strength", strength},
        {"frequency", frequency},
        {"secured", secured},
        {"connected", connected},
        {"path", apPath}
    };
}

/*
 * Rebuild the networks list from cache
 *
 * This is called whenever the cache changes. It:
 * 1. Clears the current list
 * 2. Adds all cached APs (skipping empty SSIDs)
 * 3. Sorts by signal strength (strongest first)
 * 4. Emits networksChanged signal
 */
void WiFiManager::rebuildNetworksList()
{
    m_networks.clear();

    // Use a map to deduplicate by SSID, keeping strongest signal
    QMap<QString, QVariantMap> uniqueNetworks;

    for (auto it = m_accessPointCache.begin(); it != m_accessPointCache.end(); ++it) {
        QVariantMap info = it.value();
        QString ssid = info["ssid"].toString();

        // Skip empty SSIDs (hidden networks)
        if (ssid.isEmpty()) {
            continue;
        }

        // Update connected status
        info["connected"] = (ssid == m_connectedNetwork);

        // Check if we already have this SSID
        if (uniqueNetworks.contains(ssid)) {
            // Keep the one with stronger signal
            int existingStrength = uniqueNetworks[ssid]["strength"].toInt();
            int newStrength = info["strength"].toInt();

            if (newStrength > existingStrength) {
                uniqueNetworks[ssid] = info;
            }
        } else {
            // First time seeing this SSID
            uniqueNetworks[ssid] = info;
        }
    }

    // Convert map to list
    for (const QVariantMap &network : uniqueNetworks) {
        m_networks.append(network);
    }

    // Sort by signal strength (descending)
    std::sort(m_networks.begin(), m_networks.end(),
              [](const QVariant &a, const QVariant &b) {
                  int strengthA = a.toMap()["strength"].toInt();
                  int strengthB = b.toMap()["strength"].toInt();
                  return strengthA > strengthB;
              });

    qDebug() << "Networks list rebuilt:" << m_networks.count() << "unique networks";
    emit networksChanged();
}

// ============================================================================
// CONNECTION STATUS
// ============================================================================

void WiFiManager::updateActiveConnection()
{
    QDBusInterface wireless(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::WIRELESS_INTERFACE,
        m_systemBus
        );

    // Get ActiveAccessPoint property
    QVariant activeApVariant = wireless.property(NM::PROP_ACTIVE_AP);
    QDBusObjectPath activeApPath = qvariant_cast<QDBusObjectPath>(activeApVariant);

    QString oldConnected = m_connectedNetwork;

    // Check if there's an active AP
    if (activeApPath.path().isEmpty() || activeApPath.path() == "/") {
        m_connectedNetwork.clear();
    } else {
        // Get the SSID of the active AP
        QDBusInterface ap(
            NM::SERVICE,
            activeApPath.path(),
            NM::AP_INTERFACE,
            m_systemBus
            );

        QByteArray ssidBytes = ap.property("Ssid").toByteArray();
        m_connectedNetwork = QString::fromUtf8(ssidBytes);
    }

    // Emit signal if changed
    if (oldConnected != m_connectedNetwork) {
        qDebug() << "Connected network changed:" << m_connectedNetwork;
        emit connectedNetworkChanged(m_connectedNetwork);
    }
}

// ============================================================================
// CONNECT TO NETWORK
// ============================================================================

void WiFiManager::connectToNetwork(const QString &ssid, const QString &password)
{
    qDebug() << "Connecting to network:" << ssid;

    // Find the AP path from cache
    QString apPath;
    for (auto it = m_accessPointCache.begin(); it != m_accessPointCache.end(); ++it) {
        if (it.value()["ssid"].toString() == ssid) {
            apPath = it.key();
            break;
        }
    }

    if (apPath.isEmpty()) {
        qWarning() << "Cannot find AP for SSID:" << ssid;
        emit connectionFailed("Network not found");
        return;
    }

    // Check if a saved connection exists for this SSID
    QString savedConnectionPath = findSavedConnection(ssid);

    if (!savedConnectionPath.isEmpty()) {
        // Activate existing saved connection
        qDebug() << "Found saved connection, activating...";

        QDBusReply<QDBusObjectPath> reply = m_nmInterface->call(
            NM::METHOD_ACTIVATE_CONNECTION,
            QVariant::fromValue(QDBusObjectPath(savedConnectionPath)),
            QVariant::fromValue(QDBusObjectPath(m_wirelessDevicePath)),
            QVariant::fromValue(QDBusObjectPath("/"))  // Let NM pick the AP
            );

        if (!reply.isValid()) {
            qWarning() << "ActivateConnection failed:" << reply.error().message();
            emit connectionFailed(reply.error().message());
        } else {
            qDebug() << "Connection activated:" << reply.value().path();
            emit connectionSuccess(ssid);
        }
        return;
    }

    // No saved connection - create a new one
    qDebug() << "Creating new connection...";

    // Build connection settings
    QMap<QString, QVariantMap> connectionSettings;

    connectionSettings["connection"] = {
        {"id", ssid},
        {"type", QString("802-11-wireless")}
    };

    connectionSettings["802-11-wireless"] = {
        {"ssid", ssid.toUtf8()},
        {"mode", QString("infrastructure")}
    };

    // Add security settings if password provided
    if (!password.isEmpty()) {
        connectionSettings["802-11-wireless-security"] = {
            {"key-mgmt", QString("wpa-psk")},
            {"psk", password}
        };
    }

    // IPv4/IPv6 settings
    connectionSettings["ipv4"] = {{"method", QString("auto")}};
    connectionSettings["ipv6"] = {{"method", QString("ignore")}};

    // Convert to QVariantMap for D-Bus
    QVariantMap settingsMap;
    for (auto it = connectionSettings.begin(); it != connectionSettings.end(); ++it) {
        settingsMap.insert(it.key(), QVariant::fromValue(it.value()));
    }

    // Call AddAndActivateConnection
    QDBusReply<QDBusObjectPath> reply = m_nmInterface->call(
        NM::METHOD_ADD_AND_ACTIVATE,
        QVariant::fromValue(settingsMap),
        QVariant::fromValue(QDBusObjectPath(m_wirelessDevicePath)),
        QVariant::fromValue(QDBusObjectPath(apPath))
        );

    if (!reply.isValid()) {
        qWarning() << "AddAndActivateConnection failed:" << reply.error().message();
        emit connectionFailed(reply.error().message());
    } else {
        qDebug() << "Connection created and activating:" << reply.value().path();
        emit connectionSuccess(ssid);
    }
}

QString WiFiManager::findSavedConnection(const QString &ssid)
{
    QDBusInterface settings(
        NM::SERVICE,
        NM::SETTINGS_PATH,
        NM::SETTINGS_INTERFACE,
        m_systemBus
        );

    QDBusReply<QList<QDBusObjectPath>> reply =
        settings.call(NM::METHOD_LIST_CONNECTIONS);

    if (!reply.isValid()) {
        qWarning() << "ListConnections failed:" << reply.error().message();
        return QString();
    }

    // Check each saved connection
    for (const QDBusObjectPath &connPath : reply.value()) {
        QDBusInterface conn(
            NM::SERVICE,
            connPath.path(),
            NM::CONNECTION_INTERFACE,
            m_systemBus
            );

        QDBusReply<QMap<QString, QVariantMap>> settingsReply =
            conn.call(NM::METHOD_GET_SETTINGS);

        if (!settingsReply.isValid()) {
            continue;
        }

        QMap<QString, QVariantMap> connSettings = settingsReply.value();

        // Check for matching SSID in 802-11-wireless section
        if (connSettings.contains("802-11-wireless")) {
            QByteArray savedSsid =
                connSettings["802-11-wireless"].value("ssid").toByteArray();

            if (QString::fromUtf8(savedSsid) == ssid) {
                qDebug() << "Found saved connection for" << ssid << "at" << connPath.path();
                return connPath.path();
            }
        }
    }

    return QString();
}

// ============================================================================
// DISCONNECT
// ============================================================================

void WiFiManager::disconnectFromNetwork()
{
    qDebug() << "Disconnecting from network...";

    // Get active connection on our device
    QDBusInterface device(
        NM::SERVICE,
        m_wirelessDevicePath,
        NM::DEVICE_INTERFACE,
        m_systemBus
        );

    QVariant activeConnVariant = device.property(NM::PROP_ACTIVE_CONN);
    QDBusObjectPath activeConnPath = qvariant_cast<QDBusObjectPath>(activeConnVariant);

    if (activeConnPath.path().isEmpty() || activeConnPath.path() == "/") {
        qDebug() << "No active connection to disconnect";
        emit errorOccurred("Not connected to any network");
        return;
    }

    // Deactivate the connection
    QDBusReply<void> reply = m_nmInterface->call(
        NM::METHOD_DEACTIVATE_CONNECTION,
        QVariant::fromValue(activeConnPath)
        );

    if (!reply.isValid()) {
        qWarning() << "DeactivateConnection failed:" << reply.error().message();
        emit errorOccurred("Failed to disconnect: " + reply.error().message());
    } else {
        qDebug() << "Disconnected successfully";
        emit disconnected();
        // Note: m_connectedNetwork will be updated via the PropertiesChanged signal
    }
}
