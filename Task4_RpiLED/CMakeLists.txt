cmake_minimum_required(VERSION 3.16)

project(Task4_RpiLED VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

## for the App to look for the shared library(mygpio) in the correct path
set(CMAKE_BUILD_RPATH "$ORIGIN/lib")
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/lib/  ${CMAKE_CURRENT_BINARY_DIR}/lib)


find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appTask4_RpiLED
    main.cpp
)

qt_add_qml_module(appTask4_RpiLED
    URI Task4_RpiLED
    QML_FILES
        Main.qml
    SOURCES
        src/gpiocontroller.h
        src/gpiocontroller.cpp
)

target_include_directories(appTask4_RpiLED PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTask4_RpiLED PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTask4_RpiLED
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask4_RpiLED
    PRIVATE Qt6::Quick
    PRIVATE mygpio
)



include(GNUInstallDirs)
install(TARGETS appTask4_RpiLED
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
