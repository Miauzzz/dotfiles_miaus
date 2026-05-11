import Quickshell
import QtQuick

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true

    margins.left: (screen.width / 2) - 150
    margins.right: (screen.width / 2) - 150

    height: 36
    color: "transparent"

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: 10

            delegate: Canvas {
                width: 36
                height: 14

                property bool isActive: index === 0

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.beginPath()
                    ctx.moveTo(6, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width - 6, height)
                    ctx.lineTo(0, height)
                    ctx.closePath()
                    ctx.fillStyle = isActive ? "#38bdf8" : "#c4b5d4"
                    ctx.fill()
                }
            }
        }
    }
}