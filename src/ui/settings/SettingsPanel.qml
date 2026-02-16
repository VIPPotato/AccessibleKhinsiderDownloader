import QtQuick
import QtQuick.Dialogs
import "../shared"
import QtQml
import QtQuick.Layouts
import QtQuick
Rectangle {
    id: root
    color: "#2c3e50"
    height: 700
    width: 400
    function openLocalFolder(path) {
        if (!path || path.length === 0) {
            return;
        }
        if (Qt.platform.os === "windows") {
            Qt.openUrlExternally("file:///" + path);
        } else {
            Qt.openUrlExternally("file://" + path);
        }
    }

    FolderDialog {
        id: folderDialog

        currentFolder: app.settings.downloadPath
        selectedFolder: app.settings.downloadPath

        onAccepted: {
            app.settings.setDownloadPath(selectedFolder);
        }
    }
    Column {
        id:maincolumn
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        topPadding: 10
        width: parent.width * 0.9

        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.width * 0.7

                Text {
                    id: downloadPathText
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Path: " + app.settings.downloadPath
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    activeFocusOnTab: true

                    Accessible.role: Accessible.Link
                    Accessible.name: "Open download path in file browser"
                    Accessible.description: app.settings.downloadPath
                    Accessible.focusable: true
                    Accessible.focused: activeFocus

                    Keys.onReturnPressed: {
                        root.openLocalFolder(app.settings.downloadPath);
                        event.accepted = true;
                    }
                    Keys.onEnterPressed: {
                        root.openLocalFolder(app.settings.downloadPath);
                        event.accepted = true;
                    }
                    Keys.onSpacePressed: {
                        root.openLocalFolder(app.settings.downloadPath);
                        event.accepted = true;
                    }
                    MouseArea
                    {
                        anchors.fill: parent;
                        cursorShape: Qt.PointingHandCursor
                        onClicked:
                        {
                            root.openLocalFolder(app.settings.downloadPath);
                        }
                    }
                }
            }
            WButton {
                fontSize: 12

                height: parent.height
                label: "Select Path"
                accessibleName: "Select download path"
                width: parent.width * 0.25

                onClicked: {
                    folderDialog.open();
                }
            }
        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.parent.width * 0.7
                RowLayout
                {
                    id: logrow
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    Text {

                        color: "#ffffff"
                        font.pointSize: 12
                        text: "Enable Logging"
                        verticalAlignment: Text.AlignVCenter
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        id: openLogPathText
                        color: "#99ffffff"
                        font.pointSize: 12
                        text: "Open Log Path"
                        verticalAlignment: Text.AlignVCenter
                        activeFocusOnTab: true

                        Accessible.role: Accessible.Link
                        Accessible.name: "Open log folder in file browser"
                        Accessible.description: app.logController.logDir
                        Accessible.focusable: true
                        Accessible.focused: activeFocus

                        Keys.onReturnPressed: {
                            root.openLocalFolder(app.logController.logDir);
                            event.accepted = true;
                        }
                        Keys.onEnterPressed: {
                            root.openLocalFolder(app.logController.logDir);
                            event.accepted = true;
                        }
                        Keys.onSpacePressed: {
                            root.openLocalFolder(app.logController.logDir);
                            event.accepted = true;
                        }
                        MouseArea
                        {
                            width: parent.width
                            height: logrow.height
                            y: logrow.y - parent.y
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                root.openLocalFolder(app.logController.logDir);
                            }
                        }
                    }
                }


            }
            WEnumButton {
                height: parent.height
                width: parent.parent.width * 0.25
                fontSize: 13
                accessibleName: "Enable logging"
                onValueChanged:
                {
                    app.settings.setEnableLogging(selectedIndex != 0);
                }
                selectedIndex: app.settings.enableLogging ? 0 : 1;
                Component.onCompleted:
                {
                    resetModel(["False", "True"], app.settings.enableLogging);
                }
            }
        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.width * 0.7

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Threads"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            WNumberBox {
                height: parent.height
                currentNumber: app.settings.downloadThreads
                nextNumber: app.settings.downloadThreads
                accessibleName: "Download threads"
                onValueChanged:
                {
                    app.settings.setDownloadThreads(currentNumber);
                }
                maxNumber: 64
                minNumber: 1
                width: parent.width * 0.25
            }

        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.width * 0.7

                RowLayout
                {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    Text
                    {
                        color: "#ffffff"
                        font.pointSize: 12
                        text: "Concurrent downloads per thread"
                        verticalAlignment: Text.AlignVCenter
                    }
                    Item
                    {
                        Layout.fillWidth: true
                    }
                    Text {
                        color: "#99ffffff"
                        font.pointSize: 12
                        text: "0 = no limit (recommended)"
                        verticalAlignment: Text.AlignVCenter

                    }
                }
            }
            WNumberBox {
                height: parent.height
                currentNumber: app.settings.maxConcurrentDownloadsPerThread
                nextNumber: app.settings.maxConcurrentDownloadsPerThread
                accessibleName: "Concurrent downloads per thread"
                onValueChanged:
                {
                    app.settings.setMaxConcurrentDownloadsPerThread(currentNumber);
                }
                maxNumber: 256
                minNumber: 0
                width: parent.width * 0.25
            }

        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.width * 0.7

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Audio Quality"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            WEnumButton {
                height: parent.height
                width: parent.width * 0.25
                fontSize: 13
                accessibleName: "Audio quality"
                onValueChanged:
                {
                    app.settings.setPreferredAudioQualityInt(selectedIndex);
                }
                selectedIndex: app.settings.preferredAudioQuality;
                Component.onCompleted:
                {
                    resetModel(["MP3", "Best"], app.settings.preferredAudioQuality);
                }
            }
        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: parent.height
                radius: 10
                width: parent.width * 0.7

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Download Art Covers"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            WEnumButton
            {
                height: parent.height
                width: parent.width * 0.25
                fontSize: 13
                accessibleName: "Download art covers"
                onValueChanged:
                {
                    app.settings.setDownloadArt(selectedIndex != 0);
                }
                selectedIndex: app.settings.downloadArt ? 0 : 1;
                Component.onCompleted:
                {
                    resetModel([ "False", "True"], app.settings.downloadArt);
                }

            }


        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: 40
                radius: 10
                width: maincolumn.width * 0.7

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8

                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Skip Downloaded"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            WEnumButton
            {
                height: parent.height
                width: parent.width * 0.25
                fontSize: 13
                accessibleName: "Skip downloaded files"
                onValueChanged:
                {
                    app.settings.setSkipDownloaded(selectedIndex != 0);
                }
                selectedIndex: app.settings.skipDownloaded ? 0 : 1;
                Component.onCompleted:
                {
                    resetModel(["False", "True"], app.settings.skipDownloaded);
                }

                //True false
            }
        }
        Row {
            height: 40
            spacing: 10
            width: parent.width

            Rectangle {
                color: "#6c98c4"
                height: 40
                radius: 10
                width: maincolumn.width * 0.7

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8

                    color: "#ffffff"
                    font.pointSize: 12
                    text: "Check for Updates"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            WButton
            {
                height: parent.height
                width: parent.width * 0.25
                fontSize: 13
                accessibleName: "Check for updates"
                onClicked:
                {
                    app.aboutController.checkForUpdates();
                }
                label: "Run Check"
            }
        }

    }
}
