// src/bluetoothmanager.cpp
#include "bluetoothmanager.h"

#include <QDBusReply>
#include <QDBusArgument>
#include <QDBusMetaType>
#include <QDBusPendingCall>
#include <QDBusPendingReply>
#include <QDebug>
#include <algorithm>

namespace Bluez {
constexpr const char* SERVICE = "org.bluez";
constexpr const char* MANAGER_PATH = "/";

constexpr const char* ADAPTER_INTERFACE = "org.bluez.Adapter1";
constexpr const char* DEVICE_INTERFACE = "org.bluez.Device1";
constexpr const char* OBJECT_MANAGER_INTERFACE = "org.freedesktop.DBus.ObjectManager";
constexpr const char* PROPS_INTERFACE = "org.freedesktop.DBus.Properties";

constexpr const char* PROP_POWERED = "Powered";
constexpr const char* PROP_DISCOVERING = "Discovering";
constexpr const char* PROP_CONNECTED = "Connected";
constexpr const char* PROP_PAIRED = "Paired";
constexpr const char* PROP_NAME = "Name";
constexpr const char* PROP_ALIAS = "Alias";
constexpr const char* PROP_ADDRESS = "Address";
constexpr const char* PROP_ICON = "Icon";
constexpr const char* PROP_RSSI = "RSSI";

constexpr const char* SIGNAL_PROPS_CHANGED = "PropertiesChanged";
constexpr const char* SIGNAL_INTERFACES_ADDED = "InterfacesAdded";
constexpr const char* SIGNAL_INTERFACES_REMOVED = "InterfacesRemoved";

constexpr const char* METHOD_GET_MANAGED_OBJECTS = "GetManagedObjects";
constexpr const char* METHOD_CONNECT = "Connect";
constexpr const char* METHOD_DISCONNECT = "Disconnect";
constexpr const char* METHOD_PAIR = "Pair";
constexpr const char* METHOD_REMOVE_DEVICE = "RemoveDevice";
}

// ============================================================================
// CONSTRUCTOR & DESTRUCTOR
// ============================================================================

BluetoothManager::BluetoothManager(QObject *parent)
    : QObject(parent)
    , m_bluetoothEnabled(false)
    , m_isDiscovering(false)
    , m_systemBus(QDBusConnection::systemBus())
    , m_adapterInterface(nullptr)
{
    qDebug() << "BluetoothManager: Initializing...";

    // Register D-Bus types
    qDBusRegisterMetaType<QMap<QString, QVariantMap>>();
    qDBusRegisterMetaType<QMap<QDBusObjectPath, QMap<QString, QVariantMap>>>();

    if (!initializeDBus()) {
        qWarning() << "BluetoothManager: Initialization failed!";
        return;
    }

    connectToDBusSignals();
    loadDevices();

    qDebug() << "BluetoothManager: Ready!";
    qDebug() << "  Bluetooth enabled:" << m_bluetoothEnabled;
    qDebug() << "  Discovering:" << m_isDiscovering;
    qDebug() << "  Devices found:" << m_devices.count();
}

BluetoothManager::~BluetoothManager()
{
    delete m_adapterInterface;
}

// ============================================================================
// INITIALIZATION
// ============================================================================

bool BluetoothManager::initializeDBus()
{
    if (!m_systemBus.isConnected()) {
        qWarning() << "Cannot connect to D-Bus system bus";
        emit errorOccurred("Cannot connect to system bus");
        return false;
    }
    qDebug() << "  Connected to D-Bus";

    m_adapterPath = findAdapter();
    if (m_adapterPath.isEmpty()) {
        qWarning() << "No Bluetooth adapter found";
        emit errorOccurred("No Bluetooth adapter found");
        return false;
    }
    qDebug() << "  Adapter found:" << m_adapterPath;

    m_adapterInterface = new QDBusInterface(
        Bluez::SERVICE,
        m_adapterPath,
        Bluez::ADAPTER_INTERFACE,
        m_systemBus,
        this
        );

    if (!m_adapterInterface->isValid()) {
        qWarning() << "Adapter interface invalid";
        emit errorOccurred("Cannot access Bluetooth adapter");
        return false;
    }
    qDebug() << "  Adapter interface OK";

    // Get initial state
    m_bluetoothEnabled = m_adapterInterface->property(Bluez::PROP_POWERED).toBool();
    m_isDiscovering = m_adapterInterface->property(Bluez::PROP_DISCOVERING).toBool();

    return true;
}

