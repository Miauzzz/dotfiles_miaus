import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  anchors.top: true
  anchors.left: true
  anchors.right: true

  height: 40  // Aumentado para incluir el espacio del margin
  color: "transparent"

  Rectangle {
    anchors.fill: parent

    // Los margins van aquí
    anchors.topMargin: 0
    anchors.leftMargin: 0
    anchors.rightMargin: 0
    anchors.bottomMargin: 0

    color: "#e2edf8"
    opacity: 0.75
    radius: 0

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      anchors.topMargin: 10
      spacing: 30

      RowLayout {
        spacing: 8

        Repeater {
          model: 9
          delegate: Item {
              required property int index
              property int wsId: index + 1
              property bool isActive: Hyprland.focusedWorkspace?.id === wsId

              width: 36
              height: 14

              Canvas {
                  anchors.fill: parent
                  property bool active: parent.isActive
                  onActiveChanged: requestPaint()

                  onPaint: {
                      var ctx = getContext("2d")
                      ctx.clearRect(0, 0, width, height)
                      ctx.beginPath()
                      ctx.moveTo(6, 0)
                      ctx.lineTo(width, 0)
                      ctx.lineTo(width - 6, height)
                      ctx.lineTo(0, height)
                      ctx.closePath()
                      ctx.fillStyle = active ? "#38bdf8" : "#35477c"
                      ctx.fill()
                  }
              }

              MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: Hyprland.dispatch("workspace", parent.wsId.toString())
              }
          }
        }
      }

      Item { Layout.fillWidth: true }

      Text {
        text: " MiausOS v0.1 - Work in progress "
        color: "#000000"
        font.pixelSize: 11
        font.bold: true
      }
    }
  }
}