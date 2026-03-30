#include "shell/app_bootstrap.h"

#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QUrl>

namespace {

constexpr auto kAppUrl = "qrc:/qt/qml/ProDeskShell/App.qml";
constexpr int kPanelHeight = 40;

}  // namespace

namespace shell {

AppBootstrap::AppBootstrap()
{
    LayerShellQt::Shell::useLayerShell();
}

bool AppBootstrap::initialize(QQmlApplicationEngine& engine)
{
    engine.load(QUrl(QStringLiteral(kAppUrl)));
    if (engine.rootObjects().isEmpty()) {
        m_last_error = QStringLiteral("QQmlApplicationEngine failed to load App.qml");
        return false;
    }

    auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().constFirst());
    if (window == nullptr) {
        m_last_error = QStringLiteral("Root QML object is not a QQuickWindow");
        return false;
    }

    return configure_layer_shell(window);
}

QString AppBootstrap::last_error() const
{
    return m_last_error;
}

bool AppBootstrap::configure_layer_shell(QQuickWindow* window)
{
    auto* layer_window = LayerShellQt::Window::get(window);
    if (layer_window == nullptr) {
        m_last_error = QStringLiteral("LayerShellQt could not wrap the root window");
        return false;
    }

    layer_window->setLayer(LayerShellQt::Window::LayerTop);
    layer_window->setAnchors(
        LayerShellQt::Window::AnchorTop
        | LayerShellQt::Window::AnchorLeft
        | LayerShellQt::Window::AnchorRight);
    layer_window->setExclusiveZone(kPanelHeight);
    window->setHeight(kPanelHeight);

    return true;
}

}  // namespace shell
