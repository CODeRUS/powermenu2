import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2
import org.coderus.powermenu 1.0

ToggleItem {
    id: root

    name: qsTr("Radio mode")
    icon: ""
    settingsPage: "system_settings/connectivity/mobile"
    disabled: !radioSettings.valid
    property string currentModem: manager.defaultModem
    property var modes1: ["any", "umts", "gsm"]
    property var modes2: ["any", "lte", "umtslte", "umts", "gsmumts", "gsm"]
    property var labels1: ["4G", "3G", "2G"]
    property var labels2: ["Any", "4G", "4G+3G", "3G", "3G+2G", "2G"]
    property var preferences: modes1
    property var labels: labels1
    property bool _externalChange: false
    property int currentIndex: 0

    expandComponent: Component {
        ListView {
            orientation: ListView.Horizontal
            delegate: Loader {
                width: root.width
                height: root.height
                sourceComponent: textLabel
                property string title: modelData
                property int pixelSize: height / 2
                property bool itemHighlight: ListView.isCurrentItem

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        radioSettings.technologyPreference = preferences[index]
                    }
                }
            }
            currentIndex: root.currentIndex
            boundsBehavior: ListView.StopAtBounds
            highlight: Component {
                Rectangle {
                    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity / 2)
                }
            }
            highlightFollowsCurrentItem: true

            model: labels

            HorizontalScrollDecorator {}
        }
    }

    function dummyTr() {
        qsTr("Any")
        qsTr("4G")
        qsTr("4G+3G")
        qsTr("3G")
        qsTr("3G+2G")
        qsTr("2G")
    }

    Component.onCompleted: {
        if (fileUtils.exists("/var/lib/patchmanager/ausmt/patches/sailfishos-more-network-modes/unified_diff.patch")) {
            preferences = modes2
            labels = labels2
            updateValue()
        }
    }

    onClicked: {
        if (!_externalChange) {
            var nextIndex = currentIndex + 1
            if (nextIndex == preferences.length) {
                nextIndex = 0
            }
            radioSettings.technologyPreference = preferences[nextIndex]
        }
    }

    function updateValue() {
        _externalChange = true
        if (radioSettings.valid) {
            var tech = radioSettings.technologyPreference
            currentIndex = preferences.indexOf(tech)
            if (currentIndex <= -1) {
                currentIndex = 0
            }
        } else {
            currentIndex = -1
        }
        _externalChange = false
    }

    Loader {
        anchors.top: parent.top
        anchors.bottom: labelItem.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.paddingMedium
        sourceComponent: textLabel
        property string title: qsTr(labels[currentIndex] || "")
        property int pixelSize: height
        property bool itemHighlight: highlighted
    }

    Component {
        id: textLabel
        Label {
            font.pixelSize: pixelSize
            fontSizeMode: Text.HorizontalFit
            text: title
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: itemHighlight ? Theme.highlightColor : Theme.primaryColor
        }
    }

    FileUtils {
        id: fileUtils
    }

    OfonoManager { id: manager }

    OfonoRadioSettings {
        id: radioSettings
        modemPath: currentModem
        onTechnologyPreferenceChanged: updateValue()
        onValidChanged: updateValue()
    }
}

