#ifndef GPIOCONTROLLER_H
#define GPIOCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <mygpio.hpp>

class GpioController : public QObject
{
    Q_OBJECT


    Q_PROPERTY(bool ledOn READ ledOn  NOTIFY ledOnChanged )


    Q_PROPERTY(int pinNumber READ pinNumber CONSTANT)

    // just to give a name to be used in the listview
    Q_PROPERTY(QString name READ name CONSTANT)

public:
    explicit GpioController(const QString& name, int pinNumber, QObject *parent = nullptr);
    ~GpioController() = default;

    // getter
    bool ledOn() const { return ledState_; }
    QString name()      const { return name_; }
    int     pinNumber() const { return pinNumber_; }

public slots:
        Q_INVOKABLE void turnOn();
        Q_INVOKABLE void turnOff();
        Q_INVOKABLE void toggle();


    signals:

        void ledOnChanged();


private:
    std::unique_ptr<mcal::gpio::GPIO> pin_;
    bool ledState_ = false;
    QString name_;
    int     pinNumber_;

 };

#endif // GPIOCONTROLLER_H
