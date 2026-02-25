import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 240
    height: 120

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#f5f5f5"
        border.color: "#e0e0e0"
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                
                Image {
                    source: "../assets/bloret.png"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                }
                
                Text {
                    text: "Bloret 服务器状态"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: (typeof backend !== "undefined" && backend.online) ? "#4caf50" : "#f44336"
                }
            }

            Text {
                text: (typeof backend !== "undefined" && backend.online) ? "在线" : "离线"
                color: (typeof backend !== "undefined" && backend.online) ? "#4caf50" : "#f44336"
                font.pixelSize: 12
            }

            Text {
                text: (typeof backend !== "undefined") ? backend.motd : "正在加载..."
                font.pixelSize: 13
                color: "#666666"
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            RowLayout {
                Layout.fillWidth: true
                
                ProgressBar {
                    value: (typeof backend !== "undefined" && backend.playersMax > 0) ? backend.playersOnline / backend.playersMax : 0
                    Layout.fillWidth: true
                }
                
                Text {
                    text: (typeof backend !== "undefined") ? backend.playersOnline + "/" + backend.playersMax : "0/0"
                    font.pixelSize: 12
                    color: "#999999"
                }
            }
        }
    }
}
