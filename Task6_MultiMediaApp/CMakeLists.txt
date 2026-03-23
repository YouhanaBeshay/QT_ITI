cmake_minimum_required(VERSION 3.16)

project(Task6_MultiMediaApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick VirtualKeyboard)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appTask6_MultiMediaApp
    main.cpp
)

qt_add_qml_module(appTask6_MultiMediaApp
    URI Task6_MultiMediaApp
    QML_FILES
        Main.qml
        QML_FILES radioPage.qml
        QML_FILES homePage.qml
        QML_FILES audioPage.qml
        QML_FILES videoPage.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTask6_MultiMediaApp PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTask6_MultiMediaApp
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask6_MultiMediaApp
    PRIVATE Qt6::Quick
    PRIVATE Qt6::VirtualKeyboard
)

include(GNUInstallDirs)
install(TARGETS appTask6_MultiMediaApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
