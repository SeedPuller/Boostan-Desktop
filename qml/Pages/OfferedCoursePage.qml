import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Controls"
import "../Helpers"
import API.OfferedCourseHandler 1.0

Page {
    id: offered_course_page

    OfferedCourseHandler {
        id: offered_course_handler
        Component.onCompleted: start()
        onFinished: {
            sendDataTo(offered_course_model)
            table_view.model = offered_course_model
        }
    }

    OfferedCourseModel {
        id: offered_course_model
    }

    Rectangle {
        id: page_background
        anchors.fill: parent
        color: "#262A2F"
    }

    Popup {
        id: schedule_popup
        modal: true
        width: parent.width
        height: parent.height / 1.5
        anchors.centerIn: Overlay.overlay
        background: Rectangle { color: "transparent" }
        ScheduleTable {
            id: schedule_table
            width: parent.width
            height: parent.height
            model: 0
        }
    }

    MyButton {
        id: constructed_schedule_btn
        anchors.right: table_view.right
//        anchors.rightMargin: 10
        y: 20
        width: 170
        height: 50
        // TODO: change text to a more meaningful text
        text: "برنامه ساخته شده"
        bgColor: "#19B99A"
        radius: 8
        font.family: regular_font.name
        onClicked: schedule_popup.open()
    }

    MyTableView {
        id: table_view
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: constructed_schedule_btn.bottom
        anchors.topMargin: 10
        width: parent.width - 30
        height: parent.height - constructed_schedule_btn.height - 50
        model: 0
        columnItem: tableview_column
        onChoosed: schedule_table.addElement(offered_course_model.toScheduleFormat(index))
        onUnchoosed: schedule_table.removeElement(offered_course_model.toScheduleFormat(index))
    }

    Component {
        id: tableview_column
        MyTableView.BaseColumnItem {
            Column {
                anchors.centerIn: parent
                width: parent.width - 5
                Label {
                    width: parent.width
                    horizontalAlignment: Label.AlignHCenter
                    wrapMode: Label.WordWrap
                    font.family: regular_font.name
                    text: model[role]
                    color: model.isChoosed ? "#757575" : "#FFFFFF"
                }
                Icon {
                    visible: role == "capacity" && model.sex !== OfferedCourseModel.None
                    width: parent.width
                    text: model.sex
                    horizontalAlignment: Label.AlignHCenter
                    color: model.isChoosed ? "#757575" : "#FFFFFF"
                }
            }
        }
    }
}