QString BluetoothManager::findAdapter()
{
    QDBusInterface manager(
        Bluez::SERVICE,
        Bluez::MANAGER_PATH,
        Bluez::OBJECT_MANAGER_INTERFACE,
        m_systemBus
        );

    QDBusReply<QMap<QDBusObjectPath, QMap<QString, QVariantMap>>> reply =
        manager.call(Bluez::METHOD_GET_MANAGED_OBJECTS);

    if (!reply.isValid()) {
        qWarning() << "GetManagedObjects failed:" << reply.error().message();
        return QString();
    }

    QMap<QDBusObjectPath, QMap<QString, QVariantMap>> objects = reply.value();

    for (auto it = objects.begin(); it != objects.end(); ++it) {
        if (it.value().contains(Bluez::ADAPTER_INTERFACE)) {
            return it.key().path();
        }
    }

    return QString();
}

void BluetoothManager::connectToDBusSignals()
{
    // Listen for adapter property changes
    m_systemBus.connect(
        Bluez::SERVICE,
        m_adapterPath,
        Bluez::PROPS_INTERFACE,
        Bluez::SIGNAL_PROPS_CHANGED,
        this,
        SLOT(onAdapterPropertiesChanged(QString, QVariantMap, QStringList))
        );
    qDebug() << "  Listening for adapter changes";

    // Listen for new devices
    m_systemBus.connect(
        Bluez::SERVICE,
        Bluez::MANAGER_PATH,
        Bluez::OBJECT_MANAGER_INTERFACE,
        Bluez::SIGNAL_INTERFACES_ADDED,
        this,
        SLOT(onInterfacesAdded(QDBusObjectPath, QMap<QString,QVariantMap>))
        );
    qDebug() << "  Listening for new devices";

    // Listen for removed devices
    m_systemBus.connect(
        Bluez::SERVICE,
        Bluez::MANAGER_PATH,
        Bluez::OBJECT_MANAGER_INTERFACE,
        Bluez::SIGNAL_INTERFACES_REMOVED,
        this,
        SLOT(onInterfacesRemoved(QDBusObjectPath, QStringList))
        );
    qDebug() << "  Listening for removed devices";
}

// ============================================================================
// D-BUS SIGNAL HANDLERS
// ============================================================================

void BluetoothManager::onAdapterPropertiesChanged(QString interface,
                                                  QVariantMap changedProperties,
                                                  QStringList invalidatedProperties)
{
    Q_UNUSED(invalidatedProperties)

    if (interface != Bluez::ADAPTER_INTERFACE) {
        return;
    }

    // Check Powered
    if (changedProperties.contains(Bluez::PROP_POWERED)) {
        bool enabled = changedProperties[Bluez::PROP_POWERED].toBool();
        if (m_bluetoothEnabled != enabled) {
            m_bluetoothEnabled = enabled;
            qDebug() << "Bluetooth enabled changed:" << enabled;
            emit bluetoothEnabledChanged(enabled);

            if (enabled) {
                loadDevices();
            } else {
                m_deviceCache.clear();
                rebuildDevicesList();
            }
        }
    }

    // Check Discovering (just reflect the state, we don't control it)
    if (changedProperties.contains(Bluez::PROP_DISCOVERING)) {
        bool discovering = changedProperties[Bluez::PROP_DISCOVERING].toBool();
        if (m_isDiscovering != discovering) {
            m_isDiscovering = discovering;
            qDebug() << "Discovering changed:" << discovering;
            emit isDiscoveringChanged(discovering);
        }
    }
}

