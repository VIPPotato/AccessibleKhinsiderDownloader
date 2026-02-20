import QtQuick 2.12
import QtQuick.Controls 2.12
import "../shared"

Item {
    id: root
    property var checkedResults: ({})
    property int checkedCount: 0
    property int checkedRevision: 0
    function hideAllResults()
    {
        root.isSearching = true;
        root.clearCheckedResults();
        app.searchController.searchResultVM.setSelectedIndex(-1);
    }
    function selectResult(resultIndex) {
        if (resultIndex < 0 || resultIndex >= resultRepeater.count) {
            return;
        }
        app.searchController.searchResultVM.setSelectedIndex(resultIndex);
    }
    function isResultChecked(resultIndex) {
        return checkedResults[resultIndex] === true;
    }
    function setResultChecked(resultIndex, checked) {
        if (resultIndex < 0 || resultIndex >= resultRepeater.count) {
            return;
        }
        var previouslyChecked = root.isResultChecked(resultIndex);
        if (previouslyChecked === checked) {
            return;
        }
        if (checked) {
            checkedResults[resultIndex] = true;
            checkedCount++;
        } else {
            delete checkedResults[resultIndex];
            checkedCount = Math.max(0, checkedCount - 1);
        }
        checkedRevision++;
    }
    function toggleResultChecked(resultIndex) {
        setResultChecked(resultIndex, !isResultChecked(resultIndex));
    }
    function clearCheckedResults() {
        checkedResults = ({});
        checkedCount = 0;
        checkedRevision++;
    }
    function checkedAlbumLinks() {
        var links = [];
        for (var i = 0; i < resultRepeater.count; i++) {
            if (!isResultChecked(i)) {
                continue;
            }
            var item = resultRepeater.itemAt(i);
            if (item && item.albumLink && item.albumLink.length > 0) {
                links.push(item.albumLink);
            }
        }
        if (links.length === 0 && selectedIndex >= 0) {
            var selectedItem = resultRepeater.itemAt(selectedIndex);
            if (selectedItem && selectedItem.albumLink && selectedItem.albumLink.length > 0) {
                links.push(selectedItem.albumLink);
            }
        }
        return links;
    }
    function checkedAlbumLinksText() {
        return checkedAlbumLinks().join("\n");
    }
    function addCheckedToDownloads() {
        var linksText = checkedAlbumLinksText();
        if (linksText.length === 0) {
            return;
        }
        app.downloaderController.downloaderVM.addToDownloadList(linksText);
    }
    function appendCheckedUrlsToDownloadInput() {
        var linksText = checkedAlbumLinksText();
        if (linksText.length === 0) {
            return;
        }
        app.downloaderController.downloaderVM.appendBulkUrlBuffer(linksText);
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
    Accessible.description: "Album search results. Use Up and Down arrows to move, Space to check albums, Ctrl+D to queue checked albums, and Ctrl+U to append checked URLs to download input."
    activeFocusOnTab: true
    onActiveFocusChanged: {
        if (activeFocus && resultRepeater.count > 0) {
            focusResult(selectedIndex >= 0 ? selectedIndex : 0);
        }
    }

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
                    property bool isChecked: root.checkedRevision >= 0 && root.isResultChecked(index)
                    property string albumLink: model.albumLink

                    color: isSelected || isHovered ? "#759fc7" : (isChecked ? "#688db2" : "#6c98c4")
                    height: 45
                    radius: 10
                    width: parent.width * 0.9
                    x: isSelected ? 0 : (parent.width - width) / 2
                    scale: root.isSearching ? 0 : isSelected ? 0.95 : mouseArea.pressed ? 0.90 : 1.0
                    opacity: root.isSearching ? 0 : 1
                    activeFocusOnTab: false
                    border.width: activeFocus ? 2 : 0
                    border.color: activeFocus ? "#ffffff" : "transparent"

                    Accessible.role: Accessible.ListItem
                    Accessible.name: model.name
                    Accessible.description: "Result " + (index + 1) + " of " + resultRepeater.count + ". " + (isSelected ? "Selected" : "Not selected") + ". " + (isChecked ? "Checked" : "Not checked") + "."
                    Accessible.focusable: true
                    Accessible.focused: activeFocus
                    Accessible.selectable: true
                    Accessible.selected: isSelected
                    Accessible.checkable: true
                    Accessible.checked: isChecked

                    Keys.onReturnPressed: {
                        root.toggleResultChecked(index);
                        event.accepted = true;
                    }
                    Keys.onEnterPressed: {
                        root.toggleResultChecked(index);
                        event.accepted = true;
                    }
                    Keys.onSpacePressed: {
                        root.toggleResultChecked(index);
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
                    Keys.onPressed: (event) => {
                        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_D) {
                            root.addCheckedToDownloads();
                            event.accepted = true;
                        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U) {
                            root.appendCheckedUrlsToDownloadInput();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Home) {
                            root.focusResult(0);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_End) {
                            root.focusResult(resultRepeater.count - 1);
                            event.accepted = true;
                        }
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
                        id: checkboxIndicator
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        color: "white"
                        font.bold: true
                        font.pointSize: 13
                        height: parent.height
                        horizontalAlignment: Text.AlignLeft
                        text: isChecked ? "[x]" : "[ ]"
                        verticalAlignment: Text.AlignVCenter
                        width: 28
                        Accessible.ignored: true
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 40
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
