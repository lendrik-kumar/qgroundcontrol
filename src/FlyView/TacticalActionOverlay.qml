import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

// Tactical Action Overlay replaces standard dropdown menus for critical operations
Rectangle {
    id:             tacticalOverlay
    anchors.fill:   parent
    color:          Qt.rgba(0.02, 0.04, 0.08, 0.85) // Dark sci-fi overlay
    visible:        false // Toggled when tactical mode is requested
    z:              QGroundControl.zOrderTopMost - 1

    property var    guidedController: globals.guidedControllerFlyView

    QGCPalette { id: qgcPal }
    
    // Tap anywhere outside the grid to close
    MouseArea {
        anchors.fill: parent
        onClicked: tacticalOverlay.visible = false
    }

    Rectangle {
        id: containerRect
        anchors.centerIn: parent
        width:  gridLayout.implicitWidth + ScreenTools.defaultFontPixelWidth * 4
        height: gridLayout.implicitHeight + ScreenTools.defaultFontPixelHeight * 4
        color:  qgcPal.windowShade
        border.color: qgcPal.colorRed
        border.width: 1
        radius: 8

        // Slide and fade fluid loader
        opacity: tacticalOverlay.visible ? 1.0 : 0.0
        transform: Translate {
            id: containerTranslate
            x: tacticalOverlay.visible ? 0 : ScreenTools.defaultFontPixelWidth * 2

            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        // Stop clicks from falling through
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: ScreenTools.defaultFontPixelHeight * 2

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("TACTICAL COMMAND CENTER")
                font.pointSize: ScreenTools.largeFontPointSize
                font.weight: Font.Bold
                font.letterSpacing: 2
                color: qgcPal.colorRed
            }

            GridLayout {
                id: gridLayout
                columns: 3
                rowSpacing: ScreenTools.defaultFontPixelHeight
                columnSpacing: ScreenTools.defaultFontPixelWidth * 2
                Layout.alignment: Qt.AlignHCenter

                // RTL Button
                QGCButton {
                    text: qsTr("RTL")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 6
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5 // Explicit tap-target requirement
                    onClicked: {
                        tacticalOverlay.visible = false
                        guidedController.confirmAction(guidedController.actionRTL)
                    }
                    enabled: guidedController.showRTL
                }

                // Land Button
                QGCButton {
                    text: qsTr("LAND")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 6
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5 // Explicit tap-target requirement
                    onClicked: {
                        tacticalOverlay.visible = false
                        guidedController.confirmAction(guidedController.actionLand)
                    }
                    enabled: guidedController.showLand
                }

                // Kill-Switch Button
                QGCButton {
                    text: qsTr("KILL SWITCH")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 6
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5 // Explicit tap-target requirement
                    onClicked: {
                        tacticalOverlay.visible = false
                        guidedController.confirmAction(guidedController.actionEmergencyStop)
                    }
                    enabled: guidedController.showEmergenyStop
                    
                    background: Rectangle {
                        color: parent.down ? qgcPal.buttonHighlight : qgcPal.colorRed
                        opacity: parent.enabled ? 1.0 : 0.4
                        radius: 4
                    }
                    contentItem: QGCLabel {
                        text: parent.text
                        color: qgcPal.buttonText
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            QGCButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: ScreenTools.defaultFontPixelHeight
                text: qsTr("CANCEL")
                onClicked: tacticalOverlay.visible = false
            }
        }
    }
}