void BluetoothManager::onInterfacesAdded(QDBusObjectPath path,
                                         QMap<QString, QVariantMap> interfaces)
{
    QString devicePath = path.path();

    if (!interfaces.contains(Bluez::DEVICE_INTERFACE)) {
        return;
    }

    qDebug() << "Device added:" << devicePath;

    QVariantMap info = getDeviceInfo(devicePath);
    if (!info.isEmpty()) {
        m_deviceCache.insert(devicePath, info);

        // Listen for this device's property changes
        m_systemBus.connect(
            Bluez::SERVICE,
            devicePath,
            Bluez::PROPS_INTERFACE,
            Bluez::SIGNAL_PROPS_CHANGED,
            this,
            SLOT(onDevicePropertiesChanged(QString, QVariantMap, QStringList))
            );

        rebuildDevicesList();
    }
}

void BluetoothManager::onInterfacesRemoved(QDBusObjectPath path,
                                           QStringList interfaces)
{
    QString devicePath = path.path();

    if (!interfaces.contains(Bluez::DEVICE_INTERFACE)) {
        return;
    }

    qDebug() << "Device removed:" << devicePath;

    if (m_deviceCache.remove(devicePath) > 0) {
        rebuildDevicesList();
    }
}

void BluetoothManager::onDevicePropertiesChanged(QString interface,
                                                 QVariantMap changedProperties,
                                                 QStringList invalidatedProperties)
{
    Q_UNUSED(invalidatedProperties)

    if (interface != Bluez::DEVICE_INTERFACE) {
        return;
    }

    qDebug() << "Device properties changed:" << changedProperties.keys();

    // Check for connection state change
    if (changedProperties.contains(Bluez::PROP_CONNECTED)) {
        bool connected = changedProperties[Bluez::PROP_CONNECTED].toBool();

        // Find device name from cache (we'll update after refresh)
        QString deviceName = "Unknown device";

        if (connected) {
            qDebug() << "A device connected";
            emit deviceConnected(deviceName);
        } else {
            qDebug() << "A device disconnected";
            emit deviceDisconnected(deviceName);
        }
    }

    // Check for pairing state change
    if (changedProperties.contains(Bluez::PROP_PAIRED)) {
        bool paired = changedProperties[Bluez::PROP_PAIRED].toBool();
        if (paired) {
            qDebug() << "A device was paired";
            emit devicePaired("Unknown device");
        }
    }

    // Refresh device list on any relevant change
    if (changedProperties.contains(Bluez::PROP_CONNECTED) ||
        changedProperties.contains(Bluez::PROP_PAIRED) ||
        changedProperties.contains(Bluez::PROP_NAME)) {

        loadDevices();
    }
}

// ============================================================================
// PROPERTY GETTERS & SETTERS
// ============================================================================

bool BluetoothManager::getBluetoothEnabled() const
{
    return m_bluetoothEnabled;
}

bool BluetoothManager::getIsDiscovering() const
{
    return m_isDiscovering;
}

QVariantList BluetoothManager::getDevices() const
{
    return m_devices;
}

bool BluetoothManager::getIsConnecting() const
{
    return m_isConnecting;
}

void BluetoothManager::setBluetoothEnabled(bool enabled)
{
    if (m_bluetoothEnabled == enabled) {
        return;
    }

    qDebug() << "Setting Bluetooth enabled to:" << enabled;

    bool success = m_adapterInterface->setProperty(Bluez::PROP_POWERED, enabled);

    if (!success) {
        qWarning() << "Failed to set Powered property";
        emit errorOccurred("Failed to toggle Bluetooth");
    }
}

// ============================================================================
// REFRESH DEVICES
// ============================================================================

void BluetoothManager::refreshDevices()
{
    qDebug() << "Refreshing device list...";
    loadDevices();
}

