#pragma once
namespace mcal {
namespace gpio {

enum class Gpio_Direction_t {
  INPUT = 0,
  OUTPUT = 1,
};

enum class Gpio_Value_t {
  LOW = 0,
  HIGH = 1,
};

// Gpio pins shifted by 512
enum class Gpio_Pin_t {
  GPIO_0 = 512,
  GPIO_1 = 513,
  GPIO_2 = 514,
  GPIO_3 = 515,
  GPIO_4 = 516,
  GPIO_5 = 517,
  GPIO_6 = 518,
  GPIO_7 = 519,
  GPIO_8 = 520,
  GPIO_9 = 521,
  GPIO_10 = 522,
  GPIO_11 = 523,
  GPIO_12 = 524,
  GPIO_13 = 525,
  GPIO_14 = 526,
  GPIO_15 = 527,
  GPIO_16 = 528,
  GPIO_17 = 529,
  GPIO_18 = 530,
  GPIO_19 = 531,
  GPIO_20 = 532,
  GPIO_21 = 533,
  GPIO_22 = 534,
  GPIO_23 = 535,
  GPIO_24 = 536,
  GPIO_25 = 537,
  GPIO_26 = 538,
  GPIO_27 = 539,
};

class GPIO {
private:
  // the class stores intger pin number but the user must pass it as enum class
  // (to avoid multiple casting in the constructors)
  int PinNumber_;

  // File Descriptors
  int FdExport_;
  int FdDirection_ = -1;
  int FdValue_ = -1;

  // Private helper functions
  void OpenExportFile(int PinNumber);
  void OpenDirectionFile(int PinNumber);
  void OpenValueFile(int PinNumber);

public:
  // Construstors
  GPIO(Gpio_Pin_t PinNumber);
  GPIO(Gpio_Pin_t PinNumber, Gpio_Direction_t Direction);
  GPIO(Gpio_Pin_t PinNumber, Gpio_Direction_t Direction, Gpio_Value_t Value);

  // No Copy Constructors
  GPIO(const GPIO &obj) = delete;
  GPIO &operator=(const GPIO &obj) = delete;

  // Move Contsructors
  // TODO: ask wether we should use move constructors or not
  GPIO(GPIO &&obj) = delete;
  GPIO &operator=(GPIO &&obj) = delete;

  // Destructor
  ~GPIO();

  // APIs
  void SetDirection(Gpio_Direction_t Direction);
  void SetPin(Gpio_Value_t Value);
  int GetPinNumber();
  int GetPinValue();
};

} // namespace gpio
}; // namespace mcal