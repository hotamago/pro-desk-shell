#include "shell/app_bootstrap.h"

#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickWindow>

namespace {

constexpr auto kAppModule = "ProDeskShell";
constexpr auto kAppType = "App";

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
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::warnings,
        &engine,
        [this](const QList<QQmlError>& warnings) { record_qml_warnings(warnings); });

    engine.rootContext()->setContextProperty(QStringLiteral("shellUseLayerShell"), m_use_layer_shell);
    engine.loadFromModule(QString::fromLatin1(kAppModule), QString::fromLatin1(kAppType));
    if (engine.rootObjects().isEmpty()) {
        if (m_last_error.isEmpty()) {
            m_last_error = QStringLiteral("QQmlApplicationEngine failed to load App.qml");
        }
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

void AppBootstrap::record_qml_warnings(const QList<QQmlError>& warnings)
{
    QStringList formatted_warnings;
    formatted_warnings.reserve(warnings.size());

    for (const auto& warning : warnings) {
        formatted_warnings.append(warning.toString());
    }

    if (!formatted_warnings.isEmpty()) {
        m_last_error = formatted_warnings.join(QLatin1Char('\n'));
        qWarning().noquote() << m_last_error;
    }
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
    anchors |= LayerShellQt::Window::AnchorBottom;
    anchors |= LayerShellQt::Window::AnchorLeft;
    anchors |= LayerShellQt::Window::AnchorRight;

    layer_window->setAnchors(anchors);
    layer_window->setExclusiveZone(0);

    return true;
}

}  // namespace shell
