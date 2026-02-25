import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    width: 260
    height: 140

    // 背景卡片
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 20
        color: "#FFFFFF"
        
        // 阴影效果 (如果是 Class Widgets 环境可能已有阴影，这里加个轻微的边框)
        border.color: "#F0F0F0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // 头部：标题与灯
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Image {
                    source: "../icon.png"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Bloret 百络谷"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#1D1D1F"
                    }
                    
                    Text {
                        text: (typeof backend !== "undefined" && backend.online) ? "● 运行中" : "○ 已离线"
                        font.pixelSize: 11
                        color: (typeof backend !== "undefined" && backend.online) ? "#34C759" : "#FF3B30"
                    }
                }
            }

            // MOTD
            Text {
                id: motdText
                Layout.fillWidth: true
                text: (typeof backend !== "undefined") ? backend.motd : "获取中..."
                font.pixelSize: 13
                color: "#48484A"
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            // 进度条与人数
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "在线人数"
                        font.pixelSize: 11
                        color: "#8E8E93"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: (typeof backend !== "undefined") ? (backend.playersOnline + " / " + backend.playersMax) : "0 / 0"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: "#1D1D1F"
                    }
                }

                ProgressBar {
                    id: playerBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    value: (typeof backend !== "undefined" && backend.playersMax > 0) ? backend.playersOnline / backend.playersMax : 0
                    
                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 6
                        color: "#E5E5EA"
                        radius: 3
                    }

                    contentItem: Item {
                        implicitWidth: 200
                        implicitHeight: 6

                        Rectangle {
                            width: playerBar.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: "#5856D6" // 蓝色/紫色调
                        }
                    }
                }
            }
        }
    }
}
