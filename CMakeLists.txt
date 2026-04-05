cmake_minimum_required(VERSION 3.24)

project(pro_desk_shell VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)
include(FetchContent)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CompilerWarnings)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 WaylandClient)
find_package(LayerShellQt REQUIRED)

if(POLICY QTP0001)
    qt_policy(SET QTP0001 NEW)
endif()

qt_standard_project_setup(REQUIRES 6.5)

find_package(CxxQt QUIET)
if(NOT CxxQt_FOUND)
    FetchContent_Declare(
        CxxQt
        GIT_REPOSITORY https://github.com/kdab/cxx-qt-cmake.git
        GIT_TAG 0.8.1
    )
    FetchContent_MakeAvailable(CxxQt)
endif()

set(CRATE shell_ui_bridge)

cxx_qt_import_crate(
    MANIFEST_PATH rust/Cargo.toml
    CRATES ${CRATE}
    QT_MODULES Qt::Core Qt::Gui Qt::Qml Qt::Quick Qt::QuickControls2
)

cxx_qt_import_qml_module(${CRATE}_qml_module
    URI "io.hotamago.shell"
    SOURCE_CRATE ${CRATE}
)

qt_add_executable(pro-desk-shell
    cpp/main.cpp
    cpp/shell/app_bootstrap.cpp
    cpp/shell/app_bootstrap.h
)

pro_desk_shell_set_common_warnings(pro-desk-shell)

target_include_directories(pro-desk-shell PRIVATE cpp)

qt_add_qml_module(pro-desk-shell
    URI ProDeskShell
    VERSION 1.0
    QML_FILES
        qml/App.qml
        qml/components/DesktopTestBar.qml
        qml/components/PlaceholderBar.qml
)

target_link_libraries(pro-desk-shell
    PRIVATE
        ${CRATE}_qml_module
        LayerShellQt::Interface
        Qt::Core
        Qt::Gui
        Qt::Qml
        Qt::Quick
        Qt::QuickControls2
        Qt::WaylandClient
)

qt_import_qml_plugins(pro-desk-shell)

install(
    TARGETS pro-desk-shell
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
