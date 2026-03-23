#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard")); // Set the IM module
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Task6_MultiMediaApp", "Main");

    return app.exec();
}
