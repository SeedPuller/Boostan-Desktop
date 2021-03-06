/*
    * This control is responsible for showing an icon by using "fontello" font.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
ClickableText {
    property bool clickAble: false
    property string description
    area.enabled: clickAble
    area.cursorShape: clickAble ? Qt.PointingHandCursor : Qt.ArrowCursor
    area.hoverEnabled: true
    font.family: "fontello"
    font.pixelSize: 15
    ToolTip.visible: area.containsMouse && description !== ""
    ToolTip.delay: 500
    ToolTip.text: description
}
