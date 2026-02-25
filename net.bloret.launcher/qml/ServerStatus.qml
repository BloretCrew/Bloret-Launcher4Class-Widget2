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
    text: "在线人数"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 0

        // 中间大数字显示
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Row {
                anchors.centerIn: parent
                spacing: 4
                
                // 大数字
                Text {
                    text: (typeof backend !== "undefined") ? backend.playersOnline : "0"
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: "#1D1D1F"
                    font.family: "MiSans, HarmonyOS Sans, Segoe UI"
                }
                
                // 分隔符与最大人数
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

        // 底部进度条 (仿图二风格)
        Rectangle {
            id: barContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            color: Qt.rgba(0, 0, 0, 0.05)
            radius: 3
            Layout.bottomMargin: 4
            
            Rectangle {
                width: (typeof backend !== "undefined" && backend.playersMax > 0) ? 
                       parent.width * (backend.playersOnline / backend.playersMax) : 0
                height: parent.height
                radius: 3
                color: (typeof backend !== "undefined" && backend.online) ? "#28CD41" : "#FF3B30"
                
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
        }
    }
    
    // 鼠标悬浮显示详细信息（MOTD 等）
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
