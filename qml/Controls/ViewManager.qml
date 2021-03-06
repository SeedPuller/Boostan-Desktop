/*
    * A component that is responsible to manage the view system(StackView in here).
    * This component is able to remove a object(PageBase) from the StackView but keep
    * the page instead of destroying it. This enables us to restore the already-created page.
    * So no need to re-create the object.
    * Also, the objects would destroy only if they time gets up.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15

StackView {
    id: root

    property var __objects: ({})

    function showPage(comp, comp_name, enable_cache = true, is_url = true)
    {
        if (root.__objects.hasOwnProperty(comp_name)) {
            root.currentItem.__isActive = false
            root.__objects[comp_name].__isActive = true
            root.replace(root.__objects[comp_name], StackView.PushTransition)
            return;
        }

        if (is_url === true)
            comp = Qt.createComponent(comp)

        var obj = comp.createObject(root.parent, {__viewManUid: comp_name})
        obj.__timedOut.connect(root.removePage)

        __objects[comp_name] = obj

        var current_obj = root.currentItem
        root.replace(obj, StackView.PushTransition)

        // if the page noted that it should not be cached, remove it.
        if (enable_cache)
            current_obj.__isActive = false
        else
            removePage(current_obj.__viewManUid)
    }

    // just push the component
    function rawPush(comp, comp_name, is_url = true)
    {
        if (is_url === true)
            comp = Qt.createComponent(comp)

        var obj = comp.createObject(root.parent, {__viewManUid: comp_name})
        __objects[comp_name] = obj

        root.push(obj)
    }

    // replace current item with {{comp}} and remove every
    // other existing component in {{__objects}}
    function rawPushReset(comp, comp_name, is_url = true)
    {
        if (is_url === true)
            comp = Qt.createComponent(comp)

        var obj = comp.createObject(root.parent, {__viewManUid: comp_name})
        root.replace(obj, StackView.PushTransition)

        for (var uid in __objects) {
            removePage(uid);
        }
        __objects[comp_name] = obj

    }

    function removePage(uid)
    {
        if (__objects.hasOwnProperty(uid)) {
            __objects[uid].destroy()
            delete __objects[uid]
        }
    }

}
