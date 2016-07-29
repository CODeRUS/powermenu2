#include <QCoreApplication>

#include <QTimer>

#include <unistd.h>
#include <grp.h>
#include <pwd.h>

#include "dbuslistener.h"

const char* msgTypeToString(QtMsgType type)
{
    switch (type) {
    case QtDebugMsg:
        return "D";
    case QtWarningMsg:
        return "W";
    case QtCriticalMsg:
        return "C";
    case QtFatalMsg:
        return "F";
        //abort();
    default:
        return "D";
    }
}

void printLog(const QString &message)
{
    QTextStream(stdout) << message;
}

QString simpleLog(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    return QString("%1 %2 [%3:%4] %5\n").arg(msgTypeToString(type))
                                        .arg(QDateTime::currentDateTime().toString("hh:mm:ss"))
                                        .arg(context.function)
                                        .arg(context.line)
                                        .arg(message);
}

void stdoutHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    printLog(simpleLog(type, context, msg));
    if (type == QtFatalMsg)
        abort();
}

int main(int argc, char *argv[])
{
    setuid(getpwnam("root")->pw_uid);
    setgid(getgrnam("root")->gr_gid);
    qputenv("DBUS_SESSION_BUS_ADDRESS", "unix:path=/run/user/100000/dbus/user_bus_socket");

    qInstallMessageHandler(stdoutHandler);

    QScopedPointer<QCoreApplication> app(new QCoreApplication(argc, argv));
    QScopedPointer<DBusListener> dbus(new DBusListener(app.data()));
    QTimer::singleShot(1, dbus.data(), SLOT(startService()));
    return app->exec();
}

