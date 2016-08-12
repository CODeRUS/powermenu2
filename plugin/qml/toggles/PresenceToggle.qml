import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0
import org.coderus.powermenu 1.0

ToggleItem {
    id: root
    anchors.fill: parent

    name: PresenceListener.presenceStateText(PresenceListener.globalPresenceState)
    icon: "image://theme/icon-m-presence"
    settingsPage: "system_settings/connectivity/presence"
    disabled: PresenceListener.globalPresenceState == Person.PresenceUnknown

    expandComponent: Component {
        ListView {
            orientation: ListView.Horizontal
            delegate: Loader {
                width: root.width
                height: root.height
                sourceComponent: Component {
                    IconItem {
                        name: PresenceListener.presenceStateText(modelData.presence)
                        icon: "image://theme/icon-m-presence"
                        active: false

                        MouseArea {
                            anchors.fill: parent
                            onClicked: presenceUpdate.setGlobalPresence(modelData.presence)
                            enabled: !root.disabled
                        }
                    }
                }
            }
            currentIndex: PresenceListener.globalPresenceState == Person.PresenceOffline ?
                              0 : PresenceListener.globalPresenceState == Person.PresenceAvailable ?
                                  2 : 1
            boundsBehavior: ListView.StopAtBounds
            highlight: Component {
                Rectangle {
                    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity / 2)
                }
            }
            highlightFollowsCurrentItem: true

            model: [
                {
                    color: "gray",
                    presence: Person.PresenceOffline
                },
                {
                    color: "orange",
                    presence: Person.PresenceAway
                },
                {
                    color: "green",
                    presence: Person.PresenceAvailable
                }
            ]

            HorizontalScrollDecorator {}
        }
    }

    onClicked: {
        if (PresenceListener.globalPresenceState == Person.PresenceOffline) {
            presenceUpdate.setGlobalPresence(Person.PresenceAway)
        }
        else if (PresenceListener.globalPresenceState == Person.PresenceAway) {
            presenceUpdate.setGlobalPresence(Person.PresenceAvailable)
        }
        else if (PresenceListener.globalPresenceState == Person.PresenceAvailable) {
            presenceUpdate.setGlobalPresence(Person.PresenceOffline)
        }
    }

    ContactPresenceUpdate {
        id: presenceUpdate
    }
}
