import QtQuick 2.15

Rectangle {
    id: root

    property int maxNumber: 1000
    property int minNumber: 0
    property int currentNumber: 0
    property int nextNumber: currentNumber
    property int value: currentNumber
    property string accessibleName: "Number selector"
    property string accessibleDescription: ""
    signal numberChanged()

    width: parent ? parent.width * 0.5 : 120
    height: 40
    radius: 107
    color: mouseArea.containsMouse || activeFocus ? "#5a87b3" : "#6c98c4"
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? "#ffffff" : "transparent"
    activeFocusOnTab: true

    function clampNumber(number) {
        return Math.max(minNumber, Math.min(maxNumber, number));
    }

    function setNumber(number) {
        var clamped = clampNumber(number);
        if (clamped === currentNumber) {
            if (nextNumber !== clamped) {
                nextNumber = clamped;
            }
            if (value !== clamped) {
                value = clamped;
            }
            return;
        }

        currentNumber = clamped;
        nextNumber = clamped;
        value = clamped;
        Accessible.valueChanged();
        numberChanged();
    }

    function increaseValue() {
        if (!enabled) {
            return;
        }
        setNumber(currentNumber + 1);
    }

    function decreaseValue() {
        if (!enabled) {
            return;
        }
        setNumber(currentNumber - 1);
    }

    onCurrentNumberChanged: {
        if (value !== currentNumber) {
            value = currentNumber;
        }
        if (nextNumber !== currentNumber) {
            nextNumber = currentNumber;
        }
    }

    onNextNumberChanged: {
        if (nextNumber !== currentNumber) {
            setNumber(nextNumber);
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
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
            setNumber(minNumber);
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            setNumber(maxNumber);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            setNumber(currentNumber + 10);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageDown) {
            setNumber(currentNumber - 10);
            event.accepted = true;
        }
    }

    Accessible.role: Accessible.SpinBox
    Accessible.name: accessibleName + " " + currentNumber
    Accessible.description: accessibleDescription.length > 0
                            ? accessibleDescription
                            : "Range from " + minNumber + " to " + maxNumber + ". Use arrow keys, Home, End, Page Up, or Page Down."
    Accessible.focusable: enabled
    Accessible.focused: activeFocus

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

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
                    root.forceActiveFocus();
                    root.increaseValue();
                }
            }
        }

        Text {
            width: parent.width * 0.6
            height: parent.height
            color: "white"
            text: root.currentNumber
            font.pointSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Accessible.ignored: true
        }

        Text {
            width: parent.width * 0.2
            height: parent.height
            color: "white"
            text: "-"
            font.pointSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Accessible.ignored: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.forceActiveFocus();
                    root.decreaseValue();
                }
            }
        }
    }
}
