pragma Singleton

import QtQuick
import Quickshell

Singleton {
  property Item get: main

  Item {
    id: main

    // Material Design 3 color palette
    property string barBgColor: "#11111b"  // Surface dark
    property string buttonBorderColor: "#181825"  // Surface variant
    property string buttonBackgroundColor: "#181825"  // Surface variant
    property bool buttonBorderShadow: false
    property bool onTop: true
    property bool showBackground: false
    property string iconColor: "#90CAF9"  // Primary light
    property string iconPressedColor: "#64B5F6"  // Primary medium
    property string active: "#cba6f7"
  }
}

