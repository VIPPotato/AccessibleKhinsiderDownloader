import QtQuick
import QtQuick.Dialogs
import "../shared"
import QtQml
import QtQuick.Controls.Basic
import QtQml.XmlListModel
import QtQuick.Layouts

Rectangle {
    color: "#2c3e50"
    height: 700
    width: 400

    Accessible.role: Accessible.Pane
    Accessible.name: "About panel"
    Accessible.description: "Project information, contributors list, and release links."

    Connections {
        target: app.aboutController
        function onFoundNewUpdate() {
            messageDialog.visible = true;
        }
    }

    UpdateCheckerDialog {
        id: messageDialog
        onAccepted: {
            Qt.openUrlExternally("https://github.com/weespin/KhinsiderDownloader/releases")
        }
        Component.onCompleted: visible = false
    }
    ColumnLayout {
        id: maincolumn
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        width: parent.width * 0.9
        height: parent.height
        Text {
            color: "white"
            height: implicitHeight
            width: implicitWidth
            text: qsTr("KhinsiderDownloader QT")
            font.pointSize: 25
        }
        Text {
            color: "white"
            height: implicitHeight
            width: implicitWidth
            text: qsTr("Thanks to:")
            font.pointSize: 15
        }
        Rectangle {
            color: "#6C98C4"
            width: parent.width
            Layout.preferredHeight: parent.height * 0.6
            Layout.fillWidth: true
            radius: 10
            FocusScope {
                id: contributorsListScope
                anchors.fill: parent
                activeFocusOnTab: true
                property int selectedContributorIndex: -1

                function focusContributor(index) {
                    if (contributorsModel.count <= 0) {
                        return;
                    }
                    var boundedIndex = Math.max(0, Math.min(index, contributorsModel.count - 1));
                    selectedContributorIndex = boundedIndex;
                    var item = contributorsRepeater.itemAt(boundedIndex);
                    if (item) {
                        item.forceActiveFocus();
                    }
                }

                Accessible.role: Accessible.List
                Accessible.name: "Contributors"
                Accessible.description: "Contributors list. Use Up and Down arrows to review entries."
                Accessible.focusable: true
                Accessible.focused: activeFocus

                onActiveFocusChanged: {
                    if (activeFocus && contributorsModel.count > 0) {
                        focusContributor(selectedContributorIndex >= 0 ? selectedContributorIndex : 0);
                    }
                }

                Keys.onUpPressed: {
                    focusContributor((selectedContributorIndex >= 0 ? selectedContributorIndex : contributorsModel.count) - 1);
                    event.accepted = true;
                }
                Keys.onDownPressed: {
                    focusContributor((selectedContributorIndex >= 0 ? selectedContributorIndex : -1) + 1);
                    event.accepted = true;
                }
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Home) {
                        focusContributor(0);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_End) {
                        focusContributor(contributorsModel.count - 1);
                        event.accepted = true;
                    }
                }

                WScrollView {
                    id: scrollView
                    anchors.fill: parent

                    XmlListModel {
                        id: contributorsModel
                        source: "qrc:/CONTRIBUTORS.xml"
                        query: "/contributors/contributor"

                        XmlListModelRole {
                            name: "username"; elementName: "username"
                        }
                        XmlListModelRole {
                            name: "contributionType"; elementName: "contributionType"
                        }
                    }

                    Column {
                        id: column
                        width: parent.width
                        height: parent.height
                        spacing: 5

                        Repeater {
                            id: contributorsRepeater
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            width: parent.width
                            model: contributorsModel

                            Rectangle {
                                width: scrollView.width
                                height: contributorRow.height + 10
                                color: "transparent"
                                radius: 6
                                activeFocusOnTab: false
                                property bool isSelected: index === contributorsListScope.selectedContributorIndex
                                border.width: activeFocus ? 2 : (isSelected ? 1 : 0)
                                border.color: activeFocus ? "#ffffff" : (isSelected ? "#d0ecff" : "transparent")

                                Accessible.role: Accessible.ListItem
                                Accessible.name: username + ", " + contributionType
                                Accessible.description: "Contributor " + (index + 1) + " of " + contributorsModel.count + ". " + (isSelected ? "Selected" : "Not selected")
                                Accessible.focusable: true
                                Accessible.focused: activeFocus
                                Accessible.selectable: true
                                Accessible.selected: isSelected

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        contributorsListScope.selectedContributorIndex = index;
                                    }
                                }

                                Keys.onUpPressed: {
                                    contributorsListScope.focusContributor(index - 1);
                                    event.accepted = true;
                                }
                                Keys.onDownPressed: {
                                    contributorsListScope.focusContributor(index + 1);
                                    event.accepted = true;
                                }
                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Home) {
                                        contributorsListScope.focusContributor(0);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_End) {
                                        contributorsListScope.focusContributor(contributorsModel.count - 1);
                                        event.accepted = true;
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        contributorsListScope.focusContributor(index);
                                    }
                                }

                                RowLayout {
                                    id: contributorRow
                                    width: scrollView.width

                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        Layout.leftMargin: 10
                                        text: username
                                        color: "white"
                                        font.pointSize: 13
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Item {

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        Layout.rightMargin: 10
                                        text: contributionType
                                        color: "white"
                                        font.pointSize: 13
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight * 2
            Text {
                Layout.fillWidth: true
                font.pointSize: 16
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: "Version: " + app.aboutController.appVersion
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                text: "<a href=\"https://weesp.in\">Weespin</a> 2025"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                textFormat: Text.RichText
                color: "white"
                onLinkActivated: Qt.openUrlExternally(link)
                font.pointSize: 16
                activeFocusOnTab: true

                Accessible.role: Accessible.Link
                Accessible.name: "Open Weespin website"
                Accessible.focusable: true
                Accessible.focused: activeFocus

                Keys.onReturnPressed: {
                    Qt.openUrlExternally("https://weesp.in");
                    event.accepted = true;
                }
                Keys.onEnterPressed: {
                    Qt.openUrlExternally("https://weesp.in");
                    event.accepted = true;
                }
                Keys.onSpacePressed: {
                    Qt.openUrlExternally("https://weesp.in");
                    event.accepted = true;
                }
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: parent.activeFocus ? 2 : 0
                    border.color: parent.activeFocus ? "#ffffff" : "transparent"
                    radius: 4
                }
            }
        }

    }
}
