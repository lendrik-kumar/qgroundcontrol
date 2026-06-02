import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Kinetic Primary Flight Display (PFD) Altitude Tape Ladder
Item {
    id: _root
    width: ScreenTools.defaultFontPixelWidth * 8
    height: ScreenTools.defaultFontPixelHeight * 16
    clip: true

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real altitude: activeVehicle && activeVehicle.altitudeRelative && !isNaN(activeVehicle.altitudeRelative.value) ? activeVehicle.altitudeRelative.value : 0.0

    // Smooth easing for kinetic scrolling (no geometry layout reflows)
    property real _smoothedAlt: altitude
    Behavior on _smoothedAlt {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    // Tape calculations
    readonly property int _tickInterval: 5
    readonly property real _pixelsPerUnit: ScreenTools.defaultFontPixelHeight * 0.8
    // Find the nearest tick mark below current altitude
    property int _baseAlt: Math.floor(_smoothedAlt / _tickInterval) * _tickInterval
    property real _pixelOffset: (_smoothedAlt - _baseAlt) * _pixelsPerUnit

    // Semi-transparent obsidian background
    Rectangle {
        anchors.fill: parent
        color: "#0B0F19"
        opacity: 0.85
        border.color: Qt.rgba(0.42, 0.74, 0.85, 0.20) // 20% opacity cyan
        border.width: 1
    }

    // Sliding Tape
    Item {
        anchors.fill: parent
        
        // Render ticks above and below the center
        Repeater {
            model: 15
            Item {
                // index 0 to 14. Center is 7.
                property int val: _root._baseAlt + (index - 7) * _root._tickInterval
                width: parent.width
                height: 1
                
                // Position relative to center, minus the continuous sub-interval offset
                y: parent.height / 2 - ((index - 7) * _root._tickInterval * _root._pixelsPerUnit) + _root._pixelOffset

                // Graduation Tick
                Rectangle {
                    anchors.left: parent.left
                    width: val % 10 === 0 ? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 0.8
                    height: val % 10 === 0 ? 2 : 1
                    color: qgcPal.colorBlue
                }

                // Label (only on 10s)
                QGCLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
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

    // Center Bug (Current Value)
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.1
        height: ScreenTools.defaultFontPixelHeight * 1.8
        color: qgcPal.colorBlue
        radius: ScreenTools.defaultFontPixelWidth * 0.3
        
        QGCLabel {
            anchors.centerIn: parent
            text: _root.altitude.toFixed(1)
            font.family: "Courier New"
            font.pointSize: ScreenTools.defaultFontPointSize * 0.9
            font.bold: true
            color: "#0B0F19"
        }
    }
}
