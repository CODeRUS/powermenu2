import QtQuick 2.0
import Sailfish.Silica 1.0
import org.coderus.powermenu 1.0

GridView {
    id: grid
    property int fullWidth: parent.width
    property int sideMargin: (fullWidth - (grid.cellWidth * Math.floor(fullWidth / grid.cellWidth))) / 2
    x: sideMargin
    pixelAligned: true
    flickDeceleration: Theme.flickDeceleration
    maximumFlickVelocity: Theme.maximumFlickVelocity
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    cacheBuffer: cellHeight
    interactive: contentHeight > height
    cellWidth: Theme.itemSizeExtraLarge
    cellHeight: Theme.itemSizeLarge
    property bool editMode: false
    property int expandedHeight: currentIndex != -1 ? cellHeight : 0
    property int columnCount: Math.floor(width / cellWidth)
    property int minOffsetIndex: currentIndex != -1
                                 ? currentIndex + columnCount - (currentIndex % columnCount)
                                 : 0
    signal hideWithCare
    currentIndex: -1

    function collapse() {
        currentIndex = -1
    }

    add: Transition {
        SequentialAnimation {
            NumberAnimation { properties: "z"; to: -1; duration: 1 }
            NumberAnimation { properties: "opacity"; to: 0.0; duration: 1 }
            NumberAnimation { properties: "x,y"; duration: 1 }
            NumberAnimation { properties: "z"; to: 0; duration: 200 }
            NumberAnimation { properties: "opacity"; from: 0.0; to: 1.0; duration: 100 }
        }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { properties: "z"; to: -1; duration: 1 }
            NumberAnimation { properties: "x"; to: 0; duration: 100 }
            NumberAnimation { properties: "opacity"; to: 0.0; duration: 100 }
        }
    }
    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 200 }
    }

    model: TogglesModel {
        id: gridModel
        editMode: grid.editMode
    }
    delegate: Component {
        Item {
            id: gridDelegate
            width: grid.cellWidth
            height: grid.cellHeight + extraHeight
            property int extraHeight: isCurrent ? grid.cellHeight : 0

            property bool isCurrent: GridView.isCurrentItem
            property int contentYOffset: grid.currentIndex != -1 && index >= grid.minOffsetIndex ? grid.cellHeight : 0.0

            Behavior on extraHeight {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on contentYOffset {
                NumberAnimation {
                    duration: 200
                }
            }

            Rectangle {
                id: itemDelegate
                width: gridDelegate.width
                height: grid.cellHeight
                color: actionDelegate.pressed
                       ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                       : "transparent"
                property int posX: 0
                property int posY: 0
                x: posX
                y: posY + gridDelegate.contentYOffset

                Loader {
                    id: loaderDelegate
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: "/usr/lib/qt5/qml/org/coderus/powermenu/" + model.source
                    property var sourceModel: model
                    property bool hiddenProperty: gridModel.hidden.indexOf(model.path) >= 0
                    property bool editMode: grid.editMode
                    property bool expanded: gridDelegate.isCurrent

                    MouseArea {
                        id: actionDelegate
                        anchors.fill: parent
                        property int dragIndex: index
                        onDragIndexChanged: {
                            if (drag.target) {
                                gridModel.move(index, dragIndex)
                            }
                        }
                        onPressed: {
                            if (!editMode) {
                                loaderDelegate.item.pressed = true
                            }
                        }
                        onClicked: {
                            if (grid.currentIndex != -1) {
                                grid.currentIndex = -1;
                            }
                            else if (editMode) {
                                if (!model.icon || model.icon.length == 0) {
                                    gridModel.hideToggle(model.path)
                                }
                            }
                            else if (doubleTimer2.running) {
                                doubleTimer2.stop()
                                loaderDelegate.item.doubleClicked()
                                if (loaderDelegate.item.settingsPage && loaderDelegate.item.settingsPage.length > 0) {
                                    window.disappearAnimation()
                                }
                            }
                            else {
                                doubleTimer2.restart()
                            }
                        }
                        Timer {
                            id: doubleTimer2
                            interval: 200
                            onTriggered: {
                                loaderDelegate.item.clicked()
                                if (loaderDelegate.item.hideAfterClick) {
                                    grid.hideWithCare()
                                }
                            }
                        }
                        onReleased: {
                            if (drag.target) {
                                drag.target = null
                                itemDelegate.parent = gridDelegate
                                itemDelegate.posX = 0
                                itemDelegate.posY = 0
                            }
                            loaderDelegate.item.pressed = false
                        }
                        onPressAndHold: {
                            if (grid.currentIndex != -1) {
                                grid.currentIndex = -1;
                            }
                            else if (editMode) {
                                drag.target = itemDelegate
                                var newPos = mapToItem(grid, mouseX, mouseY)
                                itemDelegate.parent = grid
                                itemDelegate.posX = newPos.x - itemDelegate.width / 2
                                itemDelegate.posY = newPos.y - itemDelegate.height
                            }
                            else if (loaderDelegate.item.expandComponent && !loaderDelegate.item.disabled) {
                                grid.currentIndex = index
                            }
                        }
                        onPositionChanged: {
                            if (drag.target) {
                                var targetIndex = grid.indexAt(itemDelegate.x + itemDelegate.width / 2, itemDelegate.y + itemDelegate.height / 2)
                                if (targetIndex >= 0) {
                                    dragIndex = targetIndex
                                }
                            }
                        }
                        onContainsMouseChanged: {
                            if (!drag.target && !editMode) {
                                loaderDelegate.item.pressed = containsMouse
                            }
                        }
                    }
                }

                Item {
                    anchors.top: parent.bottom
                    x: -gridDelegate.x
                    width: grid.width - grid.sideMargin * 2
                    height: gridDelegate.extraHeight
                    clip: true

                    Loader {
                        id: expandDelegate
                        anchors.bottom: parent.bottom
                        height: parent.height
                        width: parent.width
                        active: gridDelegate.isCurrent
                        sourceComponent: loaderDelegate.item.expandComponent
                    }
                }
            }
        }
    }
}

