import QtQuick 2.1
import Sailfish.Silica 1.0
import ".."

Page {
    id: page
    objectName: "welcomePage"

    SilicaFlickable {
        id: flick
        anchors.fill: page
        contentHeight: column.height

        PullDownMenu {
            background: Component { ShaderTiledBackground {} }
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }

            MenuItem {
                text: qsTr("How to use")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UsagePage.qml"))
                }
            }
        }

        Column {
            id: column
            width: flick.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Powermenu 2")
            }

            Label {
                text: qsTr("Welcome to Powermenu 2 configuration\n\nTo continue please select configuration method below.")
                font.pixelSize: Theme.fontSizeMedium
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge * 2
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Beginner")
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("BeginnerPage.qml"))
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Expert")
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("ConfigurationPage.qml"))
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
