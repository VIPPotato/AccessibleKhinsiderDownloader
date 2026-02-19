import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout{
    id:col
    width:300
    height:300
    property int imageIndex: 0
    property int imageTarget : 0
    property var imageSources: app.searchController.albumInfoVM.albumImages
    activeFocusOnTab: true

    Accessible.role: Accessible.Pane
    Accessible.name: "Album artwork viewer"
    Accessible.description: "Use previous and next image buttons to switch artwork."

    Keys.onLeftPressed: {
        if (col.imageSources.length > 1) {
            col.imageTarget--;
            fadeOut.start();
        }
        event.accepted = true;
    }
    Keys.onRightPressed: {
        if (col.imageSources.length > 1) {
            col.imageTarget++;
            fadeOut.start();
        }
        event.accepted = true;
    }

    Connections {
        target: app.searchController.albumInfoVM
        function onCurrentAlbumChanged()
        {
            col.imageIndex = 0
            col.imageTarget = 0
            fadeOut.start()
            if(app.searchController.albumInfoVM.currentAlbum.isInfoParsed)
            {
                blur.radius = 0;
            }
            else
            {
                blur.radius = 30;
            }
        }
    }
    Item {
       Layout.fillHeight: true
       Layout.fillWidth: true
        Image {
            SequentialAnimation {
                id: fadeIn
                NumberAnimation { target: blur; property: "opacity"; to: 1; duration: 100 }
                NumberAnimation { target: profileImage; property: "opacity"; to: 1; duration: 100 }
            }
            SequentialAnimation {
                id: fadeOut
                NumberAnimation { target: blur; property: "opacity"; to: 0; duration: 100 }
                NumberAnimation { target: profileImage; property: "opacity"; to: 0; duration: 100 }
                onStopped:
                {
                    if (col.imageSources.length === 0) {
                        col.imageIndex = 0;
                        col.imageTarget = 0;
                        fadeIn.start();
                        return;
                    }
                    //wrap imageTarget
                    if(imageTarget < 0)
                    {
                        imageTarget = col.imageSources.length - 1;
                    }

                    col.imageIndex = (imageTarget) % col.imageSources.length;
                    fadeIn.start();
                    imageTarget = col.imageIndex;
                }
            }
            cache: true
            id: profileImage
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            source: col.imageSources.length > 0 ? col.imageSources[col.imageIndex] : "qrc:/icons/albumplaceholder.jpg"
            //source: "icons/albumplaceholder.jpg"
            fillMode: Image.PreserveAspectFit
            Accessible.ignored: true

        }
        Rectangle {
            id: blur
            anchors.fill: profileImage
            color: "#8c2c3e50"
            radius: 30
            visible: radius > 0
            opacity: visible ? 1 : 0
            Behavior on radius {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
        BusyIndicator {
            id: busyIndicator
            anchors.fill: profileImage
            running: {
                if (!app.searchController.albumInfoVM.currentAlbum)
                    return false;
                return !app.searchController.albumInfoVM.currentAlbum.isInfoParsed || profileImage.progress !== 1;
            }
            Accessible.role: Accessible.StaticText
            Accessible.name: running ? "Loading album artwork" : "Album artwork loaded"
            Accessible.ignored: !visible
        }
    }

    Rectangle {
        color: "#6C98C4"
        width: parent.width * 0.8
        radius: 10
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        height: 45
        Row
        {
            id: row
            height: parent.height
            width:parent.width
            AlbumImageCaretButton {
                width: parent.width*0.2
                height: parent.height
                mirror: false
                accessibleName: "Previous album image"
                accessibleDescription: "Show the previous artwork image."
                onRequestImageChange:
                {
                    if(col.imageSources.length > 1)
                    {
                        col.imageTarget--;
                        fadeOut.start();
                    }
                }
            }
            Text {
                id:indextextlabel
                property string _text: "0/0";
                text: _text

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.DemiBold
                font.bold: false
                textFormat: Text.AutoText
                font.pointSize: 16
                width: parent.width*0.6
                height: parent.height
                color: "#ffffff"

                Accessible.role: Accessible.StaticText
                Accessible.name: "Artwork index"
                Accessible.description: text
                SequentialAnimation {
                    id: fadeTextOut
                    NumberAnimation { target: indextextlabel; property: "opacity"; to: 0; duration: 50 }
                    onStopped: {
                        // Update the text after the fade-out
                        indextextlabel._text = col.imageSources.length > 0 ? (col.imageIndex + 1) + "/" + col.imageSources.length : "0/0"
                        fadeTextIn.start()  // Start the fade-in animation
                    }
                }

                SequentialAnimation {
                    id: fadeTextIn
                    NumberAnimation { target: indextextlabel; property: "opacity"; to: 1; duration: 50 }
                }
                function checkAndFade()
                {

                    if ((col.imageIndex + 1) + "/" + col.imageSources.length !== indextextlabel._text)
                    {
                        fadeTextOut.start();
                    }
                    }
                Connections
                {
                    target: col
                    function onImageSourcesChanged()
                    {
                        indextextlabel.checkAndFade();
                    }
                    function onImageIndexChanged()
                    {
                          indextextlabel.checkAndFade();
                    }

                }
            }
            AlbumImageCaretButton
            {
                width: parent.width*0.2
                height: parent.height
                accessibleName: "Next album image"
                accessibleDescription: "Show the next artwork image."
                onRequestImageChange:
                {
                    if(col.imageSources.length > 1)
                    {
                        col.imageTarget++;
                        fadeOut.start();
                    }
                }
            }
        }

    }
}

