import QtQuick 2.1
import Sailfish.Silica 1.0
import org.coderus.powermenu.desktopfilemodel 1.0
import org.nemomobile.configuration 1.0
import ".."

Page {
    id: page
    objectName: "beginnerPage"

    SilicaFlickable {
        id: flick
        anchors.fill: page
        contentHeight: column.height

        Column {
            id: column
            width: flick.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Configuration")
            }

            SectionHeader {
                text: qsTr("Powerkey settings")
            }

            TextSwitch {
                width: parent.width
                text: qsTr("Enable Powermenu2 on long key press")
                checked: helper.action1 == "powermenu2"
                onCheckedChanged: {
                    helper.longPressActionOn = "dbus1"
                    helper.action1 = checked ? "powermenu2" : "power-key-menu"
                }
            }

            TextSwitch {
                width: parent.width
                text: qsTr("Flashlight on double key press")
                checked: helper.doublePressActionOff == "dbus3" && helper.doublePressActionOn == "dbus3"
                onCheckedChanged: {
                    helper.doublePressActionOff = checked ? "dbus3" : "unblank,tkunlock,dbus2"
                    helper.doublePressActionOn = checked ? "dbus3" : "blank,tklock,devlock"
                    helper.action2 = "double-power-key"
                    helper.action3 = "flashlight"
                }
            }

            SectionHeader {
                text: qsTr("Custom shortcuts")
            }

            ListView {
                width: parent.width
                height: contentHeight
                model: desktopModel
                interactive: false
                delegate: Component {
                    ListItem {
                        id: item
                        width: ListView.view.width
                        contentHeight: Theme.itemSizeSmall
                        ListView.onRemove: animateRemoval(item)
                        menu: contextMenu

                        function removeShortcut() {
                            var itemname = model.path
                            remorseAction(qsTr("Delete shortcut"),
                                                 function() {
                                                     var list = shortcutsConfig.value
                                                     for (var i = 0; i < list.length; i++) {
                                                        if (list[i] == itemname) {
                                                            list.splice(i, 1);
                                                            break;
                                                        }
                                                     }
                                                     shortcutsConfig.value = list
                                                 },
                                                 3000
                            )
                        }

                        Image {
                            id: iconImage
                            source: model.icon
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            anchors {
                                left: parent.left
                                leftMargin: Theme.horizontalPageMargin
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Label {
                            text: model.name
                            anchors {
                                left: iconImage.right
                                leftMargin: Theme.paddingMedium
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                MenuItem {
                                    text: qsTr("Remove")
                                    onClicked: {
                                        removeShortcut()
                                    }
                                }
                            }
                        }
                    }
                }
                footer: BackgroundItem {
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("ShortcutsPage.qml"), {
                            selectedValues: shortcutsConfig.value,
                            selectedCallback: function(path) {
                                var list = shortcutsConfig.value
                                list.splice(list.length, 0, path)
                                shortcutsConfig.value = list
                            }
                        })
                    }

                    Image {
                        id: addImage
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                        source: "image://theme/icon-l-add"
                        anchors {
                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Label {
                        text: qsTr("Add shortcut")
                        anchors {
                            left: addImage.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }


    ConfigurationValue {
        id: shortcutsConfig
        key: "/apps/powermenu/shortcuts"
        defaultValue: []
    }

    DesktopFileSortModel {
        id: desktopModel
        filterShortcuts: shortcutsConfig.value
        onlySelected: true
        showHidden: true
    }
}


