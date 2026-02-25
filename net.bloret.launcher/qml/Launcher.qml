import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 100
    height: 100

    Button {
        id: launchButton
        anchors.fill: parent
        flat: true
        
        background: Rectangle {
            id: bg
            radius: 16
            color: launchButton.hovered ? "#20000000" : "transparent"
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        contentItem: Column {
            spacing: 8
            anchors.centerIn: parent
            
            Image {
                id: icon
                // 使用插件资源目录下的图标
                source: "../assets/bloret.png"
                width: 64
                height: 64
                anchors.horizontalCenter: parent
                fillMode: Image.PreserveAspectFit
                
                // 添加一个简单的缩放动画
                scale: launchButton.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
            
            Text {
                text: "Bloret"
                font.pixelSize: 14
                font.bold: true
                color: "#333333"
                anchors.horizontalCenter: parent
            }
        }

        onClicked: {
            if (typeof backend !== "undefined") {
                backend.launch()
            } else {
                print("Backend not found!")
            }
        }
    }
}
