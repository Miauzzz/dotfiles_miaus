import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

PanelWindow {
  id: border

  color: "transparent"
  WlrLayershell.layer: WlrLayer.Background

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  Rectangle {
    id: borderRect
    anchors.fill: parent
    opacity: 0.75
    gradient: Gradient{
      GradientStop { position: 0.0; color: "#e2edf8"}
      GradientStop { position: 1.0; color: "#f9cfff"}
    }

    layer.enabled: true
    layer.effect: MultiEffect {
      maskSource: mask
      maskEnabled: true
      maskInverted: true
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1
    }
  }

  //Borde interno
  Rectangle {
    anchors.fill: parent
    anchors.leftMargin : 10
    anchors.rightMargin : 10
    anchors.topMargin : 10
    anchors.bottomMargin : 10

    color : "transparent"
    border.width : 2
    border.color : "#426484"
    radius: 15
    opacity: 0.50
  }

  Item {
    id: mask
    anchors.fill: parent
    layer.enabled: true
    visible: false

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      anchors.topMargin: 10
      anchors.bottomMargin: 10
      radius: 15
    }
  }
}