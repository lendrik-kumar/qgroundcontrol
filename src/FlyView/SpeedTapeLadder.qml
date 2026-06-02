import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Kinetic Primary Flight Display (PFD) Speed Tape Ladder
Item {
    id: _root
    width: ScreenTools.defaultFontPixelWidth * 8
    height: ScreenTools.defaultFontPixelHeight * 16
    clip: true

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real speed: activeVehicle && activeVehicle.groundSpeed && !isNaN(activeVehicle.groundSpeed.value) ? activeVehicle.groundSpeed.value : 0.0
    property real warnSpeed: 15.0 // Amber warning threshold

    // Smooth easing for kinetic scrolling
    property real _smoothedSpeed: speed
    Behavior on _smoothedSpeed {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    readonly property int _tickInterval: 2
    readonly property real _pixelsPerUnit: ScreenTools.defaultFontPixelHeight * 2.0
    property int _baseSpeed: Math.floor(_smoothedSpeed / _tickInterval) * _tickInterval
    property real _pixelOffset: (_smoothedSpeed - _baseSpeed) * _pixelsPerUnit

    Rectangle {
        anchors.fill: parent
        color: "#0B0F19"
        opacity: 0.85
        border.color: Qt.rgba(0.42, 0.74, 0.85, 0.20) // 20% opacity cyan
        border.width: 1
    }

    Item {
        anchors.fill: parent
        
        Repeater {
            model: 15
            Item {
                property int val: _root._baseSpeed + (index - 7) * _root._tickInterval
                width: parent.width
                height: 1
                
                y: parent.height / 2 - ((index - 7) * _root._tickInterval * _root._pixelsPerUnit) + _root._pixelOffset

                // Tick on the right
                Rectangle {
                    anchors.right: parent.right
                    width: val % 10 === 0 ? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 0.8
                    height: val % 10 === 0 ? 2 : 1
                    color: qgcPal.colorBlue
                }

                QGCLabel {
                    anchors.right: parent.right
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 2
                    anchors.verticalCenter: parent.verticalCenter
                    text: val.toString()
                    font.family: "Courier New"
                    font.pointSize: ScreenTools.smallFontPointSize
                    font.bold: true
                    color: qgcPal.colorBlue
                    visible: val % 10 === 0
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.1
        height: ScreenTools.defaultFontPixelHeight * 1.8
        color: _root.speed >= _root.warnSpeed ? "#FFB300" : qgcPal.colorBlue
        radius: ScreenTools.defaultFontPixelWidth * 0.3
        
        QGCLabel {
            anchors.centerIn: parent
            text: _root.speed.toFixed(1)
            font.family: "Courier New"
            font.pointSize: ScreenTools.defaultFontPointSize * 0.9
            font.bold: true
            color: "#0B0F19"
        }
    }
}
