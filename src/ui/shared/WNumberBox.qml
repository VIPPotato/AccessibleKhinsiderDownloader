import QtQuick 2.15

Rectangle {
    property int maxNumber : 1000
    property int minNumber : 0
    property int currentNumber : 0
    property int nextNumber : 0
    property string accessibleName: "Number selector"
    property string accessibleDescription: ""
    signal valueChanged();
    id: buttonRect
    width: parent.width * 0.5
    radius: 107
    height: 40
    color: mouseArea.containsMouse || activeFocus ? "#5a87b3" : "#6c98c4"
    scale: 1.0
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? "#ffffff" : "transparent"
    activeFocusOnTab: true

    Accessible.role: Accessible.SpinBox
    Accessible.name: accessibleName + " " + currentNumber
    Accessible.description: accessibleDescription.length > 0
                            ? accessibleDescription
                            : "Range from " + minNumber + " to " + maxNumber + ". Use arrow keys, Home, End, Page Up, or Page Down."
    Accessible.focusable: enabled
    Accessible.focused: activeFocus

    function commitNextValue(newValue) {
        nextNumber = Math.max(minNumber, Math.min(maxNumber, newValue));
        if (nextNumber !== currentNumber) {
            fadeOut.start();
        }
    }
    function increaseValue() {
        if (!enabled) {
            return;
        }
        commitNextValue(nextNumber + 1);
    }
    function decreaseValue() {
        if (!enabled) {
            return;
        }
        commitNextValue(nextNumber - 1);
    }
    onCurrentNumberChanged: {
        if (nextNumber !== currentNumber) {
            nextNumber = currentNumber;
        }
        if (activeFocus || plus.activeFocus || minus.activeFocus) {
            Accessible.valueChanged();
        }
    }

    Keys.onUpPressed: {
        increaseValue();
        event.accepted = true;
    }
    Keys.onRightPressed: {
        increaseValue();
        event.accepted = true;
    }
    Keys.onDownPressed: {
        decreaseValue();
        event.accepted = true;
    }
    Keys.onLeftPressed: {
        decreaseValue();
        event.accepted = true;
    }
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Home) {
            commitNextValue(minNumber);
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            commitNextValue(maxNumber);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            commitNextValue(nextNumber + 10);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageDown) {
            commitNextValue(nextNumber - 10);
            event.accepted = true;
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    SequentialAnimation {
        id: fadeIn
        NumberAnimation { target: buttonlabel; property: "opacity"; to: 1; duration: 75 }
    }
    SequentialAnimation {
        id: fadeOut
        NumberAnimation { target: buttonlabel; property: "opacity"; to: 0; duration: 75 }
        onStopped:
        {
            currentNumber = nextNumber;
            valueChanged();
            fadeIn.start()
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: buttonRect.enabled
        cursorShape: Qt.PointingHandCursor
    }
    Row
    {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        WNumberBoxButton
        {
            id: plus
            y:-4
            height: parent.height
            isPlus: true
            width: parent.width * 0.2
            onInvoked: {
                buttonRect.increaseValue();
            }

        }
        Text
        {
            y:-2
            height: parent.height
            width: parent.width * 0.6
            color:"white"
            id: buttonlabel
            text: currentNumber
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
            Accessible.ignored: true
        }
        WNumberBoxButton
        {
            y:-4
            id:minus
            font.pointSize: 30
            height: parent.height
            width: parent.width * 0.2
            onInvoked: {
                buttonRect.decreaseValue();
            }
        }
    }


}