void BluetoothManager::loadDevices()
{
    if (!m_bluetoothEnabled) {
        qDebug() << "Bluetooth disabled, skipping device load";
        m_deviceCache.clear();
        rebuildDevicesList();
        return;
    }

    qDebug() << "Loading devices...";

    QDBusInterface manager(
        Bluez::SERVICE,
        Bluez::MANAGER_PATH,
        Bluez::OBJECT_MANAGER_INTERFACE,
        m_systemBus
        );

    QDBusReply<QMap<QDBusObjectPath, QMap<QString, QVariantMap>>> reply =
        manager.call(Bluez::METHOD_GET_MANAGED_OBJECTS);

    if (!reply.isValid()) {
        qWarning() << "GetManagedObjects failed:" << reply.error().message();
        return;
    }

    m_deviceCache.clear();

    QMap<QDBusObjectPath, QMap<QString, QVariantMap>> objects = reply.value();

    for (auto it = objects.begin(); it != objects.end(); ++it) {
        QString path = it.key().path();
        QMap<QString, QVariantMap> interfaces = it.value();

        if (!interfaces.contains(Bluez::DEVICE_INTERFACE)) {
            continue;
        }

        QVariantMap info = getDeviceInfo(path);
        if (!info.isEmpty()) {
            m_deviceCache.insert(path, info);

            // Connect to this device's property changes
            m_systemBus.connect(
                Bluez::SERVICE,
                path,
                Bluez::PROPS_INTERFACE,
                Bluez::SIGNAL_PROPS_CHANGED,
                this,
                SLOT(onDevicePropertiesChanged(QString, QVariantMap, QStringList))
                );
        }
    }

    rebuildDevicesList();
    qDebug() << "Loaded" << m_deviceCache.count() << "devices";
}

QVariantMap BluetoothManager::getDeviceInfo(const QString &devicePath)
{
    QDBusInterface device(
        Bluez::SERVICE,
        devicePath,
        Bluez::DEVICE_INTERFACE,
        m_systemBus
        );

    if (!device.isValid()) {
        return QVariantMap();
    }

    QString name = device.property(Bluez::PROP_ALIAS).toString();
    if (name.isEmpty()) {
        name = device.property(Bluez::PROP_NAME).toString();
    }
    if (name.isEmpty()) {
        name = device.property(Bluez::PROP_ADDRESS).toString();
    }

    QString address = device.property(Bluez::PROP_ADDRESS).toString();
    QString icon = device.property(Bluez::PROP_ICON).toString();
    bool paired = device.property(Bluez::PROP_PAIRED).toBool();
    bool connected = device.property(Bluez::PROP_CONNECTED).toBool();
    int rssi = device.property(Bluez::PROP_RSSI).toInt();

    return QVariantMap{
        {"name", name},
        {"address", address},
        {"icon", icon},
        {"paired", paired},
        {"connected", connected},
        {"rssi", rssi},
        {"path", devicePath}
    };
}

void BluetoothManager::rebuildDevicesList()
{
    m_devices.clear();

    for (const QVariantMap &device : m_deviceCache) {
        QString name = device["name"].toString();
        if (!name.isEmpty()) {
            m_devices.append(device);
        }
    }

    // Sort: connected first, then paired, then by name
    std::sort(m_devices.begin(), m_devices.end(),
              [](const QVariant &a, const QVariant &b) {
                  QVariantMap mapA = a.toMap();
                  QVariantMap mapB = b.toMap();

                  bool connA = mapA["connected"].toBool();
                  bool connB = mapB["connected"].toBool();
                  if (connA != connB) return connA > connB;

                  bool pairA = mapA["paired"].toBool();
                  bool pairB = mapB["paired"].toBool();
                  if (pairA != pairB) return pairA > pairB;

                  return mapA["name"].toString() < mapB["name"].toString();
              });

    qDebug() << "Device list rebuilt:" << m_devices.count() << "devices";
    emit devicesChanged();
}

QString BluetoothManager::addressToPath(const QString &address)
{
    QString pathAddress = address;
    pathAddress.replace(":", "_");
    return m_adapterPath + "/dev_" + pathAddress;
}

