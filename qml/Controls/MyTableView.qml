/*
    * This is my implementation of TableView.
    * This Component will get model data like normal ListView
    * and provide each column data by each of 'columnKey' 's.
    * Also, This class can use custom component(via 'columnItem' property)
    * for showing information inside each cell.
    * NOTE: custom component should be type of BaseColumnItem
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    /**  Properties  **/

    property alias model: listview.model
    property bool hasModelBackend: false
    // Roles used for accessing information in model.
    property var columnRoles: ["group", "courseNumber", "courseName", "weight", "capacity", "teacher", "time", "place", "exam"]
    // List of titles for each column.
    property alias columnTitles: table_header_repeater.model
    // alias for listview.interactive
    property alias interactive: listview.interactive
    // determine if the component should calculate the height based on listview contents automaticly
    property bool autoHeight: false
    // check if autoheight is true
    implicitHeight: autoHeight ? listview.contentHeight + 60 : 300

    // List of width(width coefficient actually) of each column corresponding to columnTitles element.
    // Sizes MUST be a number between 0 and 1.
    // 0 means width = 0 and 1 means the width of column would equivalent to the whole Table.
    // the best occasion is when the summation of ratios being equal(or nearly equal) to 1.
    property alias columnWidthRatios: table_header_repeater.sizes
    // height of each row
    property real rowHeight: 70
    // A component for showing each cells.
    property var columnItem: column_repeater_delegate
    // List of choosed rows indexes.
    property var choosedList: []
    // The items are choose-able or not
    property bool choosable: true

    /**  Signals  **/

    // A row at index 'index' choosed.
    signal choosed(int index)
    // A row at index 'index' have unchoosed.
    signal unchoosed(int index)
    // Row initialized already chosen.
    signal initialChoose(int index)
    signal choosedCleared()

    // Undo a choosed state of row at index 'index'
    function undoChoose(index)
    {
        listview.itemAtIndex(index).rowData["isChoosed"] = false
        var ind = root.choosedList.indexOf(index)
        root.choosedList.splice(ind, 1)
    }

    function clearAllChoosed ()
    {
        if (root.hasModelBackend)
            listview.model.clearAllChoosed(choosedList)
        else {
            for (var i = 0; i < choosedList.length; ++i) {
                var obj = listview.itemAtIndex(choosedList[i])
                obj.rowData["isChoosed"] = false
            }
        }
        root.choosedList = []
        root.choosedCleared()
    }

    // header for the listview
    Rectangle {
        id: container_level1
        color: "#19B99A"
        width: root.width
        height: root.height
        radius: 10
        RowLayout {
            id: table_header_layout
            width: parent.width - 10
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            layoutDirection: Qt.RightToLeft
            spacing: 0
            Repeater {
                id: table_header_repeater                
                model: ["گروه", "شماره درس", "نام درس", "واحد", "ظرفیت", "استاد", "زمان", "محل برگزاری", "امتحان"]
                property var sizes: [0.05, 0.11, 0.18, 0.04, 0.06, 0.13, 0.16, 0.11, 0.1]
                Item {
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: table_header_layout.width * table_header_repeater.sizes[index]
                    Label {
                        anchors.centerIn: parent
                        font.family: regular_font.name
                        font.bold: true
                        text: modelData
                        color: "#000000"
                    }

                    // column separator
                    Rectangle {
                        visible: index !== 0
                        anchors.right: parent.right
                        height: root.height
                        width: 2
                        color: "#262A2F"
                    }

                }
            }
        }
    }

    Rectangle {
        id: container_level2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: container_level1.top
        anchors.topMargin: 50
        width: container_level1.width
        height: container_level1.height - 50
        radius: 8
        color: "#262A2F"
        opacity: 0.7
    }

    Rectangle {
        id: listview_bg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: container_level2.top
        anchors.topMargin: 10
        width: container_level2.width
        height: container_level2.height - 10
        radius: 8
        color: "#262A2F"
        opacity: 0.5
    }

    // List view that generates the rows
    ListView {
        id: listview
        property bool isArray: false
        anchors.fill: listview_bg
        clip: true
        boundsBehavior: Flickable.OvershootBounds
        ScrollBar.vertical: ScrollBar { }
        delegate: delegate
        onModelChanged: {
            if (model.constructor.name === "Array") {
                isArray = true;
                return;
            }
            isArray = false;
        }
    }

    // TODO: Check for destructing the columns to prevent errors
    Component {
        id: delegate
        Item {
            id: delegate_root
            height: root.rowHeight
            width: listview.width
            property var rowData: listview.isArray ? modelData : model
            Component.onCompleted: {
                // Identify the chosen state of the row. If there is no member names 'isChoosed', create one.
                rowData["isChoosed"] = rowData.isChoosed ?? false;
                if (rowData["isChoosed"] && root.choosedList.indexOf(index) === -1) {
                    choosedList.push(index)
                    initialChoose(index)
                }
            }

            // Columns of each row place in here
            RowLayout {
                width: parent.width - 10
                height: parent.height - 10
                anchors.horizontalCenter: parent.horizontalCenter
                layoutDirection: Qt.RightToLeft
                spacing: 0

                // Generate the columns
                Repeater {
                    id: column_repeater
                    model: root.columnRoles
                    property var rowIndex: index

                    Item {
                        id: column_repeater_root_delegate
                        Layout.preferredWidth: parent.width * table_header_repeater.sizes[index]
                        Layout.preferredHeight: parent.height
                        Layout.alignment: Qt.AlignVCenter
                        // Create a object with 'columnItem' as a cell.
                        Component.onCompleted: {
                            root.columnItem.incubateObject(column_repeater_root_delegate, {
                                                             "model": delegate_root.rowData, "role": modelData,
                                                             "index": index
                                                         })
                        }

                    }
                }
            }

            // MouseArea on row space that manage the choosing functionalities.
            MouseArea {
                id: mouse_area
                anchors.fill: parent
                onPressAndHold: {
                    if (!root.choosable)
                        return;
                    // if already choosed, unchoose them.
                    if (delegate_root.rowData.isChoosed) {
                        var ind = root.choosedList.indexOf(index)
                        root.choosedList.splice(ind, 1)
                        delegate_root.rowData.isChoosed = false
                        root.unchoosed(index)
                    }else {
                        root.choosedList.push(index);
                        delegate_root.rowData.isChoosed = true
                        root.choosed(index)
                    }
                }
            }

            // Row separator
            Rectangle {
                visible: index !== listview.count - 1
                anchors.bottom: parent.bottom
                width: listview.width
                height: 4
                color: "#19B99A"
                opacity: 0.6
            }
        }

    }

    // A component that wrap the necessary data's for being used in cells.
    component BaseColumnItem: Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        required property var model
        required property var role
        required property int index
    }

    // Default Cell component
    Component {
        id: column_repeater_delegate
        BaseColumnItem {
            Label {
                anchors.centerIn: parent
                width: parent.width - 5
                horizontalAlignment: Label.AlignHCenter
                wrapMode: Label.WordWrap
                font.family: regular_font.name
                text: model[role]
                color: model.isChoosed ? "#757575" : "#FFFFFF"
            }
        }
    }
}
