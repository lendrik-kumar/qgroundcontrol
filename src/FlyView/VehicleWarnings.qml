import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Item {
    id:                 _root
    height:             warningsCol.height
    width:              warningsCol.width
    visible:            _noGPSLockVisible || _prearmErrorVisible

    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _noGPSLockVisible:    _activeVehicle && _activeVehicle.requiresGpsFix && !_activeVehicle.coordinate.isValid
    property bool _prearmErrorVisible:  _activeVehicle && !_activeVehicle.armed && _activeVehicle.prearmError && !_activeVehicle.healthAndArmingCheckReport.supported

    QGCPalette { id: qgcPal }

    Column {
        id:         warningsCol
        spacing:    ScreenTools.defaultFontPixelHeight * 0.75

        // GPS Lock Warning (Amber)
        Rectangle {
            id:                 gpsCard
            width:              ScreenTools.defaultFontPixelWidth * 35
            height:             gpsLayout.height + ScreenTools.defaultFontPixelHeight
            color:              qgcPal.windowShade
            opacity:            _noGPSLockVisible ? 0.9 : 0
            visible:            opacity > 0
            radius:             2
            border.width:       1
            border.color:       qgcPal.alertBorder
            clip:               true

            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            RowLayout {
                id: gpsLayout
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelWidth

                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.fillHeight: true
                    color: qgcPal.alertBorder
                }
                QGCLabel {
                    text:           qsTr("NO GPS LOCK")
                    font.pointSize: ScreenTools.largeFontPointSize
                    font.weight:    Font.DemiBold
                    font.letterSpacing: 2
                    color:          qgcPal.alertBorder
                }
            }
        }

        // Prearm Error (Critical / Pulsing Red)
        Rectangle {
            id:                 prearmCard
            width:              ScreenTools.defaultFontPixelWidth * 50
            height:             prearmLayout.height + ScreenTools.defaultFontPixelHeight * 1.5
            color:              qgcPal.windowShade
            opacity:            _prearmErrorVisible ? 0.95 : 0
            visible:            opacity > 0
            radius:             2
            border.width:       1
            border.color:       qgcPal.statusFailedText
            clip:               true

            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            SequentialAnimation on border.color {
                loops: Animation.Infinite
                running: _prearmErrorVisible
                ColorAnimation { to: "#ff003c"; duration: 800 }
                ColorAnimation { to: "#4a0011"; duration: 800 }
            }

            RowLayout {
                id: prearmLayout
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: ScreenTools.defaultFontPixelWidth

                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.fillHeight: true
                    color: qgcPal.statusFailedText
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    QGCLabel {
                        text:           qsTr("PRE-ARM FAILURE")
                        font.pointSize: ScreenTools.largeFontPointSize
                        font.weight:    Font.Bold
                        font.letterSpacing: 1.5
                        color:          qgcPal.statusFailedText
                    }
                    QGCLabel {
                        Layout.fillWidth: true
                        wrapMode:       Text.WordWrap
                        color:          qgcPal.text
                        font.pointSize: ScreenTools.defaultFontPointSize
                        text:           _activeVehicle ? _activeVehicle.prearmError : ""
                    }
                }
            }
        }
    }
}
