import QtQuick 2.15

Rectangle {
    signal valueChanged();
    property int selectedIndex: 0
    property alias model: internalModel
    property string accessibleName: "Option selector"
    property string accessibleDescription: ""

    function resetModel(newItems, newIndex) {
        internalModel.clear();

        for (let i = 0; i < newItems.length; i++) {
            internalModel.append({text: newItems[i]});
        }

        if (newIndex !== undefined) {
            selectedIndex = newIndex;
        } else if (selectedIndex >= internalModel.count) {
            selectedIndex = 0;
        }

        updateLabelText();
    }

    function updateLabelText() {
        if (internalModel.count > 0 && selectedIndex < internalModel.count) {
            buttonlabel.text = internalModel.get(selectedIndex).text;
        }
    }
    function cycleNext() {
        if (!enabled || internalModel.count === 0) {
            return;
        }
        fadeOut.start();
    }
    function cyclePrevious() {
        if (!enabled || internalModel.count === 0) {
            return;
        }
        selectedIndex = (selectedIndex - 1 + internalModel.count) % internalModel.count;
        valueChanged();
        fadeIn.start();
    }

    onSelectedIndexChanged: updateLabelText()

    ListModel {
        id: internalModel
        ListElement { text: "First";}
        ListElement { text: "Second";}
    }

    property alias fontSize: buttonlabel.font.pointSize
    property alias label: buttonlabel.text
    id: buttonRect
    width: 40
    radius: 107
    height: 40
    color: mouseArea.containsMouse || activeFocus ? "#5a87b3" : "#6c98c4"
    scale: 1.0
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? "#ffffff" : "transparent"
    activeFocusOnTab: true

    Accessible.role: Accessible.ComboBox
    Accessible.name: accessibleName
    Accessible.description: (accessibleDescription.length > 0
                             ? accessibleDescription
                             : "Use Enter, Space, or arrow keys to change option.")
                            + " Current value: " + buttonlabel.text
    Accessible.focusable: enabled
    Accessible.focused: activeFocus

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    SequentialAnimation {
        id: shrinkAnim
        NumberAnimation { target: buttonRect; property: "scale"; to: 0.96; duration: 100 }
    }

    SequentialAnimation {
        id: growAnim
        NumberAnimation { target: buttonRect; property: "scale"; to: 1.0; duration: 100 }
    }

    SequentialAnimation {
        id: fadeIn
        NumberAnimation { target: buttonlabel; property: "opacity"; to: 1; duration: 100 }
    }

    SequentialAnimation {
        id: fadeOut
        NumberAnimation { target: buttonlabel; property: "opacity"; to: 0; duration: 100 }
        onStopped: {
            buttonRect.selectedIndex = (buttonRect.selectedIndex + 1) % internalModel.count;
            valueChanged();
            fadeIn.start();
        }
    }

    Keys.onReturnPressed: {
        cycleNext();
        event.accepted = true;
    }
    Keys.onEnterPressed: {
        cycleNext();
        event.accepted = true;
    }
    Keys.onSpacePressed: {
        cycleNext();
        event.accepted = true;
    }
    Keys.onUpPressed: {
        cycleNext();
        event.accepted = true;
    }
    Keys.onRightPressed: {
        cycleNext();
        event.accepted = true;
    }
    Keys.onDownPressed: {
        cyclePrevious();
        event.accepted = true;
    }
    Keys.onLeftPressed: {
        cyclePrevious();
        event.accepted = true;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: buttonRect.enabled
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            shrinkAnim.running = true
        }
        onReleased: {
            growAnim.running = true
        }
        onClicked: {
            cycleNext();
        }
    }

    Text {
        id: buttonlabel
        color: "white"
        text: ""
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 10
        Accessible.ignored: true
    }

    Component.onCompleted: {
        updateLabelText();
    }
}
