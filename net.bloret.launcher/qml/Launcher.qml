import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 80
    height: 90

    Button {
        id: launchButton
        anchors.fill: parent
        flat: true
        
        background: Rectangle {
            radius: 12
            color: launchButton.hovered ? "#2FFFFFFF" : "#1FFFFFFF"
            border.color: "#3FFFFFFF"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        contentItem: ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            
            Image {
                source: "../icon.png"
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignHCenter
                smooth: true
                opacity: launchButton.pressed ? 0.8 : 1.0
            }
            
            Text {
                text: "启动器"
                font.pixelSize: 11
                font.bold: true
                color: "white"
                Layout.alignment: Qt.AlignHCenter
                style: Text.Outline
                styleColor: "#20000000"
            }
        }

        onClicked: {
            if (typeof backend !== "undefined") {
                backend.launch()
            }
        }
    }
}
