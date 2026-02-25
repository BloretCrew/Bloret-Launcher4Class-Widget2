import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Widgets
import RinUI

Widget {
    id: root
    width: 180
    height: 100
    
    // 顶部小字标题
    text: "Bloret 在线人数"

    // 主内容区
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 15 // 避开 Widget 标题
        anchors.bottomMargin: 10 // 为底部进度条留出点空间
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Row {
                anchors.centerIn: parent
                spacing: 4
                
                Text {
                    text: (typeof backend !== "undefined") ? backend.playersOnline : "0"
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: "#1D1D1F"
                    font.family: "MiSans, HarmonyOS Sans, Segoe UI"
                }
                
                Text {
                    text: (typeof backend !== "undefined") ? "/ " + backend.playersMax : "/ 0"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#8E8E93"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                }
            }
        }
    }

    // 底部进度条：强制固定在最底部
    Rectangle {
        id: barContainer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        anchors.bottomMargin: 12 // 调整垂直位置，使其看起来像图二
        
        height: 6
        color: Qt.rgba(0, 0, 0, 0.05)
        radius: 3
        
        Rectangle {
            width: (typeof backend !== "undefined" && backend.playersMax > 0) ? 
                   parent.width * (backend.playersOnline / backend.playersMax) : 0
            height: parent.height
            radius: 3
            color: (typeof backend !== "undefined" && backend.online) ? "#28CD41" : "#FF3B30"
            
            Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        }
    }
    
    ToolTip {
        visible: mouseArea.containsMouse
        text: (typeof backend !== "undefined") ? backend.motd : ""
        delay: 500
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
