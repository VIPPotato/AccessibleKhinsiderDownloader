import QtQuick
import QtQuick.Controls.Basic
import "../shared"
Window {
    width : 400
    height: 300
    minimumHeight: height
    minimumWidth: width
    maximumHeight:height
    maximumWidth: width
    id: window
    visible: true
    color: "#2c3e50"
    modality: Qt.ApplicationModal
    signal accepted
    title: "A new update has been released!"
    Component.onCompleted: okButton.forceActiveFocus()
    Accessible.role: Accessible.Dialog
    Accessible.name: title
    Accessible.description: "A new release is available. Activate OK to open the downloads page."
    Keys.onEscapePressed: {
        window.visible = false;
        event.accepted = true;
    }
    Column
    {
        width: parent.width
        height:parent.height
        Text
        {
            width: parent.width
            height:parent.height * 0.7
            font.pointSize: 20
            color:"white"
            text:"Download the latest version of KhinsiderDownloader!\nClick OK to open the download page"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap

            Accessible.role: Accessible.StaticText
            Accessible.name: text
        }
        WButton
        {
            id: okButton
            anchors.horizontalCenter: parent.horizontalCenter
            width :parent.width * 0.5
            label: "OK"
            accessibleName: "Open downloads page"
            height: parent.height * 0.15
            onClicked:
            {
                accepted();
                window.visible = false;
            }
        }

    }

}
