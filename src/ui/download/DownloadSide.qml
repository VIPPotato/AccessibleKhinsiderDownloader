import QtQuick 2.15
import QtQuick.Controls
import "../shared"
Rectangle
{
       color: "#34495E"
       id:root
       height: 800
       width: 600
       property int selectedQueueIndex: app.downloaderController.downloaderVM.selectedQueueIndex
       function selectQueueIndex(index) {
              app.downloaderController.downloaderVM.setSelectedQueueIndex(index);
       }

       Accessible.role: Accessible.Pane
       Accessible.name: "Download queue panel"
       Accessible.description: "Shows queued albums and live download status. Use Tab for retry or cancel actions on the selected album."

       WScrollView
       {
              id: scrollView

              width: parent.width
              height: parent.height * 0.9
              anchors.top: parent.top
              anchors.topMargin: 10
              anchors.bottom: s.top
              clip: true

              FocusScope {
                     id: queueListScope
                     width: root.width * 0.92
                     height: root.height
                     activeFocusOnTab: true
                     property int focusedQueueIndex: -1

                     Accessible.role: Accessible.List
                     Accessible.name: "Download queue"
                     Accessible.description: "Use Up and Down arrows to move between queue items. Use Page Up and Page Down to jump and type letters to move by album name. Press Ctrl+R to retry the selected album. Press Delete to cancel the selected album."
                     Accessible.focusable: true
                     Accessible.focused: activeFocus
                     property string typeAheadBuffer: ""

                     function itemCount() {
                            return queueRepeater.count;
                     }

                     function clampIndex(index) {
                            if (itemCount() === 0) {
                                   return -1;
                            }
                            if (index < 0) {
                                   return 0;
                            }
                            if (index >= itemCount()) {
                                   return itemCount() - 1;
                            }
                            return index;
                     }

                     function focusQueueItem(index) {
                            var targetIndex = clampIndex(index);
                            if (targetIndex < 0) {
                                   focusedQueueIndex = -1;
                                   root.selectQueueIndex(-1);
                                   return false;
                            }
                            var item = queueRepeater.itemAt(targetIndex);
                            if (!item) {
                                   return false;
                            }
                            focusedQueueIndex = targetIndex;
                            root.selectQueueIndex(targetIndex);
                            item.forceActiveFocus();
                            return true;
                     }
                     function pageStep() {
                            if (queueRepeater.count <= 0) {
                                   return 1;
                            }
                            var firstItem = queueRepeater.itemAt(0);
                            var itemHeight = firstItem ? (firstItem.height + 5) : 50;
                            return Math.max(1, Math.floor(scrollView.height / Math.max(1, itemHeight)) - 1);
                     }
                     function findQueueIndexByPrefix(prefix, startIndex) {
                            if (!prefix || prefix.length === 0 || queueRepeater.count <= 0) {
                                   return -1;
                            }
                            var needle = prefix.toLowerCase();
                            var start = Math.max(0, Math.min(startIndex, queueRepeater.count - 1));
                            for (var offset = 0; offset < queueRepeater.count; offset++) {
                                   var idx = (start + offset) % queueRepeater.count;
                                   var item = queueRepeater.itemAt(idx);
                                   if (!item || !item.label) {
                                          continue;
                                   }
                                   if (item.label.toLowerCase().indexOf(needle) === 0) {
                                          return idx;
                                   }
                            }
                            return -1;
                     }
                     function clearTypeAhead() {
                            typeAheadBuffer = "";
                            typeAheadResetTimer.stop();
                     }
                     function handleTypeAheadInput(character) {
                            if (!character || character.length === 0) {
                                   return;
                            }
                            if (typeAheadResetTimer.running) {
                                   typeAheadBuffer += character;
                            } else {
                                   typeAheadBuffer = character;
                            }
                            typeAheadResetTimer.restart();

                            var start = focusedQueueIndex >= 0 ? focusedQueueIndex + 1 : 0;
                            var match = findQueueIndexByPrefix(typeAheadBuffer, start);
                            if (match < 0 && typeAheadBuffer.length > 1) {
                                   typeAheadBuffer = character;
                                   match = findQueueIndexByPrefix(typeAheadBuffer, start);
                            }
                            if (match >= 0) {
                                   focusQueueItem(match);
                            }
                     }

                     onActiveFocusChanged: {
                            if (activeFocus && queueRepeater.count > 0) {
                                   var target = root.selectedQueueIndex >= 0 ? root.selectedQueueIndex : (focusedQueueIndex >= 0 ? focusedQueueIndex : 0);
                                   focusQueueItem(target);
                            }
                     }

                     Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Up) {
                                   focusQueueItem((focusedQueueIndex >= 0 ? focusedQueueIndex : 0) - 1);
                                   event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                   focusQueueItem((focusedQueueIndex >= 0 ? focusedQueueIndex : -1) + 1);
                                   event.accepted = true;
                            } else if (event.key === Qt.Key_Home) {
                                   focusQueueItem(0);
                                   event.accepted = true;
                            } else if (event.key === Qt.Key_End) {
                                   focusQueueItem(queueRepeater.count - 1);
                                   event.accepted = true;
                            } else if (event.key === Qt.Key_PageUp) {
                                   focusQueueItem((focusedQueueIndex >= 0 ? focusedQueueIndex : 0) - pageStep());
                                   event.accepted = true;
                            } else if (event.key === Qt.Key_PageDown) {
                                   focusQueueItem((focusedQueueIndex >= 0 ? focusedQueueIndex : -1) + pageStep());
                                   event.accepted = true;
                            } else if ((event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)
                                       && event.text
                                       && event.text.length === 1
                                       && /[0-9A-Za-z]/.test(event.text)) {
                                   handleTypeAheadInput(event.text.toLowerCase());
                                   event.accepted = true;
                            }
                     }

                     Column
                     {
                            width: parent.width
                            height: parent.height
                            leftPadding: 10
                            spacing:5

                            Repeater
                            {
                                   id: queueRepeater
                                   height: parent.height
                                   model: app.downloaderController.downloaderVM
                                   width : parent.width
                                   onCountChanged: {
                                          if (count === 0) {
                                                 queueListScope.focusedQueueIndex = -1;
                                                 root.selectQueueIndex(-1);
                                                 queueListScope.clearTypeAhead();
                                          } else if (queueListScope.focusedQueueIndex >= count) {
                                                 queueListScope.focusedQueueIndex = count - 1;
                                                 root.selectQueueIndex(queueListScope.focusedQueueIndex);
                                          }
                                   }
                                   delegate: AlbumItem
                                   {
                                          progress: model.progress
                                          state: model.state
                                          height: 45
                                          label: model.name
                                          width : parent.width
                                          donwloadedSongs: model.downloadedSongs
                                          totalSongs: model.totalSongs
                                          speedInBytes: model.speed
                                          selected: root.selectedQueueIndex === model.index
                                          activeFocusOnTab: false
                                          onActiveFocusChanged: {
                                                 if (activeFocus) {
                                                        queueListScope.focusedQueueIndex = model.index;
                                                        root.selectQueueIndex(model.index);
                                                 }
                                          }
                                          onCancelRequested:
                                          {
                                                 app.downloaderController.downloaderVM.cancelAlbum(model.index)
                                          }
                                          onRetryRequested :
                                          {
                                                 app.downloaderController.downloaderVM.retryAlbum(model.index);
                                          }
                                   }
                            }

                     }
              }

              Timer {
                     id: typeAheadResetTimer
                     interval: 750
                     repeat: false
                     onTriggered: {
                            queueListScope.typeAheadBuffer = "";
                     }
              }
       }
       Item
       {
              id: s
              width: parent.width
              height: parent.height * 0.1
              anchors.bottom: parent.bottom
              Rectangle {
                     width: parent.width
                     height: 1
              }
              Column
              {
                     width: parent.width
                     height: parent.height
                     spacing: 4

                     Row {
                            width: parent.width
                            height: (parent.height - parent.spacing) * 0.5
                            Text {
                            id: speedText
                            height: parent.height
                            width: parent.width/2
                            text: "";
                            color: "#ffffff"
                            opacity: 0
                            font.pointSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Accessible.role: Accessible.StaticText
                            Accessible.name: "Total download speed"
                            Accessible.description: text
                            function formatSpeed(bytesPerSecond) {
                                   if (bytesPerSecond >= 1024 * 1024) {
                                          return (bytesPerSecond / (1024 * 1024)).toFixed(2) + " MB/s";
                                   } else if (bytesPerSecond >= 1024) {
                                          return (bytesPerSecond / 1024).toFixed(2) + " KB/s";
                                   } else {
                                          return bytesPerSecond + " B/s";
                                   }
                            }
                            Behavior on opacity {
                                 NumberAnimation {
                                     duration: 100
                                     easing.type: Easing.InOutQuad
                                 }
                             }
                            Connections {
                                   target: app.downloaderController.downloaderVM
                                   function onTotalsChanged()
                                   {
                                          var shouldShowAnyData = app.downloaderController.downloaderVM.totalSongs() !== 0 ? 1 : 0;
                                          speedText.opacity = shouldShowAnyData ? 1 : 0;
                                          if(shouldShowAnyData)
                                          {
                                                 speedText.text = speedText.formatSpeed(app.downloaderController.downloaderVM.totalSpeed());
                                          }
                                   }
                            }
                            }


                            Text {
                            id: downloadedSizeText
                            height: parent.height
                            width: parent.width/2
                            font.pointSize: 16
                            color: "#ffffff"
                            opacity: 0
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Accessible.role: Accessible.StaticText
                            Accessible.name: "Downloaded songs"
                            Accessible.description: text
                            Behavior on opacity {
                                 NumberAnimation {
                                     duration: 100
                                     easing.type: Easing.InOutQuad
                                 }
                             }
                            Connections {
                                   target: app.downloaderController.downloaderVM
                                   function onTotalsChanged()
                                   {
                                          var shouldShowAnyData = app.downloaderController.downloaderVM.totalSongs() !== 0 ? 1 : 0;
                                          downloadedSizeText.opacity = shouldShowAnyData ? 1 : 0;
                                          if(shouldShowAnyData)
                                          {
                                                 downloadedSizeText.text = app.downloaderController.downloaderVM.totalDownloadedSongs()
                                                               + "/" + app.downloaderController.downloaderVM.totalSongs();
                                          }
                                   }
                            }
                            }
                     }

                     Row {
                            width: parent.width
                            height: (parent.height - parent.spacing) * 0.5
                            spacing: 8

                            WButton {
                                   width: (parent.width - parent.spacing * 3) / 2
                                   height: parent.height - 4
                                   label: "Retry Selected"
                                   enabled: app.downloaderController.downloaderVM.hasSelectedQueueItem()
                                   accessibleName: "Retry selected album download"
                                   accessibleDescription: "Retry the currently selected album in the queue."
                                   onClicked: {
                                          app.downloaderController.downloaderVM.retrySelectedAlbum();
                                   }
                            }

                            WButton {
                                   width: (parent.width - parent.spacing * 3) / 2
                                   height: parent.height - 4
                                   label: "Cancel Selected"
                                   enabled: app.downloaderController.downloaderVM.hasSelectedQueueItem()
                                   accessibleName: "Cancel selected album download"
                                   accessibleDescription: "Cancel and remove the currently selected album in the queue."
                                   onClicked: {
                                          app.downloaderController.downloaderVM.cancelSelectedAlbum();
                                   }
                            }
                     }
              }


       }
}

