#ifndef DBUSLISTENERFLASHLIGHT_H
#define DBUSLISTENERFLASHLIGHT_H

#include <QObject>

#include <QtDBus>

#include "../libpowermenutools/src/flashlightcontrol.h"

class DBusListener : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.coderus.powermenu.flashlight")
public:
    explicit DBusListener(QObject *parent = 0);

public slots:
    Q_SCRIPTABLE void setActive(bool active);
    Q_SCRIPTABLE void quit();

public slots:
    void startService();

};

#endif // DBUSLISTENERFLASHLIGHT_H
