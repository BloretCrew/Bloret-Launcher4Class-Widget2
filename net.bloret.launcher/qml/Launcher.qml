import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 100
    height: 100

    Button {
        id: launchButton
        anchors.fill: parent
        flat: true
        padding: 0
        
        background: Rectangle {
            id: bg
            radius: 20
            color: launchButton.hovered ? "#0A000000" : "transparent"
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        contentItem: ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            
            Image {
                id: iconImg
                source: "../icon.png"
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                Layout.alignment: Qt.AlignHCenter
                smooth: true
                fillMode: Image.PreserveAspectFit
                
                scale: launchButton.pressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }
            }
            
            Text {
                text: "启动器"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#1D1D1F"
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
