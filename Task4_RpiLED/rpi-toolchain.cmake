cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CT_SYSROOT  "$ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/aarch64-rpi3-linux-gnu/sysroot")
set(RPI_SYSROOT "$ENV{HOME}/rpi-sysroot")

set(CMAKE_SYSROOT ${CT_SYSROOT})

set(CMAKE_C_COMPILER   $ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/bin/aarch64-rpi3-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER $ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/bin/aarch64-rpi3-linux-gnu-g++)



set(CMAKE_C_FLAGS_INIT
    "-isystem ${RPI_SYSROOT}/usr/include/aarch64-linux-gnu \
     -isystem ${RPI_SYSROOT}/usr/include \
     -B${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

set(CMAKE_CXX_FLAGS_INIT
    "-isystem ${RPI_SYSROOT}/usr/include/aarch64-linux-gnu \
     -isystem ${RPI_SYSROOT}/usr/include \
     -B${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

set(CMAKE_EXE_LINKER_FLAGS_INIT
    "-Wl,--sysroot=${RPI_SYSROOT} \
     -Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -L${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

set(CMAKE_SHARED_LINKER_FLAGS_INIT
    "-Wl,--sysroot=${RPI_SYSROOT} \
     -Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -L${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

set(CMAKE_FIND_ROOT_PATH ${RPI_SYSROOT} ${CT_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(QT_HOST_PATH "$ENV{HOME}/Qt/6.8.3/gcc_64")
set(QT_HOST_PATH_CMAKE_DIR "$ENV{HOME}/Qt/6.8.3/gcc_64/lib/cmake")

set(ENV{PKG_CONFIG_SYSROOT_DIR} ${RPI_SYSROOT})
set(ENV{PKG_CONFIG_PATH} "${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig")