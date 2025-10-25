import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../"
import "root:/"

BarBlock {
  id: root
  Layout.preferredWidth: 20

  content: BarText {
    text: "󰣇"
    pointSize: 12
    anchors.horizontalCenterOffset: 5
    anchors.verticalCenterOffset: 0
  }

  color: "transparent"
}