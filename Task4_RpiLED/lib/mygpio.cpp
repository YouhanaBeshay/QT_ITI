#include "mygpio.hpp"

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <string>
// #include <iostream>

// TODO: Ask how to hanle errors (errot_status vs perror)
namespace mcal {
namespace gpio {

//==== Private helper functions ===

void GPIO::OpenExportFile(int PinNumber) {
  std::string exportPath = "/sys/class/gpio/export";
  std::string PinNumberString = std::to_string(PinNumber);
  FdExport_ = open(exportPath.c_str(), O_WRONLY);
  write(FdExport_, PinNumberString.c_str(), PinNumberString.size());
  close(FdExport_); // Close the export file (we will open 1 gpio pin for object
                    // so no need for it anymore)

  //  wait for kernel to export the pin
  usleep(100000);
}
void GPIO::OpenDirectionFile(int PinNumber) {
  std::string PinNumberString = std::to_string(PinNumber);
  std::string directionPath =
      "/sys/class/gpio/gpio" + PinNumberString + "/direction";
  FdDirection_ = open(directionPath.c_str(), O_RDWR);
}

void GPIO::OpenValueFile(int PinNumber) {
  std::string PinNumberString = std::to_string(PinNumber);
  std::string valuePath = "/sys/class/gpio/gpio" + PinNumberString + "/value";
  FdValue_ = open(valuePath.c_str(), O_RDWR);
}

//=== Construstors ===

GPIO::GPIO(Gpio_Pin_t PinNumber) {
  PinNumber_ = static_cast<int>(PinNumber);
  // Open the export file
  OpenExportFile(PinNumber_);
}

GPIO::GPIO(Gpio_Pin_t PinNumber, Gpio_Direction_t Direction) {
  PinNumber_ = static_cast<int>(PinNumber);

  // Open the export file
  OpenExportFile(PinNumber_);

  // Open the direction file
  OpenDirectionFile(PinNumber_);
  // Assign the direction
  SetDirection(Direction);
}
GPIO::GPIO(Gpio_Pin_t PinNumber, Gpio_Direction_t Direction,
           Gpio_Value_t Value) {

  PinNumber_ = static_cast<int>(PinNumber);
  // Open the export file
  OpenExportFile(PinNumber_);

  // Open the direction file
  OpenDirectionFile(PinNumber_);
  // Assign the direction
  SetDirection(Direction);

  // Open the Value file
  OpenValueFile(PinNumber_);
  // Assign the value
  SetPin(Value);
}

//=== Move Contsructors ===
// GPIO::GPIO(GPIO &&obj) {}
// GPIO &GPIO::operator=(GPIO &&obj) {}

//=== Destructor ===
GPIO::~GPIO() {
  close(FdDirection_);
  close(FdValue_);

  // Unexport the pin (so we dont need to manually unexport it after program)
  int fdUnexport = open("/sys/class/gpio/unexport", O_WRONLY);
  if (fdUnexport != -1) {
    std::string pinStr = std::to_string(PinNumber_);
    write(fdUnexport, pinStr.c_str(), pinStr.size());
    close(fdUnexport);
  }
}

//=== APIs ===
void GPIO::SetDirection(Gpio_Direction_t Direction) {
  // try to open file descriptor if not opened before
  if (FdDirection_ == -1) {
    OpenDirectionFile(PinNumber_);
  }
  // return to start of file
  lseek(FdDirection_, 0, SEEK_SET);
  // assign the direction
  if (Direction == Gpio_Direction_t::INPUT) {
    write(FdDirection_, "in", 2);
  } else {
    write(FdDirection_, "out", 3);
  }
}
void GPIO::SetPin(Gpio_Value_t Value) {

  // try to open file descriptor if not opened before
  if (FdValue_ == -1) {
    OpenValueFile(PinNumber_);
  }
  // return to start of file
  lseek(FdValue_, 0, SEEK_SET);
  // assign the vlaue
  if (Value == Gpio_Value_t::LOW) {
    write(FdValue_, "0", 1);
  } else {
    write(FdValue_, "1", 1);
  }
}

int GPIO::GetPinNumber() { return PinNumber_ - 512; }

int GPIO::GetPinValue() {
  // if no value file opened return -1
  int Ret = -1;

  if (FdValue_ != -1) {
    // return to start of file
    lseek(FdValue_, 0, SEEK_SET);
    // read the value
    char Value;
    int BytesRead = read(FdValue_, &Value, sizeof(Value));
    if (BytesRead == 1) {
      // check the value
      if (Value == '1') {
        Ret = 1;
      } else if (Value == '0') {
        Ret = 0;
      }
    }
  }

  return Ret;
}

} // namespace gpio
}; // namespace mcal