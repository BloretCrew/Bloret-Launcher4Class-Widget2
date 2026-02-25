import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Widgets
import RinUI

Widget {
    id: root
    width: 80
    height: 80

    // 确保内容完全居中，且不被遮挡
    Button {
        id: launchButton
        anchors.fill: parent
        anchors.margins: 4
        flat: true
        
        background: null // 移除按钮背景，使用 Widget 背景
        
        contentItem: ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            
            Image {
                source: "../icon.png"
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignHCenter
                smooth: true
                
                scale: launchButton.pressed ? 0.85 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
            
            Title {
                text: "启动器"
                font.pixelSize: 10
                Layout.alignment: Qt.AlignHCenter
                color: "#1d1d1f"
            }
        }

        onClicked: {
            if (typeof backend !== "undefined") {
                backend.launch()
            }
        }
    }
}
