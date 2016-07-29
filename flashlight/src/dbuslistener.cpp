#include "dbuslistener.h"

#include <QDebug>
#include <QCoreApplication>

#include <unistd.h>
#include <grp.h>
#include <pwd.h>

DBusListener::DBusListener(QObject *parent) :
    QObject(parent)
{
}

void DBusListener::toggle()
{
    FlashlightControl::GetInstance()->toggle();
}

void DBusListener::quit()
{
    QCoreApplication::instance()->quit();
}

void DBusListener::startService()
{
    qDebug("startService");

    qDebug() << "DBus service" << (QDBusConnection::sessionBus().registerService("org.coderus.powermenu.flashlight") ? "registered" : "error!");
    qDebug() << "DBus object" << (QDBusConnection::sessionBus().registerObject("/", this,
                                                 QDBusConnection::ExportScriptableSlots)
                ? "registered" : "error!");

    qDebug() << "listener started";
}

