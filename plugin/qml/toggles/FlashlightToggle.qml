import QtQuick 2.0
import Sailfish.Silica 1.0
import org.coderus.powermenu 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: qsTr("Flashlight")
    icon: "image://theme/icon-camera-wb-tungsten"
    active: Flashlight.active

    onClicked: {
        flashlightIface.call("setActive", [!flashlightConfig.value])
        flashlightConfig.value = !flashlightConfig.value
    }

    DBusInterface {
        id: flashlightIface
        service: 'org.coderus.powermenu.flashlight'
        path: '/'
        iface: 'org.coderus.powermenu.flashlight'
        bus: DBus.SessionBus
    }

    ConfigurationValue {
        id: flashlightConfig
        key: "/apps/powermenu/flashlight"
        defaultValue: false
    }
}

