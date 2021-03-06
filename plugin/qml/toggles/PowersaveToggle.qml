import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0
import org.freedesktop.contextkit 1.0
import org.coderus.powermenu 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: powersaveThreshold + "%"
    icon: "image://theme/icon-m-battery"
    active: expanded || enablePowersave || forcePowersave
    settingsPage: "system_settings/info/powersave"

    expandComponent: Component {
        Item {
            Slider {
                anchors.centerIn: parent
                width: parent.width
                minimumValue: 1
                maximumValue: 99
                stepSize: 1
                value: powersaveThreshold
                label: qsTr("Battery powersave thresold")
                onReleased: mceRequestIface.setValue(key_powersave_threshold, Math.round(value))
            }
        }
    }

    onClicked: {
        if (forcePowersave) {
            mceRequestIface.setValue(key_powersave_force, false)
            mceRequestIface.setValue(key_powersave_enable, false)
        }
        else if (enablePowersave) {
            mceRequestIface.setValue(key_powersave_force, true)
        }
        else {
            mceRequestIface.setValue(key_powersave_enable, true)
        }
    }

    property string key_powersave_enable: "/system/osso/dsm/energymanagement/enable_power_saving"
    property string key_powersave_force: "/system/osso/dsm/energymanagement/force_power_saving"
    property string key_powersave_threshold: "/system/osso/dsm/energymanagement/psm_threshold"

    readonly property bool enablePowersave: values[key_powersave_enable]
    readonly property bool forcePowersave: values[key_powersave_force]
    readonly property int powersaveThreshold: values[key_powersave_threshold]

    property var values: {
        "/system/osso/dsm/energymanagement/enable_power_saving": true,
        "/system/osso/dsm/energymanagement/force_power_saving": true,
        "/system/osso/dsm/energymanagement/psm_threshold": 50
    }

    Image {
        id: psmIcon
        source: "image://theme/icon-status-powersave"
        cache: true
        anchors.centerIn: iconItem
        anchors.horizontalCenterOffset: Math.min(iconItem.width, iconItem.height) / 2 - width / 2
        anchors.verticalCenterOffset: Math.min(iconItem.width, iconItem.height) / 2 - height / 2
        visible: systemPowerSaveModeContextProperty.value || false
        layer.effect: ShaderEffect {
            property color color: Theme.highlightColor

            fragmentShader: "
                varying mediump vec2 qt_TexCoord0;
                uniform highp float qt_Opacity;
                uniform lowp sampler2D source;
                uniform highp vec4 color;
                void main() {
                    highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                    gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
                }
            "
        }
        layer.enabled: root.highlighted
        layer.samplerName: "source"
    }

    Label {
        anchors.left: psmIcon.right
        anchors.verticalCenter: psmIcon.verticalCenter
        visible: !forcePowersave && enablePowersave
        font.pixelSize: psmIcon.height / 3 * 2
        text: "A"
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    ContextProperty {
        id: systemPowerSaveModeContextProperty
        key: "System.PowerSaveMode"
    }

    DBusInterface {
        id: mceRequestIface
        service: 'com.nokia.mce'
        path: '/com/nokia/mce/request'
        iface: 'com.nokia.mce.request'
        bus: DBus.SystemBus

        function setValue(key, value) {
            typedCall('set_config', [{"type":"s", "value":key}, {"type":"v", "value":value}])
        }

        function getValue(key) {
            typedCall('get_config', [{"type":"s", "value":key}], function (value) {
                var temp = values
                temp[key] = value
                values = temp
            })
        }

        Component.onCompleted: {
            getValue(key_powersave_enable)
            getValue(key_powersave_force)
            getValue(key_powersave_threshold)
        }
    }

    DBusInterface {
        id: mceSignalIface
        service: 'com.nokia.mce'
        path: '/com/nokia/mce/signal'
        iface: 'com.nokia.mce.signal'
        bus: DBus.SystemBus

        signalsEnabled: true

        function config_change_ind(key, value) {
            if (key in values) {
                var temp = values
                temp[key] = value
                values = temp
            }
        }
    }
}
