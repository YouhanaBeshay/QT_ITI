#include "gpiocontroller.h"

GpioController::GpioController(const QString& name, int pinNumber,QObject* parent)
    : QObject(parent)
    , name_(name)
    , pinNumber_(pinNumber)
{
    // Initialize pin 17 as output, starting LOW
    pin_ = std::make_unique<mcal::gpio::GPIO>(
        static_cast<mcal::gpio::Gpio_Pin_t>(pinNumber_+ 512), // will not use my enums directly to be able to use normal numbers in the list
        mcal::gpio::Gpio_Direction_t::OUTPUT,
        mcal::gpio::Gpio_Value_t::LOW
        );
}

void GpioController::turnOn() {
    pin_->SetPin(mcal::gpio::Gpio_Value_t::HIGH);
    ledState_ = true;
    emit ledOnChanged();
}

void GpioController::turnOff() {
    pin_->SetPin(mcal::gpio::Gpio_Value_t::LOW);
    ledState_ = false;
    emit ledOnChanged();
}

void GpioController::toggle() {
    ledState_ ? turnOff() : turnOn();
}
