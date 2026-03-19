#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QVariantList>
#include "src/gpiocontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    GpioController redLed   ("Error LED",    26);
    GpioController yellowLed("Warning LED", 19);
    GpioController greenLed ("OK LED",  13);

    // the listmodel that will be used on the qml
    QVariantList leds = {
        QVariant::fromValue(&redLed),
        QVariant::fromValue(&yellowLed),
        QVariant::fromValue(&greenLed)
    };

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // expose the listmodel to the qml
    engine.rootContext()->setContextProperty("ledModel", leds);

    engine.loadFromModule("Task4_RpiLED", "Main");

    return app.exec();
}
