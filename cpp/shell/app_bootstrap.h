#pragma once

#include <QString>

class QQmlApplicationEngine;
class QQuickWindow;

namespace shell {

class AppBootstrap {
public:
    AppBootstrap();

    bool initialize(QQmlApplicationEngine& engine);
    QString last_error() const;

private:
    bool configure_layer_shell(QQuickWindow* window);

    bool m_use_layer_shell = false;
    QString m_last_error;
};

}  // namespace shell
