cmake_minimum_required(VERSION 3.16)

project(Task2_Calculator VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

set(CMAKE_AUTORCC ON)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask2_Calculator
    main.cpp
)

qt_add_qml_module(appTask2_Calculator
    URI Task2_Calculator
    QML_FILES
        Main.qml
        QML_FILES SplashScreen.qml
        QML_FILES CalcScreen.qml
        RESOURCES res.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTask2_Calculator PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTask2_Calculator
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask2_Calculator
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appTask2_Calculator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
