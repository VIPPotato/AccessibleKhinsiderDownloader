import QtQuick 2.15

Item {
    id: root
    width: 100
    height: 100
    property var iconFallback: "qrc:/icons/about.svg";
    property string accessibleName: labelText.text
    property string accessibleDescription: ""

    // Default properties
    property alias iconSource: icon.source
    property alias label: labelText.text
    signal clicked();
    signal loaded();
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.description: accessibleDescription
    Accessible.focusable: enabled
    Accessible.focused: activeFocus

    function activateButton() {
        if (!enabled) {
            return;
        }
        root.clicked();
    }

    Keys.onReturnPressed: {
        activateButton();
        event.accepted = true;
    }
    Keys.onEnterPressed: {
        activateButton();
        event.accepted = true;
    }
    Keys.onSpacePressed: {
        activateButton();
        event.accepted = true;
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 8
        border.width: root.activeFocus ? 2 : 0
        border.color: root.activeFocus ? "#ffffff" : "transparent"
    }

    MouseArea
    {
        anchors.fill:parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked:
        {
            root.activateButton();
        }
    }
    Column {
        width: parent.width
        height: parent.height
        spacing: 0

        Image {
            id: icon
            width:parent.width
            height: parent.height * 0.7
            source:  "../../../icons/about.svg" // default icon
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            Accessible.ignored: true
            onStatusChanged: {
                  if (status === Image.Error) {
                      source = iconFallback;
                  }
                  if(status === Image.Ready)
                  {
                      loaded();
                  }
            }
        }

        Text {
            id: labelText
            text: "Default" // default label
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            Accessible.ignored: true
        }

    }
}
