import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import org.coderus.powermenu 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: profileControl.ringerVolume + "%"
    icon: "image://theme/icon-m-sounds"
    settingsPage: "system_settings/look_and_feel/sounds"

    expandComponent: Component {
        Item {
            Connections {
                target: profileControl
            }

            Slider {
                id: slider
                anchors.centerIn: parent
                width: parent.width
                minimumValue: 0
                maximumValue: 100
                stepSize: 20
                value: profileControl.ringerVolume
                onValueChanged: {
                    var newValue = Math.round(value)
                    if (profileControl.ringerVolume != newValue) {
                        profileControl.ringerVolume = newValue
                        profileControl.profile = (newValue > 0) ? "general" : "silent"
                    }
                }
            }
        }
    }

    onClicked: {
        if (profileControl.ringerVolume >= 100) {
            profileControl.ringerVolume = 0
        }
        else {
            profileControl.ringerVolume = Math.ceil((profileControl.ringerVolume + 20) / 10) * 10
        }
    }

    ProfileControl {
        id: profileControl
    }
}

