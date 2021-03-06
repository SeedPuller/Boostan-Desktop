/*
    * Custom RTL ComboBox component
    * This component made from an customized ComboBox inside an Item.
    * The reason of this choice is the ComboBox reaction(animation) in response to activation
    * or deactivation. The ComboBox height will change by 10 in those situtaion and Would
    * make problem if We only have ComboBox(Without wrapping in Item) and any other component has
    * binding with this ComboBox.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
Item {
    id: root
    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight
    property alias comboItem: control
    property alias radius: control.radius
    property alias font: control.font
    property alias model: control.model
    property alias popupMaxHeight: control.popupMaxHeight
    property alias currentValue: control.currentValue
    property alias currentIndex: control.currentIndex

    signal activated(var index);

    ComboBox {
        id: control
        width: parent.width
        // we need 10 unit for the animation
        height: parent.height - 10
        model: ["سلام", "سلام دو", "سلام سه"]
        font.family: regular_font.name
        font.weight: Font.DemiBold
        font.pixelSize: 17
        property real radius: 12
        // specify the maximum height of popup.
        property real popupMaxHeight: 150

        Behavior on height {
            NumberAnimation { duration: 150 }
        }

        onActivated: root.activated(index)

        delegate: Item {
            width: control.width
            height: item_delg.height
            ItemDelegate {
                id: item_delg
                width: parent.width
                highlighted: control.highlightedIndex === index

                onClicked: {
                    control.currentIndex = index
                    control.activated(index)
                    pop.close()
                }

                contentItem: Text {
                    text: modelData[control.textRole] === undefined ? modelData : modelData[control.textRole]
                    color: "#FFFFFF"
                    font: control.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // separator between items
            Rectangle {
                visible: index !== control.count - 1
                width: parent.width
                height: 1
                y: parent.height
                color: "#159E84"
                opacity: 0.5
            }
        }

        indicator: Canvas {
            id: canvas
            x: width + control.leftPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            // rotate the 'indicator' by enabling/disabling the popup
            Connections {
                target: pop
                function onAboutToShow() { rotate.from= 0; rotate.to = 180; rotate.start() }
                function onAboutToHide() { rotate.from= 180; rotate.to = 360; rotate.start() }
            }

            Component.onCompleted: requestPaint()
            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = "#121212";
                context.fill();
            }
            RotationAnimation {
                id: rotate
                target: canvas
                duration: 150
            }
        }

        contentItem: Text {
            rightPadding: 0
            leftPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: "#262125"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            color: "#19B99A"
            radius: control.radius

        }

        popup: Popup {
            id: pop
            y: control.height - 15
            width: control.width
            height: contentItem.implicitHeight
            padding: 1

            Behavior on height {
                NumberAnimation { duration: 130 }
            }

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight <= control.popupMaxHeight ? contentHeight + 5 : control.popupMaxHeight

                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
                boundsBehavior: ListView.StopAtBounds

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                color: "#116A59"
                radius: control.radius
            }

            // change the component height whenever popup being visible/invisible
            onAboutToShow: {
                control.height += 10
                control.topPadding -= 10
            }
            onAboutToHide: {
                control.height -= 10
                control.topPadding += 10
            }

        }
    }

}