// ============================================================================
// CONNECT / DISCONNECT / PAIR / REMOVE
// ============================================================================

void BluetoothManager::connectToDevice(const QString &address)
{
    qDebug() << "Connecting to device:" << address;


    m_isConnecting = true;
    emit isConnectingChanged(true);

    QString devicePath = addressToPath(address);

    QDBusInterface *device = new QDBusInterface(
        Bluez::SERVICE,
        devicePath,
        Bluez::DEVICE_INTERFACE,
        m_systemBus,
        this  // Parent for automatic cleanup
        );

    if (!device->isValid()) {
        qWarning() << "Device interface invalid";
        emit errorOccurred("Cannot find device");
        delete device;
        return;
    }

    // Async call
    QDBusPendingCall pendingCall = device->asyncCall(Bluez::METHOD_CONNECT);

    // Watch for completion
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, device, address](QDBusPendingCallWatcher *w) {
                m_isConnecting = false;
                emit isConnectingChanged(false);
                QDBusPendingReply<> reply = *w;

                if (reply.isError()) {
                    qWarning() << "Connect failed:" << reply.error().message();
                    emit errorOccurred("Connection failed: " + reply.error().message());
                } else {
                    qDebug() << "Connect call completed for:" << address;
                    // Success will be confirmed via PropertiesChanged signal
                    refreshDevices();
                }

                // Cleanup
                w->deleteLater();
                device->deleteLater();
            });
}

void BluetoothManager::disconnectFromDevice(const QString &address)
{
    qDebug() << "Disconnecting from device:" << address;

    QString devicePath = addressToPath(address);

    QDBusInterface *device = new QDBusInterface(
        Bluez::SERVICE,
        devicePath,
        Bluez::DEVICE_INTERFACE,
        m_systemBus,
        this
        );

    if (!device->isValid()) {
        qWarning() << "Device interface invalid";
        emit errorOccurred("Cannot find device");
        delete device;
        return;
    }

    QDBusPendingCall pendingCall = device->asyncCall(Bluez::METHOD_DISCONNECT);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, device](QDBusPendingCallWatcher *w) {

                QDBusPendingReply<> reply = *w;

                if (reply.isError()) {
                    qWarning() << "Disconnect failed:" << reply.error().message();
                    emit errorOccurred("Disconnect failed: " + reply.error().message());
                }
                refreshDevices();
                w->deleteLater();
                device->deleteLater();
            });
}

void BluetoothManager::pairDevice(const QString &address)
{
    qDebug() << "Pairing with device:" << address;

    QString devicePath = addressToPath(address);

    QDBusInterface *device = new QDBusInterface(
        Bluez::SERVICE,
        devicePath,
        Bluez::DEVICE_INTERFACE,
        m_systemBus,
        this
        );

    if (!device->isValid()) {
        qWarning() << "Device interface invalid";
        emit errorOccurred("Cannot find device");
        delete device;
        return;
    }

    QDBusPendingCall pendingCall = device->asyncCall(Bluez::METHOD_PAIR);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, device](QDBusPendingCallWatcher *w) {

                QDBusPendingReply<> reply = *w;

                if (reply.isError()) {
                    qWarning() << "Pair failed:" << reply.error().message();
                    emit errorOccurred("Pairing failed: " + reply.error().message());
                }
                refreshDevices();
                w->deleteLater();
                device->deleteLater();
            });
}

void BluetoothManager::removeDevice(const QString &address)
{
    qDebug() << "Removing device:" << address;

    QString devicePath = addressToPath(address);

    QDBusPendingCall pendingCall = m_adapterInterface->asyncCall(
        Bluez::METHOD_REMOVE_DEVICE,
        QVariant::fromValue(QDBusObjectPath(devicePath))
        );

    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher *w) {

                QDBusPendingReply<> reply = *w;

                if (reply.isError()) {
                    qWarning() << "RemoveDevice failed:" << reply.error().message();
                    emit errorOccurred("Remove failed: " + reply.error().message());
                }
                refreshDevices();
                w->deleteLater();
            });
}
