import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true

    height: 40
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#e2edf8"
        opacity: 0.75
        radius: 0

        // ── CENTRO: workspaces + texto ──────────────────────
        Column {
            anchors.centerIn: parent
            spacing: 2

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: 9
                    delegate: Item {
                        required property int index
                        property int wsId: index + 1
                        property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                        width: 30
                        height: 11

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

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "우리는 각자의 지옥에서만 행복할 거야"
                color: "#09f"
                font.pixelSize: 11
                font.bold: false
            }
        }

        // ── DERECHA: red + tray + hora ──────────────────────
        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            spacing: 8

            Item {
                id: netRow
                width: netIcon.width + netLabel.width + 4
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                property bool showPublic: false
                property bool hidden: false

                property string privateIp: ""
                property string publicIp: ""
                property string swapTarget: ""

                property var hiddenPhrases: [
                    "7ㅁ6ㅅ9ㅇ4ㅈ1ㅎ8",
                    "ㅁ2ㅅ5ㅇ4ㅈ1ㅎ4ㅋ",
                    "2ㅅ9ㅇ4ㅈ1ㅎ8ㅋ0",
                    "ㅅ1ㅇ4ㅈ1ㅎ8ㅋ7ㅂ",
                    "9ㅇ4ㅈ1ㅎ8ㅋ3ㅂ6",
                    "ㅇ4ㅈ1ㅎ0ㅋ3ㅂ6ㄷ"
                ]
                property int phraseIndex: 0

                function displayedIp() {
                    if (showPublic)
                        return publicIp.length > 0 ? publicIp : "sin respuesta"
                    return privateIp.length > 0 ? privateIp : "sin conexión"
                }

                function refreshLabel() {
                    if (!hidden)
                        netLabel.text = displayedIp()
                }

                function swapTo(target) {
                    swapTarget = target
                    swapTimer.currentIndex = 0
                    swapTimer.running = true
                }

                Timer {
                    id: phraseTimer
                    interval: 1000
                    repeat: true
                    running: false
                    onTriggered: {
                        netRow.phraseIndex = (netRow.phraseIndex + 1) % netRow.hiddenPhrases.length
                        netRow.swapTo(netRow.hiddenPhrases[netRow.phraseIndex])
                    }
                }

                Timer {
                    id: swapTimer
                    property int currentIndex: 0
                    interval: 25
                    repeat: true
                    running: false

                    onTriggered: {
                        var target = netRow.swapTarget
                        var current = netLabel.text
                        var maxLen = Math.max(current.length, target.length)
                        var result = ""

                        for (var i = 0; i < maxLen; i++) {
                            if (i < currentIndex) {
                                result += i < target.length ? target[i] : ""
                            } else {
                                result += i < current.length ? current[i] : ""
                            }
                        }

                        netLabel.text = result
                        currentIndex++

                        if (currentIndex > maxLen) {
                            netLabel.text = target
                            running = false
                        }
                    }
                }

                onHiddenChanged: {
                    if (hidden) {
                        phraseIndex = 0
                        swapTo(hiddenPhrases[phraseIndex])
                        phraseTimer.restart()
                    } else {
                        phraseTimer.stop()
                        swapTo(displayedIp())
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: netIcon
                        color: "#1a2a4a"
                        font.pixelSize: 10
                        font.bold: true
                        text: "..."
                    }

                    Text {
                        id: netLabel
                        color: "#1a2a4a"
                        font.pixelSize: 12
                        font.family: "monospace"
                        text: "..."
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            netRow.showPublic = !netRow.showPublic
                            if (netRow.showPublic)
                                pubInfo.update()
                            else
                                netInfo.update()
                        } else if (mouse.button === Qt.RightButton) {
                            copyProcess.command = ["bash", "-c", "echo -n '" + netRow.displayedIp() + "' | wl-copy"]
                            copyProcess.running = true
                        } else if (mouse.button === Qt.MiddleButton) {
                            netRow.hidden = !netRow.hidden
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: 20
                color: "#35477c"
                opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }

            Repeater {
                model: SystemTray.items
                delegate: Item {
                    required property SystemTrayItem modelData
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: modelData.icon
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton)
                                modelData.activate()
                            else
                                modelData.secondaryActivate()
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: 20
                color: "#35477c"
                opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: clock
                color: "#1a2a4a"
                font.pixelSize: 12
                font.bold: true

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }

                Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }
        }

        // ── PROCESOS ─────────────────────
        Process {
            id: netInfo
            command: ["bash", "-c", "ip -o addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2, $4}' | head -1"]

            function update() {
                running = true
            }

            stdout: SplitParser {
                onRead: (line) => {
                    var parts = line.trim().split(" ")
                    if (parts.length >= 2) {
                        var iface = parts[0]
                        var ip = parts[1].split("/")[0]

                        netRow.privateIp = ip
                        if (!netRow.hidden && !netRow.showPublic)
                            netLabel.text = ip

                        netIcon.text = iface.startsWith("w") ? "󰤨" : "󰈀"
                    } else {
                        netRow.privateIp = "sin conexión"
                        if (!netRow.hidden && !netRow.showPublic)
                            netLabel.text = "sin conexión"
                        netIcon.text = "󰌙"
                    }
                }
            }

            Component.onCompleted: update()
        }

        Process {
            id: pubInfo
            command: ["bash", "-c", "curl -s ifconfig.me"]

            function update() {
                running = true
            }

            stdout: SplitParser {
                onRead: (line) => {
                    var ip = line.trim()
                    netRow.publicIp = ip.length > 0 ? ip : "sin respuesta"

                    if (!netRow.hidden && netRow.showPublic)
                        netLabel.text = netRow.publicIp

                    netIcon.text = "󰖟"
                }
            }
        }

        Process {
            id: copyProcess
            command: ["bash", "-c", "echo -n '' | wl-copy"]
        }

        Timer {
            interval: 10000
            running: true
            repeat: true
            onTriggered: {
                if (netRow.showPublic)
                    pubInfo.update()
                else
                    netInfo.update()
            }
        }
    }
}