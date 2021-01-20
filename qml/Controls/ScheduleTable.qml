﻿/*
    * Schedule Table Component. Written specially for showing weekly schedule(for courses)
    * I tried to make this component reusable.(as it is, generally)
    * the model for this component must have these 3 properties: row, column, length
    * each of the properties listed above must be a list. so at least the model could be like this:
    * { row: [0], column: [0], length: [] }
*/

//! TODO: separate delegate as a component so we can set the delegate would be flexible

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels 1.0

Item {
    id: root

    /* Public properties */

    required property var   model
    // the top header of the table
    property alias          headerTitles: hours_repeater.model
    // the side header of the table (on the right side)
    property alias          sideTitles: days_repeater.model
    // the description of the headers. this text would be placed in the first cell (from top-right)
    property alias          headerDescription: table_desc.text
    // colors of each element
    property var            courseColors: [
        "#01579B", "#FF5252", "#6A1B9A", "#33691E", "#FF6D00",
        "#00C853", "#0091EA", "#D32F2F", "#AA00FF", "#0D47A1",
        "#FFB300", "#00E676", "#00B8D4", "#BA68C8", "#3D5AFE",
        "#FFC400", "#8D6E63", "#757575", "#00796B", "#9C27B0"
                                          ]
    /* private properties */

    // index of the color from 'courseColors'
    property int __courseColorIndex: 0

    /* Functions */

    // create component 'table_element' and place it in the right place in the table.
    function addElement(model_item)
    {
        var element_length = model_item.row.length
        var element_uid = getUid(model_item)
        var element_color = root.courseColors[root.__courseColorIndex]
        // create an empty list for the object unique id
        courses.courseObjects[element_uid] = []
        for (var j = 0; j < element_length; ++j) {
            var obj = table_element.createObject(courses, {dataModel: model_item, modelIndex: j, color: element_color})
            // store the object
            courses.courseObjects[element_uid].push(obj)
        }
        // jump to next color
        root.__courseColorIndex = (root.__courseColorIndex + 1) % root.courseColors.length
    }

    // find the element using the object unique id and destroy them.
    function removeElement(model_item)
    {
        var len = model_item.row.length
        var uid = getUid(model_item)
        for (var i = 0; i < len; ++i) {
            courses.courseObjects[uid][i].destroy()
        }
    }

    // generate a unique id for a element
    function getUid(model_item)
    {
        return String(model_item.row[0]) + String(model_item.column[0])
    }

    // initialize the component
    Component.onCompleted: {
        var model_length = root.model.length
        // set a random number as a start point for courseColorIndex
        root.__courseColorIndex = parseInt(Math.random() * root.courseColors.length)
        for (var i = 0; i < model_length; ++i) {
            addElement(root.model[i])
        }
    }

    Rectangle {
        id: table_schedule_bg
        anchors.fill: parent
        color: "#1D2025"
        radius: 10
    }

    // this is the first cell (from top-right) of the table.
    Item {
        id: blank_space
        anchors.right: parent.right
        anchors.top: parent.top
        width: 90
        height: 40
        Label {
            id: table_desc
            anchors.centerIn: parent
            text: "روز / ساعت"
            font.family: regular_font.name
            color: "#FFFFFF"
        }
    }

    RowLayout {
        id: hours
        layoutDirection: Qt.RightToLeft
        width: parent.width - blank_space.width
        height: blank_space.height
        spacing: 0

        property real hour_element_width: hours.width / hours_repeater.count

        Repeater {
            id: hours_repeater
            model: ["۸", "۹", "۱۰", "۱۱", "۱۲", "۱۳", "۱۴", "۱۵", "۱۶", "۱۷", "۱۸", "۱۹", "۲۰"]
            Rectangle {
                Layout.alignment: Qt.AlignRight
                color: "transparent"
                Layout.fillHeight: true
                Layout.preferredWidth: hours.hour_element_width
                Label {
                    anchors.centerIn: parent
                    font.family: regular_font.name
                    color: "#FFFFFF"
                    text: modelData
                }
                // the separator line between each hour in header
                Rectangle {
                    x: parent.width
                    width: 2
                    height: index == 0 ? root.height : hours.height
//                    height: root.height
                    color: "#262A2F"
                }
                // the separator line in the schedule for each hour. this is a thick line.
                Rectangle {
                    x: parent.width
                    y: hours.height
                    width: 1
                    height: root.height - hours.height
                    color: "#262A2F"
                    opacity: 0.5
                }
            }
        }
    }

    ColumnLayout {
        id: days
        anchors.right: parent.right
        anchors.top: blank_space.bottom
        anchors.topMargin: -4
        spacing: 0
        width: blank_space.width
        height: table_schedule_bg.height - blank_space.height + 4

        // height of each day
        property real days_element_height: days.height / days_repeater.count
        Repeater {
            id: days_repeater
            model: ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه"]
            Rectangle {
                color: "transparent"
                Layout.preferredWidth: days.width
                Layout.preferredHeight: days.days_element_height
                Label {
                    anchors.centerIn: parent
                    font.family: regular_font.name
                    color: "#FFFFFF"
                    text: modelData
                }
                // the separator line between each day
                Rectangle {
                    y: 1
//                    width: index == 0 ? root.width : 0
                    width: root.width
                    x: -root.width + parent.width
                    height: 2
                    color: "#262A2F"
                }

//                Rectangle {
//                    y: 1
//                    width: days.width
////                    width: root.width
////                    x: -root.width + parent.width
//                    height: 2
//                    color: "#262A2F"
//                }
            }
        }
    }

    Item {
        id: courses
        anchors.top: hours.bottom
        width: parent.width - days.width
        height: parent.height - hours.height
        property var courseObjects: ({})
    }

    Component {
        id: table_element
        Rectangle {
            id: model_element
            color: "#9C27B0"
            radius: 8

            required property var dataModel
            // index for identifying which row, column and length element should we use.
            required property int modelIndex

            width: hours.hour_element_width * (dataModel.length[modelIndex])
            height: dataModel.row[modelIndex] === days_repeater.count - 1 ? (days.days_element_height / 1) - 8 : (days.days_element_height / 1) - 4
            x: courses.width - width - (dataModel.column[modelIndex] * hours.hour_element_width) - 3
//            y: days.days_element_height * dataModel.row[modelIndex] + 2 + (height / 4)
            y: days.days_element_height * dataModel.row[modelIndex] + 2

            ToolTip.visible: course_area.containsMouse
            ToolTip.delay: 500
            ToolTip.text: "استاد: " + dataModel.teacher + "<br>تاریخ امتحان:‌ " + dataModel.exam

            Label {
                id: model_element_text
                width: parent.width - 5
                anchors.centerIn: parent
                font.family: regular_font.name
//                font.pixelSize: contentHeight - model_element.height > 5 ? 11 : 14
                color: "#FFFFFF"
                text: dataModel.name
                wrapMode: Label.WordWrap
                horizontalAlignment: Label.AlignHCenter
//                Component.onCompleted: console.log(contentHeight, model_element.height)
            }
            MouseArea {
                id: course_area
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

}


