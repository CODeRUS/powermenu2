#include "flashlightcontrol.h"

#include <QFile>

FlashlightControl::FlashlightControl(QObject *parent) : QObject(parent)
{
    flashlightStatus = new MGConfItem("/apps/powermenu/flashlight", this);
    QObject::connect(flashlightStatus, SIGNAL(valueChanged()), this, SIGNAL(activeChanged()));

    flashlight = new QDBusInterface("org.coderus.powermenu.flashlight",
                                    "/",
                                    "org.coderus.powermenu.flashlight",
                                    QDBusConnection::sessionBus(), this);
}

FlashlightControl *FlashlightControl::GetInstance(QObject *parent)
{
    static FlashlightControl* lsSingleton = NULL;
    if (!lsSingleton) {
        lsSingleton = new FlashlightControl(parent);
    }
    return lsSingleton;
}

bool FlashlightControl::active()
{
    return flashlightStatus->value(false).toBool();
}

void FlashlightControl::toggle()
{
    flashlight->call(QDBus::NoBlock, "setActive", !active());
    flashlightStatus->set(!active());
    Q_EMIT activeChanged();
}
