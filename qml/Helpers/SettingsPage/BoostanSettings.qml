import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../Controls"

Item {
    Row {
        width: parent.width
        height: parent.height
        spacing: 0
        Column {
            width: parent.width / 2
            height: parent.height - 50
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20
            MySwitch {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 110
                height: 35
            }
        }

        Column {
            width: parent.width / 2
            height: parent.height - 50
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Qt.AlignVCenter
                text: "ذخیره رویدادها"
                color: "#FCFCFC"
                font.family: regular_font.name
                font.weight: Font.Bold
                height: 35
            }
        }
    }
}
