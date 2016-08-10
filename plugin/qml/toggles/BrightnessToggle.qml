import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import org.coderus.powermenu 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: displaySettings.brightness + "%"
    icon: "image://theme/icon-m-day"
    settingsPage: "system_settings/look_and_feel/display"

    expandComponent: Component {
        Item {
            Slider {
                anchors.centerIn: parent
                width: parent.width
                minimumValue: 1
                maximumValue: 100
                stepSize: 1
                value: displaySettings.brightness
                onValueChanged: displaySettings.brightness = Math.round(value)
            }
        }
    }

    onClicked: {
        if (displaySettings.brightness >= 100) {
            displaySettings.brightness = 1
        }
        else {
            displaySettings.brightness = Math.ceil((displaySettings.brightness + 1) / 10) * 10
        }
    }

    DisplaySettings {
        id: displaySettings
    }
}

