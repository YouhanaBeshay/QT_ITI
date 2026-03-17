#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "src/wifimanager.h"
#include "src/bluetoothmanager.h"

int main(int argc, char *argv[])
{
    qputenv("QT_QPA_PLATFORM", "xcb");
    QGuiApplication app(argc, argv);


    QQmlApplicationEngine engine;

    // Create classes instances
    WiFiManager wifiManager;
    BluetoothManager bluetoothManager;

    // Expose to QML as a context property
    // Now QML can access it as "wifiManager"
    engine.rootContext()->setContextProperty("wifiManager", &wifiManager);
    engine.rootContext()->setContextProperty("bluetoothManager", &bluetoothManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Task3_NetworkManager", "Main");

    return app.exec();
}
