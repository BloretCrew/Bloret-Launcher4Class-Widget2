import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Widgets
import RinUI

Widget {
    id: root
    // Widget 组件会自动处理背景、圆角和阴影
    // 我们可以通过 text 属性设置标题（如果需要）
    
    width: 80
    height: 80

    Button {
        id: launchButton
        anchors.fill: parent
        flat: true
        
        contentItem: ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            
            Image {
                source: "../icon.png"
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignHCenter
                smooth: true
                
                scale: launchButton.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
            
            Title {
                text: "启动器"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
            }
        }

        onClicked: {
            if (typeof backend !== "undefined") {
                backend.launch()
            }
        }
    }
}
