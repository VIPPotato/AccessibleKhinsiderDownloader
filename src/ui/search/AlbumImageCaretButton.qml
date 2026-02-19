import QtQuick

Image {

    signal requestImageChange()
    property string accessibleName: "Change album image"
    property string accessibleDescription: ""
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
        requestImageChange();
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

    SequentialAnimation {
        id: shrinkAnim
        NumberAnimation { target: arrow; property: "scale"; to: 0.96; duration: 100 }
    }

    SequentialAnimation {
        id: resetAnim
        NumberAnimation { target: arrow; property: "scale"; to: 1.0; duration: 100 }
    }
    SequentialAnimation {
        id: growAnim
        NumberAnimation { target: arrow; property: "scale"; to: 1.1; duration: 100 }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: arrow.enabled
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            shrinkAnim.running = true
        }
        onReleased: {
            growAnim.running = true
        }
        onEntered:
        {
            growAnim.running = true
        }
        onExited:
        {
            resetAnim.running = true
        }
        onClicked:
        {
            activateButton();
        }
    }

    id: arrow
    source: "qrc:/icons/arrowleft.svg"
    mirror: true
    fillMode: Image.PreserveAspectFit

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: arrow.activeFocus ? 2 : 0
        border.color: arrow.activeFocus ? "#ffffff" : "transparent"
        radius: 6
    }

}
