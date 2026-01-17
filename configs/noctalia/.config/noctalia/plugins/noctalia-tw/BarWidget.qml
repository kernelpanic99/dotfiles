import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import Quickshell.Io

Rectangle {
  id: root

  // Plugin API (injected by PluginService)
  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: "timewarrior"
  property string section: ""

  implicitWidth: row.implicitWidth + Style.marginM * 2
  implicitHeight: Style.barHeight - Style.marginS

  color: Style.capsuleColor
  radius: Style.radiusM

  property string cmdOutput: ""
  property string widgetIcon: "player-pause"
  property var currentTask: null

  property bool isTracking: currentTask && !currentTask.end
  property color trackingColor: isTracking ? "#a6e3a1" : "#f38ba8"

  visible: cmdOutput !== ""

  Process {
      id: tw
      command: ["timew", "export", "today"]
      running: true


      onExited: (code, status) => {
          timer.start()
      }

      stdout: StdioCollector {
          onStreamFinished: {
              const data = JSON.parse(this.text)

              if (!data.length) { 
                  cmdOutput = ""; 
                  widgetIcon = "player-stop"
                  return
              }

              const current = data[data.length - 1]
              currentTask = current
              const tags = current.tags || []
              const displayTag = tags.find(t => t.includes('-')) || tags[tags.length - 1] || "empty"

              const toIso = (str) => str.replace(/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z/, '$1-$2-$3T$4:$5:$6Z')

              const calcTotal = (tasks, showSecs = true) => {
                  const ms = tasks.reduce((acc, it) => {
                      const end = it.end ? new Date(toIso(it.end)) : new Date()
                      const start = new Date(toIso(it.start))
                      return acc + (end - start)
                  }, 0)

                  const secs = Math.floor(ms / 1000)
                  const h = Math.floor(secs / 3600)
                  const m = Math.floor((secs % 3600) / 60)
                  const s = secs % 60
                  const pad = n => String(n).padStart(2, '0')

                  return showSecs ? `${pad(h)}:${pad(m)}:${pad(s)}` : `${pad(h)}:${pad(m)}`
              }

              const sameTags = data.filter(t => JSON.stringify(t.tags || []) === JSON.stringify(tags))

              const total = calcTotal(sameTags, true)
              const dayTotal = calcTotal(data, false)

              if(current.end){
                  widgetIcon = "player-play"
              } else {
                  widgetIcon = "player-pause"
              }

              cmdOutput = `${displayTag} ${total}/${dayTotal}`
          }
      }
  }

  Process {
      id: toggleTracking
      command: root.currentTask?.end ? ["timew", "continue"] : ["timew", "stop"]
      onExited: tw.running = true
  }

  Timer {
      id: timer
      interval: 1000
      onTriggered: tw.running = true
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Style.marginS

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        implicitWidth: icon.implicitWidth
        implicitHeight: icon.implicitHeight

        onClicked: {
            if(root.currentTask) {
                toggleTracking.running = true
            }
        }

        NIcon {
          id: icon
          icon: widgetIcon
          color: root.trackingColor
        }
    }

    NText {
      text: cmdOutput
      color: root.trackingColor
      pointSize: Style.fontSizeS
    }
  }
}
