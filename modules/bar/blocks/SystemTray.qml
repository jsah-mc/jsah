import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "root:/modules/bar"

RowLayout {
    spacing: 5
    anchors.leftMargin: 20
    property bool trayExpanded: false    // controls expanded/collapsed state


    // Tray items (expandable)
    RowLayout {
        id: trayItems
        spacing: 5
        visible: trayExpanded    // only visible when expanded

        Repeater {
            model: ScriptModel {
                values: [...SystemTray.items.values]
                    .filter(item => item.id !== "spotify-client" && item.id !== "chrome_status_icon_1")
            }

            MouseArea {
                id: delegate
                required property SystemTrayItem modelData
                property alias item: delegate.modelData

                Layout.fillHeight: true
                implicitWidth: icon.implicitWidth + 5

                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true

                onClicked: event => {
                    if (event.button == Qt.LeftButton) {
                        item.activate();
                    } else if (event.button == Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (event.button == Qt.RightButton) {
                        menuAnchor.open();
                    }
                }

                onWheel: event => {
                    event.accepted = true;
                    const points = event.angleDelta.y / 120
                    item.scroll(points, false);
                }

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    source: item.icon
                    implicitSize: 16
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: item.menu

                    anchor.window: delegate.QsWindow.window
                    anchor.adjustment: PopupAdjustment.Flip

                    anchor.onAnchoring: {
                        const window = delegate.QsWindow.window;
                        const widgetRect = window.contentItem.mapFromItem(delegate, 0, delegate.height, delegate.width, delegate.height);

                        menuAnchor.anchor.rect = widgetRect;
                    }
                }

                Tooltip {
                    relativeItem: delegate.containsMouse ? delegate : null

                    Label {
                        text: delegate.item.tooltipTitle || delegate.item.id
                    }
                }
            }
        }
    }
        // Toggle button for expand/collapse
    Rectangle {
        width: 20
        height: 20
        radius: 4
        color: 'transparent'
        
        // border.color: "#aaaaaa"
        // border.width: 1

        Text {
            anchors.centerIn: parent
            text: trayExpanded ? "󰄠" : "󰄝"   // arrow indicates state
            font.pixelSize: 14
            color: "#ffffff"
            rotation: 90 
        }

        MouseArea {
            anchors.fill: parent
            onClicked: trayExpanded = !trayExpanded
            cursorShape: Qt.PointingHandCursor
        }
    }

}
