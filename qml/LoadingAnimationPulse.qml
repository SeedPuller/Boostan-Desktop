import QtQuick 2.15

Item {

    // ----- Public Properties ----- //
    id: root

    property alias barCount: repeater.model
    property color color: "white"
    property int spacing: 5

    property bool running: true

    onRunningChanged: {
        if (barCount !== repeater.count || timer._barIndex <= barCount - 1) {
            return;
        }

        for (var barIndex = 0; barIndex < barCount; barIndex++) {
            if (running) {
                if (repeater.itemAt(barIndex)) {
                    repeater.itemAt(barIndex).playAnimation();
                }
            }
            else {
                if (repeater.itemAt(barIndex)) {
                    repeater.itemAt(barIndex).pauseAnimation();
                }
            }
        }
    }

    Repeater {
        id: repeater
        delegate: Component {
            Rectangle {
                width: (root.width / root.barCount) - root.spacing
                height: root.height
                x: index * width + root.spacing * index
                transform: Scale {
                    id: rectScale
                    origin {
                        x: width / 2
                        y: height / 2
                    }
                }
                transformOrigin: Item.Center
                color: root.color

                SequentialAnimation {
                    id: anim
                    loops: Animation.Infinite
                    running: root.running
                    NumberAnimation { target: rectScale; property: "yScale"; from: 1; to: 1.5; duration: 300 }
                    NumberAnimation { target: rectScale; property: "yScale"; from: 1.5; to: 1; duration: 300 }
                    PauseAnimation { duration: root.barCount * 150 }
                }
            }
        }
    }
}
