import QtQuick
import QtQuick.Dialogs
import "../shared"
import QtQml
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls
Rectangle {
    id: root
    color: "#2c3e50"
    height: 700
    width: 400
    property string logDirectoryPath: ""
    Accessible.role: Accessible.Pane
    Accessible.name: "Settings panel"
    Accessible.description: "Configure download path, logging, performance, and content preferences."
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
    Component.onCompleted: {
        if (app.logController && app.logController.logDir) {
            root.logDirectoryPath = app.logController.logDir;
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
                border.width: downloadPathText.activeFocus ? 2 : 0
                border.color: downloadPathText.activeFocus ? "#ffffff" : "transparent"

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

                    Keys.onReturnPressed: (event) => {
                        root.openLocalFolder(app.settings.downloadPath);
                        event.accepted = true;
                    }
                    Keys.onEnterPressed: (event) => {
                        root.openLocalFolder(app.settings.downloadPath);
                        event.accepted = true;
                    }
                    Keys.onSpacePressed: (event) => {
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
                accessibleDescription: "Open a folder picker to choose where downloads are saved."
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
                        Accessible.role: Accessible.StaticText
                        Accessible.name: "Enable logging"
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
                        Accessible.description: root.logDirectoryPath
                        Accessible.focusable: true
                        Accessible.focused: activeFocus

                        Keys.onReturnPressed: (event) => {
                            root.openLocalFolder(root.logDirectoryPath);
                            event.accepted = true;
                        }
                        Keys.onEnterPressed: (event) => {
                            root.openLocalFolder(root.logDirectoryPath);
                            event.accepted = true;
                        }
                        Keys.onSpacePressed: (event) => {
                            root.openLocalFolder(root.logDirectoryPath);
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
                                root.openLocalFolder(root.logDirectoryPath);
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: openLogPathText.activeFocus ? 2 : 0
                            border.color: openLogPathText.activeFocus ? "#ffffff" : "transparent"
                            radius: 4
                        }
                    }
                }


            }
            WEnumButton {
                height: parent.height
                width: parent.parent.width * 0.25
                fontSize: 13
                accessibleName: "Enable logging"
                accessibleDescription: "Turn detailed log output on or off."
                onSelectionChanged:
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
            Rectangle {
                id: downloadThreadsControl
                height: parent.height
                width: parent.width * 0.25
                radius: 107
                color: downloadThreadsField.activeFocus ? "#5a87b3" : "#6c98c4"
                border.width: downloadThreadsField.activeFocus ? 2 : 0
                border.color: downloadThreadsField.activeFocus ? "#ffffff" : "transparent"

                function clampValue(number) {
                    return Math.max(1, Math.min(64, number));
                }
                function commitValue(number) {
                    var next = clampValue(number);
                    if (app.settings.downloadThreads !== next) {
                        app.settings.setDownloadThreads(next);
                    }
                    downloadThreadsField.text = String(next);
                    if (downloadThreadsField.activeFocus) {
                        downloadThreadsField.selectAll();
                    }
                }

                Accessible.role: Accessible.SpinBox
                Accessible.name: "Download threads " + downloadThreadsField.text
                Accessible.description: "Number of download worker threads."

                Connections {
                    target: app.settings
                    function onDownloadThreadsChanged() {
                        var valueText = String(app.settings.downloadThreads);
                        if (!downloadThreadsField.activeFocus || downloadThreadsField.text !== valueText) {
                            downloadThreadsField.text = valueText;
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        color: "white"
                        text: "-"
                        font.pointSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Accessible.ignored: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                downloadThreadsField.forceActiveFocus();
                                var parsed = parseInt(downloadThreadsField.text, 10);
                                if (isNaN(parsed)) {
                                    parsed = app.settings.downloadThreads;
                                }
                                downloadThreadsControl.commitValue(parsed - 1);
                            }
                        }
                    }

                    TextField {
                        id: downloadThreadsField
                        width: parent.width * 0.6
                        height: parent.height
                        text: String(app.settings.downloadThreads)
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 13
                        selectByMouse: false
                        activeFocusOnTab: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 64 }
                        background: Rectangle { color: "transparent" }
                        Accessible.name: "Download threads " + text
                        Accessible.description: "Number of download worker threads."

                        onEditingFinished: {
                            var parsed = parseInt(text, 10);
                            if (isNaN(parsed)) {
                                parsed = app.settings.downloadThreads;
                            }
                            downloadThreadsControl.commitValue(parsed);
                        }

                        Keys.onPressed: (event) => {
                            var parsed = parseInt(text, 10);
                            if (isNaN(parsed)) {
                                parsed = app.settings.downloadThreads;
                            }
                            if (event.key === Qt.Key_Up || event.key === Qt.Key_Right) {
                                downloadThreadsControl.commitValue(parsed + 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Left) {
                                downloadThreadsControl.commitValue(parsed - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Home) {
                                downloadThreadsControl.commitValue(1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_End) {
                                downloadThreadsControl.commitValue(64);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_PageUp) {
                                downloadThreadsControl.commitValue(parsed + 10);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_PageDown) {
                                downloadThreadsControl.commitValue(parsed - 10);
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        color: "white"
                        text: "+"
                        font.pointSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Accessible.ignored: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                downloadThreadsField.forceActiveFocus();
                                var parsed = parseInt(downloadThreadsField.text, 10);
                                if (isNaN(parsed)) {
                                    parsed = app.settings.downloadThreads;
                                }
                                downloadThreadsControl.commitValue(parsed + 1);
                            }
                        }
                    }
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
            Rectangle {
                id: concurrentDownloadsControl
                height: parent.height
                width: parent.width * 0.25
                radius: 107
                color: concurrentDownloadsField.activeFocus ? "#5a87b3" : "#6c98c4"
                border.width: concurrentDownloadsField.activeFocus ? 2 : 0
                border.color: concurrentDownloadsField.activeFocus ? "#ffffff" : "transparent"

                function clampValue(number) {
                    return Math.max(0, Math.min(256, number));
                }
                function commitValue(number) {
                    var next = clampValue(number);
                    if (app.settings.maxConcurrentDownloadsPerThread !== next) {
                        app.settings.setMaxConcurrentDownloadsPerThread(next);
                    }
                    concurrentDownloadsField.text = String(next);
                    if (concurrentDownloadsField.activeFocus) {
                        concurrentDownloadsField.selectAll();
                    }
                }

                Accessible.role: Accessible.SpinBox
                Accessible.name: "Concurrent downloads per thread " + concurrentDownloadsField.text
                Accessible.description: "Maximum simultaneous album downloads per worker thread."

                Connections {
                    target: app.settings
                    function onMaxConcurrentDownloadsPerThreadChanged() {
                        var valueText = String(app.settings.maxConcurrentDownloadsPerThread);
                        if (!concurrentDownloadsField.activeFocus || concurrentDownloadsField.text !== valueText) {
                            concurrentDownloadsField.text = valueText;
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        color: "white"
                        text: "-"
                        font.pointSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Accessible.ignored: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                concurrentDownloadsField.forceActiveFocus();
                                var parsed = parseInt(concurrentDownloadsField.text, 10);
                                if (isNaN(parsed)) {
                                    parsed = app.settings.maxConcurrentDownloadsPerThread;
                                }
                                concurrentDownloadsControl.commitValue(parsed - 1);
                            }
                        }
                    }

                    TextField {
                        id: concurrentDownloadsField
                        width: parent.width * 0.6
                        height: parent.height
                        text: String(app.settings.maxConcurrentDownloadsPerThread)
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 13
                        selectByMouse: false
                        activeFocusOnTab: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0; top: 256 }
                        background: Rectangle { color: "transparent" }
                        Accessible.name: "Concurrent downloads per thread " + text
                        Accessible.description: "Maximum simultaneous album downloads per worker thread."

                        onEditingFinished: {
                            var parsed = parseInt(text, 10);
                            if (isNaN(parsed)) {
                                parsed = app.settings.maxConcurrentDownloadsPerThread;
                            }
                            concurrentDownloadsControl.commitValue(parsed);
                        }

                        Keys.onPressed: (event) => {
                            var parsed = parseInt(text, 10);
                            if (isNaN(parsed)) {
                                parsed = app.settings.maxConcurrentDownloadsPerThread;
                            }
                            if (event.key === Qt.Key_Up || event.key === Qt.Key_Right) {
                                concurrentDownloadsControl.commitValue(parsed + 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Left) {
                                concurrentDownloadsControl.commitValue(parsed - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Home) {
                                concurrentDownloadsControl.commitValue(0);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_End) {
                                concurrentDownloadsControl.commitValue(256);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_PageUp) {
                                concurrentDownloadsControl.commitValue(parsed + 10);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_PageDown) {
                                concurrentDownloadsControl.commitValue(parsed - 10);
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        color: "white"
                        text: "+"
                        font.pointSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Accessible.ignored: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                concurrentDownloadsField.forceActiveFocus();
                                var parsed = parseInt(concurrentDownloadsField.text, 10);
                                if (isNaN(parsed)) {
                                    parsed = app.settings.maxConcurrentDownloadsPerThread;
                                }
                                concurrentDownloadsControl.commitValue(parsed + 1);
                            }
                        }
                    }
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
                    text: "Audio Quality"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            WEnumButton {
                height: parent.height
                width: parent.width * 0.25
                fontSize: 13
                accessibleName: "Audio quality"
                accessibleDescription: "Preferred quality when a format choice is available."
                onSelectionChanged:
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
                accessibleDescription: "Choose whether to download album cover artwork."
                onSelectionChanged:
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
                accessibleDescription: "Skip songs that already exist in the destination folder."
                onSelectionChanged:
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
                accessibleDescription: "Check GitHub for a newer app release."
                onClicked:
                {
                    app.aboutController.checkForUpdates();
                }
                label: "Run Check"
            }
        }

    }
}
