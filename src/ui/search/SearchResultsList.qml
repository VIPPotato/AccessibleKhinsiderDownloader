import QtQuick 2.12
import QtQuick.Controls 2.12
import "../shared"

Item {
    id: root
    function hideAllResults()
    {
        root.isSearching = true;
        app.searchController.searchResultVM.setSelectedIndex(-1);
    }
    function selectResult(resultIndex) {
        if (resultIndex < 0 || resultIndex >= resultRepeater.count) {
            return;
        }
        app.searchController.searchResultVM.setSelectedIndex(resultIndex);
    }
    function focusResult(resultIndex) {
        if (resultIndex < 0 || resultIndex >= resultRepeater.count) {
            return;
        }
        selectResult(resultIndex);
        var item = resultRepeater.itemAt(resultIndex);
        if (item) {
            item.forceActiveFocus();
        }
    }

    property int selectedIndex: app.searchController.searchResultVM.selectedIndex
    property bool isSearching: false

    height: 600
    width: 600

    Accessible.role: Accessible.List
    Accessible.name: "Search results"
    Accessible.description: "Album search results. Use Up and Down arrows to move and Enter to select."

    WScrollView {
        id: scrollView

        anchors.fill: parent
        clip: true

        Column {
            id: repeater

            spacing: 5
            width: root.width

            Repeater {
                id: resultRepeater
                model: app.searchController.searchResultVM

                Rectangle {
                    id: rectangle

                    property bool isHovered: false
                    property bool isSelected: index === root.selectedIndex

                    color: isSelected || isHovered ? "#759fc7" : "#6c98c4"
                    height: 45
                    radius: 10
                    width: parent.width * 0.9
                    x: isSelected ? 0 : (parent.width - width) / 2
                    scale: root.isSearching ? 0 : isSelected ? 0.95 : mouseArea.pressed ? 0.90 : 1.0
                    opacity: root.isSearching ? 0 : 1
                    activeFocusOnTab: true
                    border.width: activeFocus ? 2 : 0
                    border.color: activeFocus ? "#ffffff" : "transparent"

                    Accessible.role: Accessible.ListItem
                    Accessible.name: model.name
                    Accessible.description: "Result " + (index + 1) + " of " + resultRepeater.count + ". " + (isSelected ? "Selected" : "Not selected")
                    Accessible.focusable: true
                    Accessible.focused: activeFocus

                    Keys.onReturnPressed: {
                        root.selectResult(index);
                        event.accepted = true;
                    }
                    Keys.onEnterPressed: {
                        root.selectResult(index);
                        event.accepted = true;
                    }
                    Keys.onSpacePressed: {
                        root.selectResult(index);
                        event.accepted = true;
                    }
                    Keys.onUpPressed: {
                        root.focusResult(index - 1);
                        event.accepted = true;
                    }
                    Keys.onDownPressed: {
                        root.focusResult(index + 1);
                        event.accepted = true;
                    }
                    Keys.onHomePressed: {
                        root.focusResult(0);
                        event.accepted = true;
                    }
                    Keys.onEndPressed: {
                        root.focusResult(resultRepeater.count - 1);
                        event.accepted = true;
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.selectResult(index);
                            rectangle.forceActiveFocus();
                        }
                        onEntered: {
                            if (!isSelected) {
                                isHovered = true;
                            }
                        }
                        onExited: {
                            if (!isSelected) {
                                isHovered = false;
                            }
                        }
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        color: "white"
                        elide: Text.ElideRight
                        font.bold: true
                        font.pointSize: 13
                        height: parent.height
                        horizontalAlignment: Text.AlignLeft
                        text: model.name
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width
                    }
                }
            }
        }
    }
    Connections {
           target: app.searchController.searchResultVM
           function onSearchStarted() {
               root.hideAllResults();
           }
       }

       Connections {
           target: app.searchController.searchResultVM
           function onSearchCompleted() {
               root.isSearching = false;
               if (resultRepeater.count > 0) {
                   root.focusResult(0);
               }
           }
       }
}
