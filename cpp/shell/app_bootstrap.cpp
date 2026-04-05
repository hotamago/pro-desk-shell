#include "shell/app_bootstrap.h"

#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QUrl>

namespace {

constexpr auto kAppUrl = "qrc:/qt/qml/ProDeskShell/App.qml";
constexpr int kPanelHeight = 88;

bool use_layer_shell_from_environment()
{
    const auto value = qEnvironmentVariable("PRO_DESK_SHELL_USE_LAYER_SHELL").trimmed().toLower();
    return value == "1" || value == "true" || value == "yes" || value == "on";
}

}  // namespace

namespace shell {

AppBootstrap::AppBootstrap()
{
    m_use_layer_shell = use_layer_shell_from_environment();
    if (m_use_layer_shell) {
        LayerShellQt::Shell::useLayerShell();
    }
}

bool AppBootstrap::initialize(QQmlApplicationEngine& engine)
{
    engine.rootContext()->setContextProperty(QStringLiteral("shellUseLayerShell"), m_use_layer_shell);
    engine.load(QUrl(QString::fromLatin1(kAppUrl)));
    if (engine.rootObjects().isEmpty()) {
        m_last_error = QStringLiteral("QQmlApplicationEngine failed to load App.qml");
        return false;
    }

    auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().constFirst());
    if (window == nullptr) {
        m_last_error = QStringLiteral("Root QML object is not a QQuickWindow");
        return false;
    }

    if (!m_use_layer_shell) {
        return true;
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
    LayerShellQt::Window::Anchors anchors;
    anchors |= LayerShellQt::Window::AnchorTop;
    anchors |= LayerShellQt::Window::AnchorLeft;
    anchors |= LayerShellQt::Window::AnchorRight;

    layer_window->setAnchors(anchors);
    layer_window->setExclusiveZone(kPanelHeight);
    window->setHeight(kPanelHeight);

    return true;
}

}  // namespace shell
