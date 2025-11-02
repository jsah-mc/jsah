import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../utils" as Utils
import "root:/"

RowLayout {
    property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    Rectangle {
        id: workspaceBar
        Layout.preferredWidth: Math.max(50, Utils.HyprlandUtils.maxWorkspace * 25)
        Layout.preferredHeight: 23
        radius: 20
        color: "transparent"
        opacity: 0.95

        // Margin around the bar
        anchors.fill: parent
        anchors.leftMargin: 7

        Row {
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: Utils.HyprlandUtils.maxWorkspace || 1

                Rectangle {
                    required property int index
                    property bool focused: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
                    property bool occupied: Utils.HyprlandUtils.isWorkspaceOccupied(index + 1)

                    // --- Shape and color ---
                    width: focused ? 32 : 10
                    height: 10
                    radius: height / 2
                    
                    color: focused
                        ? Theme.get.active
                        : Theme.get.iconColor
                    opacity: focused || occupied ? 1.0 : 0.6

                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                    // Pac-Man icon for focused, dot for inactive
                    Text {
                        anchors.centerIn: parent
                        text: focused ? "󰮯" : "•"
                        font.pixelSize: focused ? 12 : 8
                        color: focused ? Theme.get.barBgColor : "#ffffff"
                        opacity: focused || occupied ? 1.0 : 0.7
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: Utils.HyprlandUtils.switchWorkspace(index + 1)

                        onEntered: parent.color = Theme.get.iconPressedColor
                        onExited: parent.color = focused
                            ? Theme.get.active
                            : Theme.get.iconColor
                    }
                }
            }
        }

        // Optional soft drop shadow
        layer.enabled: Theme.get.buttonBorderShadow
        layer.effect: DropShadow {
            radius: 6
            samples: 12
            color: "#66000000"
            horizontalOffset: 0
            verticalOffset: 2
        }
    }
}
