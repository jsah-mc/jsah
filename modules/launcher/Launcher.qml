import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "root:/"

Scope {
    id: root

    property var applications: []
    property int appsLoaded: 0

    // Load apps immediately on startup
    Component.onCompleted: {
        loadApps.running = true
    }

    // IPC Handler to toggle launcher
    IpcHandler {
        target: "launcher"
        
        function toggle(): void {
            launcher.visible = !launcher.visible
        }
        
        function show(): void {
            launcher.visible = true
        }
        
        function hide(): void {
            launcher.visible = false
        }
    }

    // Load applications - faster version with parallel processing
    Process {
        id: loadApps
        command: ["sh", "-c", `
            # Use awk for faster parsing - single pass through files
            for file in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null; do
                [ -f "$file" ] || continue
                awk -F= '
                    /^Name=/ && !name {name=$2}
                    /^Exec=/ && !exec {exec=$2}
                    /^Icon=/ && !icon {icon=$2}
                    /^NoDisplay=true/ {skip=1}
                    END {
                        if (!skip && name && exec) {
                            gsub(/%[uUfFick]/, "", exec)
                            gsub(/^[ \\t]+|[ \\t]+$/, "", exec)
                            print name "|" exec "|" icon
                        }
                    }
                ' "$file"
            done | head -150
        `]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim().length === 0) return
                
                const parts = data.split('|')
                if (parts.length >= 2) {
                    applications.push({
                        name: parts[0],
                        exec: parts[1],
                        icon: parts[2] || ""
                    })
                    appsLoaded++
                }
            }
        }

        onExited: {
            console.log(`Loaded ${appsLoaded} applications`)
            applications = applications
        }
    }

    PanelWindow {
        id: launcher
        visible: false
        
        width: 600
        height: 500
        
        color: "transparent"
        
        anchors {
            top: false
            bottom: false
            left: false
            right: false
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        property string searchText: ""

        property var filteredApps: {
            if (searchText.length === 0) return applications
            return applications.filter(app => 
                app.name.toLowerCase().includes(searchText)
            )
        }

        function launchApp(exec) {
            console.log("Launching:", exec)
            Qt.createQmlObject(`
                import Quickshell.Io
                Process {
                    command: ["sh", "-c", "${exec.replace(/"/g, '\\"').replace(/\$/g, '\\$')}"]
                    running: true
                }
            `, launcher)
            launcher.visible = false
            searchInput.text = ""
        }

        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus()
                searchInput.text = ""
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 40
            height: parent.height - 40
            spacing: 15

            // Search box - separate rounded rectangle
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Theme.get.barBgColor
                radius: 20
                border.color: Theme.get.active
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "🔍"
                        color: "#888888"
                        font.pixelSize: 16
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "white"
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true

                        onTextChanged: {
                            searchText = text.toLowerCase()
                            appList.currentIndex = 0
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                launcher.visible = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                appList.currentIndex = Math.min(appList.currentIndex + 1, appList.count - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appList.currentIndex >= 0 && appList.currentIndex < filteredApps.length) {
                                    launchApp(filteredApps[appList.currentIndex].exec)
                                }
                                event.accepted = true
                            }
                        }

                        Text {
                            visible: parent.text.length === 0
                            text: "Type to search..."
                            color: "#888888"
                            font: parent.font
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Application list - separate rounded rectangle
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.get.barBgColor
                radius: 20
                border.color: Theme.get.active
                border.width: 2

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    ListView {
                        id: appList
                        model: filteredApps
                        spacing: 5
                        currentIndex: 0

                        Text {
                            visible: appList.count === 0
                            anchors.centerIn: parent
                            text: applications.length === 0 ? "Loading applications..." : "No applications found"
                            color: "#888888"
                            font.pixelSize: 14
                        }

                        delegate: Rectangle {
                            required property int index
                            required property var modelData

                            width: appList.width
                            height: 50
                            color: appList.currentIndex === index ? Theme.get.active : (appMouseArea.containsMouse ? Theme.get.buttonBackgroundColor : "transparent")
                            radius: 20

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 15

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    color: "#313244"
                                    radius: 16

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.name.substring(0, 1).toUpperCase()
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: "white"
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.exec
                                        color: "#888888"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        visible: false  // Hide exec by default
                                    }
                                }
                            }

                            MouseArea {
                                id: appMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    appList.currentIndex = index
                                    launchApp(modelData.exec)
                                }

                                onEntered: appList.currentIndex = index
                            }
                        }
                    }
                }

                // Footer with count
                Text {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 15
                    text: `${filteredApps.length} application${filteredApps.length !== 1 ? 's' : ''}`
                    color: "#888888"
                    font.pixelSize: 12
                }
            }
        }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: launcher.visible = false
        }
    }
}