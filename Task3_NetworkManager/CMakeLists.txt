cmake_minimum_required(VERSION 3.16)

project(Task3_NetworkManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTORCC ON)

# for Q_OBJECT
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick DBus)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask3_NetworkManager
    main.cpp
)

qt_add_qml_module(appTask3_NetworkManager
    URI Task3_NetworkManager
    QML_FILES
        Main.qml
        QML_FILES SplashScreen.qml
        QML_FILES HomeScreen.qml
        QML_FILES WiFiListView.qml
        QML_FILES BluetoothListView.qml
        RESOURCES res.qrc
        QML_FILES StatusView.qml
        SOURCES src/wifimanager.h src/wifimanager.cpp
        SOURCES src/bluetoothmanager.h src/bluetoothmanager.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTask3_NetworkManager PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTask3_NetworkManager
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask3_NetworkManager
    PRIVATE Qt6::Quick
            Qt6::DBus
)

include(GNUInstallDirs)
install(TARGETS appTask3_NetworkManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
