import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "blocks" as Blocks
import "root:/"

Scope {
    IpcHandler {
        target: "bar"

        function toggleVis(): void {
            // Toggle visibility of all bar instances
            for (let i = 0; i < Quickshell.screens.length; i++) {
                barInstances[i].visible = !barInstances[i].visible;
            }
        }
    }

    property var barInstances: []

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData
            screen: modelData

            Component.onCompleted: {
                barInstances.push(bar);
            }

            color: 'transparent'
            height: 40 // slightly taller to allow spacing
            visible: true

            anchors {
                top: Theme.get.onTop
                bottom: !Theme.get.onTop
                left: true
                right: true
            }

            Rectangle {
                id: highlight
                anchors.fill: parent
                radius: 20
                color: Theme.get.showBackground ? Theme.get.buttonBackgroundColor : 'transparent'
                anchors {
                    fill: parent
                    topMargin: 3 // top spacing
                    leftMargin: 10 // left spacing
                    rightMargin: 10 // right spacing
                    bottomMargin: 3 // bottom spacing
                }
            }

            // Outer container to apply top/side spacing
            RowLayout {
                id: outerLayout
                anchors {
                    fill: parent
                    topMargin: 5 // top spacing
                    leftMargin: 10 // left spacing
                    rightMargin: 10 // right spacing
                    bottomMargin: 5 // bottom spacing
                }
                spacing: 0

                // === LEFT SIDE ===
                RowLayout {
                    id: leftBlocks
                    spacing: 10
                    Layout.alignment: Qt.AlignLeft

                    Rectangle {
                        id: leftBg
                        radius: 20
                        color: Theme.get.barBgColor
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillHeight: true
                        implicitWidth: leftContent.implicitWidth + 8
                        implicitHeight: leftContent.implicitHeight + 8

                        RowLayout {
                            id: leftContent
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4

                            Blocks.Icon {}
                            Blocks.Workspaces {}
                        }

                        z: -1
                    }
                }

                // Spacer to push active workspace to center
                Item { Layout.fillWidth: true }

                // === CENTER ACTIVE WORKSPACE ===
                Rectangle {
                    id: timeBg
                    color: Theme.get.barBgColor
                    radius: 20
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 100
                    implicitHeight: 30

                    Blocks.Time {
                        id: time
                        anchors.centerIn: parent
                    }
                }

                // Spacer to balance layout
                Item { Layout.fillWidth: true }

                // === RIGHT SIDE ===
                RowLayout {
                    id: rightBlocks
                    spacing: 10
                    Layout.alignment: Qt.AlignRight
                    anchors {
                        rightMargin: 4
                        topMargin: 4
                        bottomMargin: 4
                    }
                    Rectangle {
                        id: rightBg
                        radius: 20
                        color: Theme.get.barBgColor
                        Layout.alignment: Qt.AlignRight
                        Layout.fillHeight: true
                        implicitWidth: rightContent.implicitWidth + 8
                        implicitHeight: rightContent.implicitHeight + 20

                        RowLayout {
                            id: rightContent
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4 
                            //`Blocks.Notifications {}
                            Blocks.SystemTray {}
                            Blocks.Memory {}
                            Blocks.Sound {}
                            Blocks.Battery {}
                            Blocks.Date {}
                        }

                        z: -1
                    }
                }
            }
        }
    }
}
