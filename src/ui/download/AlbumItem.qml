import QtQuick 2.15
import QtQuick.Layouts

Item {
    id: root
    state: "errored"

    signal cancelRequested()
    signal retryRequested()
    property var donwloadedSongs
    property var totalSongs
    property var speedInBytes
    property bool showActionOverlay: hoverArea.containsMouse || activeFocus || retryButton.activeFocus || deleteButton.activeFocus

    property alias progress: percentageBar.percentage
    property alias label: albumName.text

    height: 50
    width: 400
    activeFocusOnTab: true

    Accessible.role: Accessible.ListItem
    Accessible.name: albumName.text
    Accessible.description: "State: " + root.state + ". Progress " + percentageBar.percentage + " percent. " + filesLabel.text + ". " + downloadStatus.text + ". Press Delete to cancel or R to retry when available."
    Accessible.focusable: true
    Accessible.focused: activeFocus

    function formatSpeed(bytesPerSecond) {
        if (bytesPerSecond >= 1024 * 1024) {
            return (bytesPerSecond / (1024 * 1024)).toFixed(2) + " MB/s";
        } else if (bytesPerSecond >= 1024) {
            return (bytesPerSecond / 1024).toFixed(2) + " KB/s";
        } else {
            return bytesPerSecond + " B/s";
        }
    }
    function requestCancel() {
        if (!enabled) {
            return;
        }
        cancelRequested();
    }
    function requestRetry() {
        if (!enabled || !retryButton.visible) {
            return;
        }
        retryRequested();
    }

    onDonwloadedSongsChanged: {
        filesLabel.text = "Files: " + donwloadedSongs + "/" + totalSongs;
    }
    onSpeedInBytesChanged: {
        downloadStatus.text = "Speed: " + formatSpeed(speedInBytes);
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
            requestCancel();
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            requestRetry();
            event.accepted = true;
        }
    }

    states: [
        State {
            name: "downloading"
            PropertyChanges { target: percentageBar; color:"#4CAF50" }
            PropertyChanges { target: mainRect; color:"#6C98C4" }
            PropertyChanges { target: percentageLabel; visible: true}
            PropertyChanges { target: downloadStatus; visible: true }
            PropertyChanges { target: filesLabel; visible: true }
            PropertyChanges { target: retryButton; visible: false }

        },
        State {
            name: "unparsed"
            PropertyChanges { target: percentageBar; color:"transparent" }
            PropertyChanges { target: mainRect; color:"#FFA000" }
            PropertyChanges { target: percentageLabel; visible: false}
            PropertyChanges { target: downloadStatus; visible: false }
            PropertyChanges { target: filesLabel; visible: false }
            PropertyChanges { target: retryButton; visible: false }

        },
        State {
            name: "parsed"
            PropertyChanges { target: percentageBar; color:"transparent" }
            PropertyChanges { target: mainRect; color:"#6C98C4" }
            PropertyChanges { target: percentageLabel; visible: false}
            PropertyChanges { target: downloadStatus; visible: true }
            PropertyChanges { target: filesLabel; visible: true }
            PropertyChanges { target: retryButton; visible: false }

        },
        State {
            name: "errored"
            PropertyChanges { target: percentageBar; color:"transparent" }
            PropertyChanges { target: mainRect; color:"#D32F2F" }
            PropertyChanges { target: percentageLabel; visible: false}
            PropertyChanges { target: downloadStatus; visible: false }
            PropertyChanges { target: filesLabel; visible: true }
            PropertyChanges { target: retryButton; visible: true }

        }
    ]

    Rectangle {
        id: mainRect
        color: "#6C98C4"
        width: parent.width
        height: parent.height
        radius: 20
        border.width: root.activeFocus ? 2 : 0
        border.color: root.activeFocus ? "#ffffff" : "transparent"

        MouseArea {
            id: hoverArea
            width: parent.width
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.forceActiveFocus();
            }
        }

        Rectangle {
            property int percentage
            id: percentageBar
            color: "#4CAF50"
            width: (percentageBar.percentage / 100) * mainRect.width
            height: parent.height
            radius: 20

            onPercentageChanged: {
                percentageBar.width = (percentageBar.percentage / 100) * mainRect.width;
            }

            Behavior on width {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Row {
            id: downloaderRow
            width: parent.width
            height: parent.height
            visible: !root.showActionOverlay

            Text {
                id: albumName
                width: parent.width * 0.75
                height: parent.height
                text: model.name
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                color: "white"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 7
                font.bold: false
                font.pointSize: 14
            }

            Text {
                id: percentageLabel
                width: parent.width * 0.25
                height: parent.height
                text: percentageBar.percentage + "%"
                color: "white"
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                rightPadding: 10
                font.bold: false
                font.pointSize: 14
            }
        }

        Rectangle {
            id: darkOverlay
            visible: root.showActionOverlay
            width: parent.width
            height: parent.height
            color: "#bc000000"

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.95
                height: parent.height

                RowLayout {
                    spacing: 10
                    width: parent.width
                    height: parent.height

                    Text {
                        id: filesLabel
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.preferredWidth: Math.min(implicitWidth, parent.width * 0.4)
                        Layout.maximumWidth: parent.width * 0.4
                        text: "Files: 0/0"
                        elide: Text.ElideRight
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 14
                    }

                    Text {
                        id: downloadStatus
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.preferredWidth: Math.min(implicitWidth, parent.width * 0.4)
                        Layout.maximumWidth: parent.width * 0.4
                        text: "Speed: 0 B/s"
                        elide: Text.ElideRight
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 14
                    }

                    Image {
                        id: retryButton
                        Layout.preferredWidth: 60 * 0.5
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        visible: true
                        property string iconFallback: "qrc:/icons/retry.svg"
                        source: "../../../icons/retry.svg"
                        fillMode: Image.PreserveAspectFit
                        activeFocusOnTab: visible

                        Accessible.role: Accessible.Button
                        Accessible.name: "Retry album download"
                        Accessible.focusable: visible
                        Accessible.focused: activeFocus

                        Keys.onReturnPressed: {
                            root.requestRetry();
                            event.accepted = true;
                        }
                        Keys.onEnterPressed: {
                            root.requestRetry();
                            event.accepted = true;
                        }
                        Keys.onSpacePressed: {
                            root.requestRetry();
                            event.accepted = true;
                        }

                        MouseArea {
                            hoverEnabled: false
                            width: parent.width
                            height: parent.height
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.requestRetry();
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: retryButton.activeFocus ? 2 : 0
                            border.color: retryButton.activeFocus ? "#ffffff" : "transparent"
                            radius: 5
                        }

                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = iconFallback;
                            }
                        }
                    }

                    Image {
                        id: deleteButton
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: parent.height * 0.8
                        Layout.fillHeight: true
                        visible: true
                        property string iconFallback: "qrc:/icons/delete.svg"
                        source: "../../../icons/delete.svg"
                        Layout.rightMargin: 5
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                        fillMode: Image.PreserveAspectFit
                        activeFocusOnTab: visible

                        Accessible.role: Accessible.Button
                        Accessible.name: "Cancel album download"
                        Accessible.focusable: visible
                        Accessible.focused: activeFocus

                        Keys.onReturnPressed: {
                            root.requestCancel();
                            event.accepted = true;
                        }
                        Keys.onEnterPressed: {
                            root.requestCancel();
                            event.accepted = true;
                        }
                        Keys.onSpacePressed: {
                            root.requestCancel();
                            event.accepted = true;
                        }

                        MouseArea {
                            hoverEnabled: false
                            width: parent.width
                            height: parent.height
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.requestCancel();
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: deleteButton.activeFocus ? 2 : 0
                            border.color: deleteButton.activeFocus ? "#ffffff" : "transparent"
                            radius: 5
                        }

                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = iconFallback;
                            }
                        }
                    }
                }
            }
        }
    }
}
