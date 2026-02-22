import QtQuick 2.12
import QtQuick.Controls.Basic
import "../shared"
import QtQuick.Layouts

Rectangle {
    width : 800
    id: mainWindow
    height : 500
    color: "#2c3e50"
    Accessible.role: Accessible.Pane
    Accessible.name: "Search panel"
    Accessible.description: "Search for albums and add selected results to the download queue."
    function triggerSearch() {
        app.searchController.doSearch(textfield.text);
    }
    function addCheckedSearchResultsToDownloads() {
        searchList.addCheckedToDownloads();
    }
    function appendCheckedSearchUrlsToDownloadInput() {
        searchList.appendCheckedUrlsToDownloadInput();
    }

    Keys.onPressed: (event) => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_D) {
            addCheckedSearchResultsToDownloads();
            event.accepted = true;
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U) {
            appendCheckedSearchUrlsToDownloadInput();
            event.accepted = true;
        }
    }

    Connections
    {
        target: app.searchController.searchResultVM
        function onSelectedIndexChanged()
        {
            mainWindow.state = "normal";
        }
    }
    state: "expanded"
    states: [
        State {
            name: "normal"
            PropertyChanges { target: leftColumn; width: mainRow.width * 0.7 }
            PropertyChanges { target: rightColumn; width: mainRow.width * 0.3; x: leftColumn.width }
        },
        State {
            name: "expanded"
            PropertyChanges { target: leftColumn; width: mainRow.width }
            PropertyChanges { target: rightColumn; width: mainRow.width * 0.3; x: mainWindow.width }
        }
    ]
    transitions: [
        Transition {
            from: "*"; to: "*"
            NumberAnimation {
                properties: "width, x"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    ]
    Row
    {
        id: mainRow
        width: parent.width
        height: parent.height


        Column {
            id: leftColumn
            topPadding: 10
            height: parent.height - 5
            spacing: 10

            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                width:parent.width * 0.9

                height: 40

                //Search Box
                Row {
                    id: row1
                    spacing: parent.width * 0.05

                    height: 40
                    width: parent.width
                    Rectangle {
                        id: rectangle

                        width: parent.width * 0.75
                        color: "#6C98C4"

                        height: 40
                        radius: 15

                        RowLayout {
                            id: row

                            height: 40
                            width: parent.width

                            Item {
                                Layout.fillWidth: true
                                height: parent.height
                                Layout.alignment: Qt.AlignVCenter
                                width: parent.width * 0.9

                                TextField {
                                    id: textfield

                                    color: "#ffffff"
                                    font.pointSize: 13
                                    height: parent.height
                                    hoverEnabled: true
                                    placeholderText: "Search..."
                                    placeholderTextColor: "#b5ffffff"
                                    verticalAlignment: Text.AlignVCenter
                                    width: parent.width
                                    activeFocusOnTab: true

                                    Accessible.role: Accessible.EditableText
                                    Accessible.name: "Search albums"
                                    Accessible.description: "Type an album name and press Enter to search."
                                    Accessible.focusable: true
                                    Accessible.focused: activeFocus

                                    function focusNextEditableTarget(forward) {
                                        var nextItem = textfield.nextItemInFocusChain(forward);
                                        if (nextItem && nextItem !== textfield) {
                                            nextItem.forceActiveFocus();
                                        }
                                    }

                                    background: Rectangle {
                                        color: "#6C98C4" // match parent background
                                        radius: 10
                                    }
                                    onAccepted:
                                    {
                                        mainWindow.triggerSearch();
                                    }
                                    Keys.onPressed: (event) => {
                                        if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                            textfield.focusNextEditableTarget(false);
                                            event.accepted = true;
                                        } else if (event.key === Qt.Key_Tab && event.modifiers === Qt.NoModifier) {
                                            textfield.focusNextEditableTarget(true);
                                            event.accepted = true;
                                        }
                                    }

                                    onHoveredChanged: {
                                        if (hovered) {
                                            onPlaceholderHover.start();
                                        } else {
                                            onPlaceholderUnHover.start();
                                        }
                                    }

                                    PropertyAnimation {
                                        id: onPlaceholderHover

                                        duration: 100
                                        property: "placeholderTextColor"
                                        target: textfield
                                        to: "#00ffffff" // ~70% opacity
                                    }
                                    PropertyAnimation {
                                        id: onPlaceholderUnHover

                                        duration: 100
                                        property: "placeholderTextColor"
                                        target: textfield
                                        to: "#b5ffffff" // original alpha
                                    }
                                }
                            }

                            Image {
                                id: icon
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                fillMode: Image.PreserveAspectFit
                                height: parent.height
                                source: "qrc:/icons/search.svg"
                                Layout.rightMargin: 5
                                activeFocusOnTab: true

                                Accessible.role: Accessible.Button
                                Accessible.name: "Run search"
                                Accessible.description: "Search using the current query."
                                Accessible.focusable: true
                                Accessible.focused: activeFocus

                                function activateSearchButton() {
                                    if (!enabled) {
                                        return;
                                    }
                                    mainWindow.triggerSearch();
                                }

                                Keys.onReturnPressed: {
                                    activateSearchButton();
                                    event.accepted = true;
                                }
                                Keys.onEnterPressed: {
                                    activateSearchButton();
                                    event.accepted = true;
                                }
                                Keys.onSpacePressed: {
                                    activateSearchButton();
                                    event.accepted = true;
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.width: icon.activeFocus ? 2 : 0
                                    border.color: icon.activeFocus ? "#ffffff" : "transparent"
                                    radius: 6
                                }

                                SequentialAnimation {
                                    id: shrinkAnim

                                    NumberAnimation {
                                        duration: 100
                                        property: "scale"
                                        target: icon
                                        to: 0.96
                                    }
                                }
                                SequentialAnimation {
                                    id: resetAnim

                                    NumberAnimation {
                                        duration: 100
                                        property: "scale"
                                        target: icon
                                        to: 1.0
                                    }
                                }
                                SequentialAnimation {
                                    id: growAnim

                                    NumberAnimation {
                                        duration: 100
                                        property: "scale"
                                        target: icon
                                        to: 1.1
                                    }
                                }
                                MouseArea {
                                    anchors.bottomMargin: 0
                                    anchors.fill: parent
                                    anchors.leftMargin: 0
                                    anchors.rightMargin: 0
                                    anchors.topMargin: 0
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {

                                        icon.activateSearchButton();
                                    }
                                    onEntered: {
                                        growAnim.running = true;
                                    }
                                    onExited: {
                                        resetAnim.running = true;
                                    }
                                    onPressed: {
                                        shrinkAnim.running = true;
                                    }
                                    onReleased: {
                                        growAnim.running = true;
                                    }
                                }
                            }
                        }
                    }
                    WButton {

                        height: 40
                        label: "Add All"
                        accessibleName: "Add all shown albums to downloads"
                        accessibleDescription: "Add every current search result to the download queue."
                        width: parent.width * 0.2
                        onClicked:
                        {
                            app.searchController.addAllAlbumsToDownloads();
                            searchList.hideAllResults();
                        }
                    }
                }
            }
            //Divider
            Rectangle {
                height: 1
                width: parent.width
            }
            Row {
                id: selectionActions
                width: parent.width * 0.9
                height: 36
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                WButton {
                    width: (parent.width - parent.spacing) * 0.5
                    height: parent.height
                    label: "Add Checked"
                    accessibleName: "Add checked albums to downloads"
                    accessibleDescription: "Queue checked search results for download. Shortcut: Ctrl+D."
                    onClicked: {
                        mainWindow.addCheckedSearchResultsToDownloads();
                    }
                }
                WButton {
                    width: (parent.width - parent.spacing) * 0.5
                    height: parent.height
                    label: "To URL Box"
                    accessibleName: "Append checked album URLs to download input"
                    accessibleDescription: "Append checked album links to the download tab URL input box. Shortcut: Ctrl+U."
                    onClicked: {
                        mainWindow.appendCheckedSearchUrlsToDownloadInput();
                    }
                }
            }
            //WButton {
            //    y: 0
            //    width: 140
            //    height: 40

            //    label: "StateTest"
            //    anchors.horizontalCenterOffset: 300
            //    onClicked:
            //    {
            //        console.log("test")
            //        mainWindow.state = (mainWindow.state === "normal") ? "expanded" : "normal"
            //    }
            //}
            //Search Info
            SearchResultsList {
                id: searchList;
                height: parent.height - rectangle.height - selectionActions.height - 40
                width: parent.width
            }
        }
        //SideColumn
        Column{
            id:rightColumn
            height: parent.height
            width: parent.width

            // Right panel
            Rectangle {
                id: rightPanel
                width: parent.width
                height: parent.height
                color: "#34495e"


                AlbumInfoSide
                {
                    width: parent.width
                    height: parent.height
                }
            }
        }
    }
}
