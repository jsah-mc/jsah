pragma Singleton

import QtQuick
import Quickshell

Singleton {
  property Item get: main

  Item {
    id: main

    // Material Design 3 color palette
    property string barBgColor: "#0C0E14"  // Surface dark
    property string buttonBorderColor: "#16161e"  // Surface variant
    property string buttonBackgroundColor: "transparent"  // Surface variant
    property bool buttonBorderShadow: false
    property bool onTop: true
    property bool showBackground: true
    property string iconColor: "#7aa2f7"  // Primary light
    property string iconPressedColor: "#3d59a1"  // Primary medium
    property string active: "#e0af68"
  }
}
