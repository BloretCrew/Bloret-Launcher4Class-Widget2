import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 80
    height: 90

    // 背景卡片：匹配 Class Widgets 2 默认样式
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 16
        color: "#E0FFFFFF" // 高透明度白色
        border.color: "#20000000"
        border.width: 1
        
        // 悬浮反馈
        Rectangle {
            anchors.fill: parent
            radius: 14
            color: launchButton.hovered ? "#10000000" : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    Button {
        id: launchButton
        anchors.fill: parent
        flat: true
        
        contentItem: ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            
            Image {
                source: "../icon.png"
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignHCenter
                smooth: true
                scale: launchButton.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
            
            Text {
                text: "启动器"
                font.pixelSize: 11
                font.bold: true
                color: "#1d1d1f"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        onClicked: {
            // 尝试多种方式访问 backend
            if (typeof backend !== "undefined") {
                backend.launch()
            } else if (typeof root.backend !== "undefined") {
                root.backend.launch()
            } else {
                console.log("Launcher backend missing")
            }
        }
    }
}
