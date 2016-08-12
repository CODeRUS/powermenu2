import QtQuick 2.0
import Sailfish.Silica 1.0
import org.coderus.powermenu 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: (pactl.value / pactl.maximumValue * 100).toFixed(0) + "%"
    icon: "image://theme/icon-m-music"
    settingsPage: ""

    Component.onCompleted: {
        PulseAudio.update()
    }

    Connections {
        target: PulseAudio
        onVolumeChanged: {
            pactl.maximumValue = maximum
            pactl.value = volume
        }
    }

    QtObject {
        id: pactl
        property int maximumValue: 11
        property int value: 1
    }

    expandComponent: Component {
        Item {
            Slider {
                anchors.centerIn: parent
                width: parent.width
                minimumValue: 0
                maximumValue: pactl.maximumValue
                stepSize: 1
                value: pactl.value
                onValueChanged: {
                    var newValue = Math.round(value)
                    if (newValue != pactl.value) {
                        PulseAudio.setVolume(newValue)
                    }
                }
            }
        }
    }

    onClicked: {
        if (pactl.value >= pactl.maximumValue) {
            PulseAudio.setVolume(0)
        }
        else if (pactl.value == 0) {
            PulseAudio.setVolume(1)
        }
        else {
            var nextVol = pactl.value + 2
            if (nextVol > pactl.maximumValue) {
                nextVol = pactl.maximumValue
            }
            PulseAudio.setVolume(nextVol)
        }
    }
}

