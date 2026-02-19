import QtQuick 2.15

Rectangle {
    id: buttonRect

    signal clicked();
    property alias label: buttonlabel.text

    property alias fontSize : buttonlabel.font.pointSize
    property string accessibleName: buttonlabel.text
    property string accessibleDescription: ""
    color: mouseArea.containsMouse || activeFocus ? "#5a87b3" : "#6c98c4"
    height: 40
    //width: parent.width * 0.5
    radius: 107
    scale: 1.0
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? "#ffffff" : "transparent"
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.description: accessibleDescription
    Accessible.focusable: enabled
    Accessible.focused: activeFocus

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    SequentialAnimation {
        id: shrinkAnim

        NumberAnimation {
            duration: 100
            property: "scale"
            target: buttonRect
            to: 0.96
        }
    }
    SequentialAnimation {
        id: growAnim

        NumberAnimation {
            duration: 100
            property: "scale"
            target: buttonRect
            to: 1.0
        }
    }
    function activateButton() {
        if (!enabled) {
            return;
        }
        shrinkAnim.restart();
        growAnim.restart();
        buttonRect.clicked();
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: buttonRect.enabled
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            shrinkAnim.running = true;
        }
        onReleased: {
            growAnim.running = true;
        }
        onClicked:
        {
            buttonRect.activateButton();
        }
    }
    Text {
        id: buttonlabel

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        elide: Text.ElideRight
        font.pointSize: 16
        horizontalAlignment: Text.AlignHCenter
        text: "Add FLAC"
        verticalAlignment: Text.AlignVCenter
        Accessible.ignored: true
    }
}
