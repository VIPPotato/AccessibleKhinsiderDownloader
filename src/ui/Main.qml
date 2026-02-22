import QtQuick 2.15
import QtQuick.Window 2.15
import "shared"
import "search"
import "settings"
import "download"
import "about"
import QtQuick.Dialogs
import QtQuick.Layouts
Window {
    id: window
    width: 1000
    height: 600
    onHeightChanged: {
        if(maincol.state === "abouttab")
        {
            //TODO: Meh solution
            slider.jump(leftaboutbutton);
        }
    }
    minimumHeight: 600
    minimumWidth: 1000
    visible: true
    color: "#2c3e50"
    title: qsTr("Khinsider Downloader - QT")
    function setActiveTab(targetState, button) {
        maincol.state = targetState;
        slider.jump(button);
        button.forceActiveFocus();
    }
    Keys.onPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            if (event.key === Qt.Key_1) {
                setActiveTab("downloadtab", leftdownloadbutton);
                event.accepted = true;
            } else if (event.key === Qt.Key_2) {
                setActiveTab("searchtab", leftsearchbutton);
                event.accepted = true;
            } else if (event.key === Qt.Key_3) {
                setActiveTab("settingstab", leftsettingsbutton);
                event.accepted = true;
            } else if (event.key === Qt.Key_4) {
                setActiveTab("abouttab", leftaboutbutton);
                event.accepted = true;
            }
        }
    }
    Component.onCompleted: {
        slider.jump(leftdownloadbutton);
        leftdownloadbutton.forceActiveFocus();
    }

    Column {
        id: maincol
        state: "downloadtab"
        Accessible.role: Accessible.Pane
        Accessible.name: "Khinsider Downloader"
        Accessible.description: "Main application view. Use Ctrl+1 for Download, Ctrl+2 for Search, Ctrl+3 for Settings, and Ctrl+4 for About."
        states: [
            State {
                name: "downloadtab" //centerPanel

                PropertyChanges { target: downloadPanel; visible:true }
                PropertyChanges { target: settingsPanel; visible:false }
                PropertyChanges { target: searchPanel; visible: false}
                PropertyChanges { target: aboutPanel; visible:false }
            },
            State {
                name: "searchtab"

                PropertyChanges { target: searchPanel; visible:true }
                PropertyChanges { target: settingsPanel; visible:false }
                PropertyChanges { target: downloadPanel; visible: false}
                PropertyChanges { target: aboutPanel; visible:false }
            },
            State {
                name: "settingstab"

                PropertyChanges { target: settingsPanel; visible:true }
                PropertyChanges { target: downloadPanel; visible:false }
                PropertyChanges { target: searchPanel; visible: false}
                PropertyChanges { target: aboutPanel; visible:false }
            },
            State {
                name: "abouttab"

                PropertyChanges { target: aboutPanel; visible:true }
                PropertyChanges { target: downloadPanel; visible:false }
                PropertyChanges { target: searchPanel; visible: false}
                PropertyChanges { target: settingsPanel; visible: false}
            }
        ]
        anchors.fill: parent
        spacing: 0
        // Header
        //Rectangle {
        //    width: parent.width
        //    height: parent.height * 0.05
        //    color: "#34495e"
        //    Text {
        //        anchors.fill: parent
        //        anchors.leftMargin: 10
        //        text: "KhinsiderDownloader 🎵"
        //        color: "white"
        //        font.pixelSize: 20
        //        horizontalAlignment: Text.AlignLeft
        //        verticalAlignment: Text.AlignVCenter
        //    }
        //}
        Row {
            width: parent.width
            height: parent.height * 1
            spacing: 0
            Rectangle {
                id: leftPanel
                width: 100
                Layout.minimumWidth: 100
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                height: parent.height
                color: "#34495e"
                Rectangle{
                    Behavior on y {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                    x: leftdownloadbutton.x
                    y: leftdownloadbutton.y - (leftdownloadbutton.height * 0.2)
                    width: leftdownloadbutton.width
                    height: leftdownloadbutton.height + (leftdownloadbutton.height * 0.4)
                    id:slider
                    color: "#2c3e50"
                    function jump(id)
                    {
                        var offset = id.height * 0.2;
                        slider.y = id.y - offset;
                        slider.x = id.x;
                        slider.width = id.width;
                        slider.height = id.height + (offset * 2);
                    }

                }


                ColumnLayout {
                    id: column
                    width: parent.width
                    height: parent.height
                    spacing: 20
                    Item {
                        Layout.preferredHeight: 10
                    }

                    SideButton {
                        id: leftdownloadbutton
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignTop
                        iconFallback: "../../icons/dl.svg"
                        iconSource: "qrc:/icons/dl.svg"
                        label: "Download"
                        accessibleName: maincol.state === "downloadtab" ? "Download tab, selected" : "Download tab"
                        accessibleDescription: "Open the download queue and bulk URL import tools."
                        onClicked: {
                            window.setActiveTab("downloadtab", leftdownloadbutton);
                        }

                    }

                    SideButton {
                        id: leftsearchbutton
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignTop
                        iconFallback: "../../icons/search.svg"
                        iconSource: "qrc:/icons/search.svg"
                        label: "Search"
                        accessibleName: maincol.state === "searchtab" ? "Search tab, selected" : "Search tab"
                        accessibleDescription: "Search albums and add them to the download queue."
                        onClicked: {
                            window.setActiveTab("searchtab", leftsearchbutton);
                        }
                    }

                    SideButton {
                        id: leftsettingsbutton
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignTop
                        iconFallback: "../../icons/settings.svg"
                        iconSource: "qrc:/icons/settings.svg"
                        label: "Settings"
                        accessibleName: maincol.state === "settingstab" ? "Settings tab, selected" : "Settings tab"
                        accessibleDescription: "Configure app behavior and download preferences."
                        onClicked: {
                            window.setActiveTab("settingstab", leftsettingsbutton);
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    SideButton {
                        id: leftaboutbutton
                        Layout.preferredHeight: 45
                        Layout.alignment: Qt.AlignBottom
                        iconFallback: "../../icons/about.svg"
                        iconSource: "qrc:/icons/about.svg"
                        label: "About"
                        accessibleName: maincol.state === "abouttab" ? "About tab, selected" : "About tab"
                        accessibleDescription: "View version, contributors, and update information."
                        onClicked: {
                            window.setActiveTab("abouttab", leftaboutbutton);
                        }
                    }
                    Item {
                        Layout.preferredHeight: 5
                    }
                }
            }
            // Center panel
            Rectangle {
                id: centerPanel
                width: parent.width - leftPanel.width
                Layout.fillWidth: true
                Layout.fillHeight: true
                height: parent.height
                color: "transparent"
                SearchPanel
                {
                    id: searchPanel;
                    width: parent.width
                    height: parent.height
                }
                SettingsPanel
                {
                    id: settingsPanel;
                    width: parent.width
                    height: parent.height
                }
                DownloadPanel
                {
                    id: downloadPanel;
                    width: parent.width
                    height: parent.height
                }
                AboutPanel
                {
                    id: aboutPanel;
                    width: parent.width
                    height: parent.height
                }
            }
        }
    }
}
