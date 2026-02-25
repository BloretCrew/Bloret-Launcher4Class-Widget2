import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 240
    height: 100

    // 背景卡片：匹配默认淡色主题
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: "#E5FFFFFF" // 几乎不透明的白色，配合主程序的毛玻璃
        border.color: "#15000000"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4

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
                
                Text {
                    text: "Bloret 百络谷"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#1D1D1F"
                }
                
                // 更加醒目的状态文字
                Text {
                    id: statusLabel
                    text: {
                        var b = (typeof backend !== "undefined") ? backend : null;
                        if (!b) return "○ 组件加载中...";
                        return b.online ? "● 服务器在线" : "● 服务器离线";
                    }
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: {
                        var b = (typeof backend !== "undefined") ? backend : null;
                        if (!b) return "#8E8E93";
                        return b.online ? "#28CD41" : "#FF3B30";
                    }
                }
            }
        }

        // MOTD：自动滚动或限制
        Text {
            text: (typeof backend !== "undefined") ? backend.motd : "正在从服务器获取最新公告..."
            font.pixelSize: 11
            color: "#48484A"
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Item { Layout.fillHeight: true }

        // 人数进度条
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            ProgressBar {
                id: playerBar
                Layout.fillWidth: true
                Layout.preferredHeight: 5
                value: (typeof backend !== "undefined" && backend.playersMax > 0) ? backend.playersOnline / backend.playersMax : 0
                
                background: Rectangle {
                    implicitHeight: 5
                    color: "#F2F2F7"
                    radius: 2.5
                }

                contentItem: Item {
                    Rectangle {
                        width: playerBar.visualPosition * parent.width
                        height: parent.height
                        radius: 2.5
                        color: "#007AFF" // 标准 iOS 蓝色
                    }
                }
            }
            
            Text {
                text: (typeof backend !== "undefined") ? (backend.playersOnline + "/" + backend.playersMax) : "--/--"
                font.pixelSize: 10
                font.weight: Font.Bold
                color: "#1D1D1F"
            }
        }
    }
    
    // 定时刷新尝试 (如果 Signal 没收到)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // 简单的强制重绘属性（如果定义了）
            if (typeof backend !== "undefined") {
                // statusLabel.text = backend.online ? "● 在线" : "○ 离线";
            }
        }
    }
}
