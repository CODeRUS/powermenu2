#include "flashlightcontrol.h"

#include <QFile>

FlashlightControl::FlashlightControl(QObject *parent) : QObject(parent)
{
    flashlightStatus = new MGConfItem("/apps/powermenu/flashlight", this);
    QObject::connect(flashlightStatus, SIGNAL(valueChanged()), this, SIGNAL(activeChanged()));
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
    QStringList controls;
    controls << "/sys/kernel/debug/flash_adp1650/mode";
    controls << "/sys/class/leds/torch-flash/flash_light";
    controls << "/sys/class/leds/led:flash_torch/brightness";
    controls << "/sys/class/leds/torch-light0/brightness";

    foreach (const QString & control, controls) {
        QFile flash(control);
        if (flash.exists() && flash.open(QFile::WriteOnly)) {
            flash.write(active() ? "0" : "1");
            flash.close();
            flashlightStatus->set(!active());

            Q_EMIT activeChanged();
        }
    }
}
