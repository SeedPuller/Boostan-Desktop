﻿import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import API.InitHandler 1.0
import API.LoginHandler 1.0

Page {
    id: login_page

    InitHandler {
        id: init_handler
        Component.onCompleted: start();
        onFinished: init_handler.success ? captcha_handler.loadCaptcha(captcha_pic) : error_handler.raiseError(
        errorCode,
        function() {
            init_handler.start()
        }
        )
    }

    LoginHandler {
        id: login_handler
        onFinished: login_handler.success
                    ? console.log("Success!")
                    : error_handler.raiseError(login_handler.errorCode,
                                               function(){
                                                //init_handler.start()
                                                captcha_handler.loadCaptcha(captcha_pic)
                                               },
                                               notifier)

    }

    CaptchaHandler {
        id: captcha_handler
        onFinished: captcha_handler.success
                    ? captcha_pic.source = "file:/" + ApplicationPath + "captcha.png"
                    : error_handler.raiseError(captcha_handler.errorCode,
                                               function(){
                                                captcha_handler.loadCaptcha(captcha_pic)
                                               },
                                               notifier)

        function loadCaptcha(cpic) {
            cpic.source = "file:/" + ApplicationPath + "/pic/captcha.png"
            getCaptcha()
        }
    }

    RowLayout {
        anchors.fill: parent
        id: page_background
        spacing: 0

        Rectangle {
            id: logo_background
            Layout.preferredWidth: parent.width / 2.5
            Layout.preferredHeight: parent.height
            color: "#19B99A"
            Image {
                anchors.centerIn: parent
                source: "pics/login-logo.svg"
                width: 330
                height: 200
            }
        }

        Rectangle {
            id: form_background
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            color: "#262125"

            Label {
                id: header_name
                anchors.horizontalCenter: form_container.horizontalCenter
                anchors.bottom: form_container.top
                anchors.bottomMargin: 20
                text: "بوستان"
                font.family: "Mj_Afsoon"
        //        font.bold: Font.Bold
                font.pixelSize: 60
                color: "#19B99A"
            }

            Rectangle {
                id: form_container
                anchors.centerIn: parent
                width: 320
                height: 320
                radius: 20
                color: Qt.rgba(255, 255, 255, 0.5)
                opacity: 0.6
        //        visible: false
            }
            ColumnLayout {
                id: form_layout
                anchors.fill: form_container
                spacing: 0
                Item {
                    Layout.preferredHeight: 10
                }

                MyTextInput {
                    id: username_input
                    Layout.alignment: Qt.AlignHCenter
        //            Layout.topMargin: -15
                    width: 240
                    height: 40
                    direction: Qt.RightToLeft
                    placeHolder: "نام کاربری"
                    icon: "\ue805" // profile icon
                }

                MyTextInput {
                    id: password_input
        //            Layout.topMargin: -40
                    Layout.alignment: Qt.AlignHCenter
                    width: 240
                    height: 40
                    direction: Qt.RightToLeft
                    placeHolder: "رمز عبور"
                    mode: TextInput.Password
                    icon: "\ue800" // profile icon
                    iconSize: 24
                }

                /*
                 * Captcha Layout
                 */
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 240

                    ClickableText {
                        id: reload_icon
                        Layout.leftMargin: -15
                        font.family: "fontello"
                        font.pixelSize: 15
                        text: "\ue801" // reload icon
                        onClicked: {
                            rotate.start()
                            captcha_handler.loadCaptcha(captcha_pic)
                        }

                        RotationAnimation {
                            id: rotate
                            target: reload_icon
                            from: 0
                            to: 360
                            duration: 400
                            easing.type: Easing.InOutQuad
                        }

                    }

                    Image {
                        id: captcha_pic
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 40
                        cache: false
                        source: "file:/" + ApplicationPath + "/pic/captcha.png"
                    }

                    MyTextInput {
                        id: captcha_input
                        Layout.fillWidth: true
                        height: 40
                        placeHolder: "تصویر امنیتی"
                        horizontalAlignment: TextInput.AlignHCenter
                    }
                }

                /*
                 *  Remember me Layout
                 */
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 240
                    Layout.maximumHeight: 20
                    Layout.bottomMargin: 20
                    Layout.topMargin: -10
                    layoutDirection: Qt.RightToLeft
                    spacing: 0
                    CheckBox {
                        id: remember_checkbox
                        Layout.preferredWidth: 15
                    }
                    Label {
                        Layout.rightMargin: -15
                        text: "مرا به خاطر بسپار"
                        font.weight: Font.Bold
                    }
                }

                MyButton {
                    enabled: captcha_handler.finished && captcha_handler.success
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 50
                    text: "ورود"
                    bgColor: "#19B99A"
                    radius: 5
                    font.pixelSize: 15
                    onClicked: login_handler.tryLogin(username_input.text, password_input.text, captcha_input.text)
                }

                Item {
                    Layout.preferredHeight: 10
                }

            }

            Notifier {
                id: notifier
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
