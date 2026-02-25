import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Widgets
import RinUI

Widget {
    id: root
    width: 250
    height: 110
    
    // 设置 Widget 标题风格
    text: "Bloret 服务器状态"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4

        // 顶栏：图标和在线状态
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                source: "../icon.png"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                smooth: true
            }

            ColumnLayout {
                spacing: -2
                Layout.fillWidth: true
                
                Title {
                    text: "百络谷 (Bloret)"
                    font.pixelSize: 13
                    Layout.fillWidth: true
                }
                
                Text {
                    text: (typeof backend !== "undefined" && backend.online) ? "● 服务器在线" : "○ 服务器离线"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: (typeof backend !== "undefined" && backend.online) ? "#28CD41" : "#FF3B30"
                }
            }
        }

        // 公告信息
        Text {
            text: (typeof backend !== "undefined") ? backend.motd : "同步中..."
            font.pixelSize: 11
            color: Qt.rgba(0, 0, 0, 0.6) // 适配淡色主题的深度灰
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Item { Layout.fillHeight: true }

        // 人数显示与进度
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            // 使用标准的进度条渲染方式，配合官方样式
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 5
                color: Qt.rgba(0, 0, 0, 0.05)
                radius: 2.5
                
                Rectangle {
                    width: (typeof backend !== "undefined" && backend.playersMax > 0) ? 
                           parent.width * (backend.playersOnline / backend.playersMax) : 0
                    height: parent.height
                    radius: 2.5
                    color: "#007AFF"
                    
                    Behavior on width { NumberAnimation { duration: 500 } }
                }
            }
            
            Title {
                text: (typeof backend !== "undefined") ? (backend.playersOnline + "/" + backend.playersMax) : "--/--"
                font.pixelSize: 11
            }
        }
    }
}
