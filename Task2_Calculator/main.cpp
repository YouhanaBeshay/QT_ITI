#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "calcbackend.h"

#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    CalcBackEnd mycalcBackEnd;
    engine.rootContext()->setContextProperty("calcBackend", &mycalcBackEnd);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Task2_Calculator", "Main");

    return app.exec();
}
