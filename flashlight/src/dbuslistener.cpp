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

void DBusListener::setActive(bool active)
{
    qDebug() << active;

    QStringList controls;
    controls << "/sys/kernel/debug/flash_adp1650/mode";
    controls << "/sys/class/leds/torch-flash/flash_light";
    controls << "/sys/class/leds/led:flash_torch/brightness";
    controls << "/sys/class/leds/torch-light0/brightness";

    foreach (const QString & control, controls) {
        QFile flash(control);
        if (flash.exists() && flash.open(QFile::WriteOnly)) {
            flash.write(active ? "1" : "0");
            flash.close();
        }
    }
}

void DBusListener::quit()
{
    qDebug() << "0";
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

