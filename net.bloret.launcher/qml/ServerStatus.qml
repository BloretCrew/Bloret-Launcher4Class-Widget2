import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 250
    height: 120

    // 毛玻璃风格背景
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 12
        // 使用带有透明度的浅色背景模拟 Glassmorphism
        color: "#1FFFFFFF" 
        border.color: "#3FFFFFFF"
        border.width: 1
        
        // 实际上 Class Widgets 已经处理了模糊背景，我们只需要确保背景是透明的
        // 如果是在纯 QML 环境下，需要用 FastBlur，但这里我们跟随主程序风格
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                source: "../icon.png"
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                smooth: true
            }

            ColumnLayout {
                spacing: -2
                Layout.fillWidth: true
                
                Text {
                    text: "Bloret 百络谷"
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    style: Text.Outline
                    styleColor: "#20000000"
                }
                
                Text {
                    text: (typeof backend !== "undefined" && backend.online) ? "● 服务器在线" : "○ 服务器离线"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: (typeof backend !== "undefined" && backend.online) ? "#a0ffb0" : "#ffb0b0"
                }
            }
        }

        Text {
            text: (typeof backend !== "undefined") ? backend.motd : "正在连接..."
            font.pixelSize: 12
            color: "#eeeeee"
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            
            ProgressBar {
                id: control
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                value: (typeof backend !== "undefined" && backend.playersMax > 0) ? backend.playersOnline / backend.playersMax : 0
                
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 4
                    color: "#30ffffff"
                    radius: 2
                }

                contentItem: Item {
                    implicitWidth: 200
                    implicitHeight: 4

                    Rectangle {
                        width: control.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: "#ffffff"
                    }
                }
            }
            
            Text {
                text: (typeof backend !== "undefined") ? (backend.playersOnline + "/" + backend.playersMax) : "0/0"
                font.pixelSize: 11
                color: "#dddddd"
                font.family: "Monospace"
            }
        }
    }
}
