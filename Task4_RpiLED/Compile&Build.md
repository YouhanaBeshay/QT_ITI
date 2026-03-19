# Compile & Build Steps
- This guide was made using a combination of the following :
  -  [Qt-wiki cross compiling guide](https://wiki.qt.io/Cross-Compile_Qt_6_for_Raspberry_Pi) 
  -  [EhabMagdyy's qt-cross-compile](https://github.com/EhabMagdyy/ITI-QtQML/blob/main/Task05_RPiControlLED/README.md) <small>(🫡)</small>


## Part A: Setup the environment & packages
1. install the qt packages on **Raspberry Pi**
    ```bash
    sudo apt update
    sudo apt install \
    libc6-dev libstdc++-12-dev \
    qt6-base-dev qt6-declarative-dev \
    libqt6quick6 \
    qml6-module-qtquick \
    qml6-module-qtquick-controls
    ```
2. create sysroot of pi on **HOST Machine**
    ```bash
    mkdir -p ~/rpi-sysroot/usr

    rsync -avz youhana@192.168.1.12:/usr/include ~/rpi-sysroot/usr/
    rsync -avz youhana@192.168.1.12:/usr/lib     ~/rpi-sysroot/usr/
    rsync -avz youhana@192.168.1.12:/lib         ~/rpi-sysroot/
    rsync -avz youhana@192.168.1.12:/usr/share/qt6 ~/rpi-sysroot/usr/share/ 2>/dev/null || true
    ```
3. fix links in sysroot in **HOST Machine** using `symlinks` command
    - As the soft links will be broken from rsync
    ```bash
    sudo apt install symlinks
    cd ~
    symlinks -rc rpi-sysroot
    ```
4. install the qt 6.8.3 on **HOST Machine** to be compatible with the pi's qt version (6.8.2)
    - from qt maintainace app, download qt 6.8.3
5.  create cmake toolchain in **HOST Machine**
    > **NOTE**: I needed to compile a new version of the cross-compiler to match the same glibc version as the Raspberry Pi (glibc 2.41).

    - In `crosstool-ng` `menuconfig`:
      - Set **C Library** to `glibc 2.41`
  
    - [cmake toolchain](./rpi-toolchain.cmake)


## Part B: Build the project
-  build using cmake not the qt creator as its easier to set variables
    ```bash
    cmake -S . -B build-rpi \
    -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=rpi-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release

    ## build
    cmake --build build-rpi  
    ```
##  Part C: Deploy the project and run it
### send to rpi:
``` bash
 cd build-rpi
 ## rsync the main app
 rsync -avz appTask4_RpiLED youhana@192.168.1.12:~/tasks/QT_LED

 ## rsync the shared library (mygpio)
 rsync -avz lib/libmygpio.so youhana@192.168.1.12:~/tasks/QT_LED/lib
```
### run on rpi:
``` bash
ssh youhana@192.168.1.12

cd tasks/QT_LED

export DISPLAY=:0
./appTask4_RpiLED
```
    
    
