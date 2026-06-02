import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

ToolIndicatorPage {
    id: root

    property real _toolButtonHeight: ScreenTools.defaultFontPixelHeight * 3
    property real _buttonWidth: ScreenTools.defaultFontPixelWidth * 18

    contentComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 0.5
            width: root._buttonWidth

            SubMenuButton {
                objectName: "toolbar_viewFly"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Fly")
                imageResource: "/res/FlyingPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showFlyView()
                    }
                }
            }

            SubMenuButton {
                objectName: "toolbar_viewPlan"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Plan")
                imageResource: "/qmlimages/Plan.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showPlanView()
                    }
                }
            }

            SubMenuButton {
                objectName: "toolbar_viewAnalyze"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Analyze")
                imageResource: "/qmlimages/Analyze.svg"
                visible: QGroundControl.corePlugin.showAdvancedUI
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showAnalyzeTool()
                    }
                }
            }

            SubMenuButton {
                id: setupButton
                objectName: "toolbar_viewConfigure"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Configure")
                imageResource: "/res/GearWithPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showVehicleConfig()
                    }
                }
            }

            SubMenuButton {
                id: settingsButton
                objectName: "toolbar_viewSettings"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Settings")
                imageResource: "/qmlimages/Gear.svg"
                visible: !QGroundControl.corePlugin.options.combineSettingsAndSetup
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showSettingsTool()
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: QGroundControl.globalPalette.groupBorder
                opacity: 0.5
            }

            SubMenuButton {
                id: closeButton
                objectName: "toolbar_viewClose"
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Close")
                imageResource: "/res/OpenDoor.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.finishCloseProcess()
                    }
                }
            }

            // Version info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                QGCLabel {
                    Layout.fillWidth:       true
                    horizontalAlignment:    Text.AlignHCenter
                    text:                   qsTr("%1 Version").arg(QGroundControl.appName)
                    font.pointSize:         ScreenTools.smallFontPointSize
                    wrapMode:               QGCLabel.WordWrap
                    elide:                  Text.ElideNone
                    color:                  QGroundControl.globalPalette.colorGrey
                }

                QGCLabel {
                    Layout.fillWidth:       true
                    horizontalAlignment:    Text.AlignHCenter
                    text:                   QGroundControl.qgcVersion
                    font.pointSize:         ScreenTools.smallFontPointSize
                    wrapMode:               QGCLabel.WrapAnywhere
                    elide:                  Text.ElideNone
                    color:                  QGroundControl.globalPalette.colorGrey
                }

                QGCLabel {
                    Layout.fillWidth:       true
                    horizontalAlignment:    Text.AlignHCenter
                    text:                   QGroundControl.qgcAppDate
                    font.pointSize:         ScreenTools.smallFontPointSize
                    wrapMode:               QGCLabel.WrapAnywhere
                    elide:                  Text.ElideNone
                    visible:                QGroundControl.qgcDailyBuild
                    color:                  QGroundControl.globalPalette.colorGrey

                    QGCMouseArea {
                        anchors.topMargin: -(parent.y - parent.y)
                        anchors.fill: parent

                        onClicked: (mouse) => {
                            if (mouse.modifiers & Qt.ControlModifier) {
                                QGroundControl.corePlugin.showTouchAreas = !QGroundControl.corePlugin.showTouchAreas
                                showTouchAreasNotification.open()
                            } else if (ScreenTools.isMobile || mouse.modifiers & Qt.ShiftModifier) {
                                mainWindow.closeIndicatorDrawer()
                                if (!QGroundControl.corePlugin.showAdvancedUI) {
                                    advancedModeOnConfirmation.open()
                                } else {
                                    advancedModeOffConfirmation.open()
                                }
                            }
                        }

                        onPressAndHold: {
                            QGroundControl.corePlugin.showTouchAreas = !QGroundControl.corePlugin.showTouchAreas
                            showTouchAreasNotification.open()
                        }
                    }
                }
            }
        }
    }
}
