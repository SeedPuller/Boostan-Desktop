/*
    * This is a Settings pge
    * In this page, We provide 3 type of information to users:
    * -Golestan settings: changing golestan account credentials
    * -Boostan Settings:  changing this client(Boostan) configurations
    * -About: some information about the Boostan project
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Controls"
import "../Helpers/SettingsPage"

PageBase {
    id: settings_page

    Rectangle {
        id: page_background
        anchors.fill: parent
        color: "#262A2F"
    }

    Notifier {
        id: notifier
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: regular_font.name
    }

    Rectangle {
        id: tabbar_bg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: container_bg.top
        anchors.bottomMargin: 20
        width: 400
        height: 35
        color: "#33363A"
        radius: 20
        RowLayout {
            width: parent.width
            height: parent.height
            spacing: 0
            Repeater {
                id: tabbar_repeater
                model: ["درباره" ,"تنظیمات بوستان" ,"تنظیمات گلستان"]
                delegate: tabbar_comp
                signal tabChanged(var index)
                onTabChanged: {
                    stack_layout.currentIndex = index
                }
                Component.onCompleted: {
                    tabbar_repeater.itemAt(stack_layout.currentIndex).selected = true
                }
            }

        }
    }


    Rectangle {
        id: container_bg
        anchors.centerIn: parent
        width: 350
        height: 400
        color: "#1D2025"
        radius: 15

        StackLayout {
            id: stack_layout
            anchors.fill: parent
            currentIndex: 2

            About { }

            BoostanSettings { }

            GolestanSettings { }

        }
    }



    Component {
        id: tabbar_comp
        Rectangle {
            id: tabbar_comp_root
            property bool selected: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"
            radius: tabbar_bg.radius
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Label {
                anchors.centerIn: parent
                text: modelData
                color: "#FCFCFC"
                font.family: regular_font.name
                font.weight: Font.Bold
            }

            MouseArea {
                id: m_area1
                anchors.fill: parent
                onClicked: {
                    if (tabbar_comp_root.selected)
                        return;
                    tabbar_comp_root.selected = true
                    tabbar_repeater.tabChanged(index)
                }
            }

            onSelectedChanged: {
                color = selected ? "#159E84" : "transparent"
            }

            Connections {
                target: tabbar_repeater
                function onTabChanged(ind)
                {
                    if (ind !== index) {
                        tabbar_comp_root.selected = false
                    }
                }
            }
        }
    }
}
