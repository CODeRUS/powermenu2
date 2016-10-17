import QtQuick 2.1
import Sailfish.Silica 1.0
import org.coderus.powermenu.desktopfilemodel 1.0
import org.nemomobile.configuration 1.0
import ".."

Page {
    id: page
    objectName: "shortcutsPage"

    property bool searchEnabled: false
    property variant selectedValues: []

    property var selectedCallback

    SilicaFlickable {
        id: view
        anchors.fill: page
        contentHeight: content.height

        PullDownMenu {
            background: Component { ShaderTiledBackground {} }
            MenuItem {
                text: configurationPowermenu.showHiddenShortcuts ? qsTr("Do not show hidden shortcuts") : qsTr("Show hidden shortcuts")
                onClicked: {
                    configurationPowermenu.showHiddenShortcuts = !configurationPowermenu.showHiddenShortcuts
                }
            }
            MenuItem {
                text: searchEnabled
                      ? qsTr("Hide search field")
                      : qsTr("Show search field")
                enabled: shortcutsRepeater.count > 0
                onClicked: {
                    searchEnabled = !searchEnabled
                }
            }
        }

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: title
                title: qsTr("Select shortcuts")
            }

            Item {
                id: searchFieldPlaceholder
                width: parent.width

                height: !searchField.enabled ? 0 : searchField.height
                Behavior on height {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            SearchField {
                id: searchField
                parent: searchFieldPlaceholder
                width: parent.width
                enabled: page.searchEnabled
                onEnabledChanged: {
                    if (!enabled) {
                        text = ''
                    }
                }
                focus: enabled
                visible: opacity > 0
                opacity: page.searchEnabled ? 1 : 0
                Behavior on opacity {
                    FadeAnimation {
                        duration: 150
                    }
                }
            }

            ListView {
                id: shortcutsRepeater
                delegate: shortcutDelegate
                model: desktopModel
                width: parent.width
                height: contentHeight
                enabled: false
                interactive: false
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: view
        size: BusyIndicatorSize.Large
        visible: !shortcutsRepeater.enabled
        running: visible
    }

    DesktopFileSortModel {
        id: desktopModel
        filter: searchField.text
        showHidden: configurationPowermenu.showHiddenShortcuts
        onDataFillEnd: {
            shortcutsRepeater.enabled = true
        }
        onShowHiddenChanged: {
            if (shortcutsRepeater.enabled) {
                shortcutsRepeater.enabled = false
                fillData(showHidden)
            }
        }
    }

    Component {
        id: shortcutDelegate
        BackgroundItem {
            id: item
            width: parent.width
            contentHeight: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            highlighted: down || selectedValues.indexOf(model.path) >= 0

            Image {
                id: iconImage
                source: model.icon
                width: Theme.iconSizeLauncher
                height: Theme.iconSizeLauncher
                smooth: true
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            Label {
                text: Theme.highlightText(model.name, searchField.text, Theme.highlightColor)
                anchors {
                    left: iconImage.right
                    leftMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                color: item.pressed ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                if (shortcutsRepeater.enabled) {
                    page.selectedCallback(model.path)
                    pageStack.pop()
                }
            }
        }
    }
}
