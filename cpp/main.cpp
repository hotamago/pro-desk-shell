#include "shell/app_bootstrap.h"

#include <QGuiApplication>
#include <QLoggingCategory>
#include <QQmlApplicationEngine>

#include <cstdio>

int main(int argc, char* argv[])
{
    QGuiApplication::setApplicationName(QStringLiteral("pro-desk-shell"));
    QGuiApplication::setOrganizationName(QStringLiteral("hotamago"));

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    shell::AppBootstrap bootstrap;
    if (!bootstrap.initialize(engine)) {
        std::fprintf(stderr, "%s\n", bootstrap.last_error().toLocal8Bit().constData());
        qCritical().noquote() << bootstrap.last_error();
        return EXIT_FAILURE;
    }

    return app.exec();
}
