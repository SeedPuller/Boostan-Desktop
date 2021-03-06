/*
    * The page that show a error and run the callback_function
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Controls"
import "../Helpers"

Page {
    id: error_page
    property alias error_msg: error_text.text
    property alias error_solution: error_solution.text
    property var callback_function: function(){}
    property int criticalStatus: ErrorHandler.SemiCritical
    property var sideBarItem

    /** Private property  **/
    property bool _sideBarItemVisiblity
    Component.onCompleted: {
        _sideBarItemVisiblity = sideBarItem.enabled
        sideBarItem.enabled = false
    }

    Rectangle {
        id: page_background
        anchors.fill: parent
        color: "#262125"
        Image {
            id: error_logo
            sourceSize.width: parent.width / 1.5
            sourceSize.height: parent.height / 1.2
            source: "qrc:/pics/error-logo.svg"
            anchors.centerIn: parent
            Rectangle {
                anchors.fill: parent
                color: "#262125"
                opacity: 0.5
            }
        }
        Label {
            id: eror_icon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: error_logo.top
            anchors.topMargin: 50
            text: "\ue802" // sad icon
            font.family: "fontello"
            font.pixelSize: error_logo.width / 4
            color: "#F8F7F2"
        }

        Label {
            id: error_text
            width: parent.width - 10
            horizontalAlignment: Label.AlignHCenter
            anchors.top: eror_icon.bottom
            anchors.topMargin: 40
            font.family: "Tanha"
            font.pixelSize: eror_icon.font.pixelSize / 4
            font.weight: Font.DemiBold
            text: "این یک متن ارور است"
            color: "#F8F7F2"
            wrapMode: Label.WordWrap
        }

        Label {
            id: error_solution
            width: parent.width - 10
            horizontalAlignment: Label.AlignHCenter
            anchors.top: error_text.bottom
            font.family: "Tanha"
            font.pixelSize: error_text.font.pixelSize / 2
            font.weight: Font.DemiBold
            text: "این یک توضیحات اضافه است"
            color: "#F8F7F2"
            wrapMode: Label.WordWrap
        }

        MyButton {
            id: retry_button
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: error_solution.bottom
            anchors.topMargin: 10
            width: 200
            height: 60
            // this text seems reverse. correct is: if status == Critical, close page. else try again
            text: error_page.criticalStatus == ErrorHandler.Critical ? "بستن برنامه!" : "دوباره تلاش کن!"
            font.pixelSize: 20
            bgColor: error_page.criticalStatus == ErrorHandler.Critical ? "#E53935" :  "#19B99A"
            radius: 5
            onClicked: {
                if (error_page.criticalStatus == ErrorHandler.Critical) {
                    Qt.quit()
                    return;
                }
                sideBarItem.enabled = _sideBarItemVisiblity
                callback_function()
            }

        }
    }
}
