/*
    * A component for do screenshot and save it as a image.
*/

import QtQuick 2.15
import QtQuick.Dialogs 1.3

FileDialog {
    id: file_dialog
    selectExisting: false
    selectMultiple: false
    // callback should be a function to run after a successful image saving
    property var callback
    property var exclude_item
    property var item_to_save

    onAccepted: {
        exclude_item.visible = false
        item_to_save.grabToImage(function(result) {
            result.saveToFile(String(file_dialog.fileUrl).replace("file://", ""))
            callback()
         });
    }

    function saveItem(item, exclude) {
        item_to_save = item
        exclude_item = exclude
        file_dialog.open()
    }

}