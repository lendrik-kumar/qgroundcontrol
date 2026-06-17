import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical Altitude Tape Ladder
/// Dark glass panel, neon cyan tick marks, Space Mono readout, no rounded corners
Item {
    id: _root
    width:  ScreenTools.defaultFontPixelWidth * 8
    height: ScreenTools.defaultFontPixelHeight * 16
    clip:   true

    property var  activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real altitude:      activeVehicle && activeVehicle.altitudeRelative && !isNaN(activeVehicle.altitudeRelative.value)
                                     ? activeVehicle.altitudeRelative.value : 0.0

    property real _smoothedAlt: altitude
    Behavior on _smoothedAlt {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    readonly property int  _tickInterval:   5
    readonly property real _pixelsPerUnit:  ScreenTools.defaultFontPixelHeight * 0.8
    property int  _baseAlt:                 Math.floor(_smoothedAlt / _tickInterval) * _tickInterval
    property real _pixelOffset:             (_smoothedAlt - _baseAlt) * _pixelsPerUnit

    QGCPalette { id: qgcPal }

    // ── Glass background ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill:  parent
        color:         TacticalTheme.surfaceContainer
        opacity:       TacticalTheme.opacityGlass
        border.color:  TacticalTheme.primary
        border.width:  1
        radius:        0    // sharp tactical corners
    }

    // ── Right edge accent ─────────────────────────────────────────────────────
    Rectangle {
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        width:          2
        color:          TacticalTheme.primary
        opacity:        0.6
    }

    // ── Sliding tape ──────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        Repeater {
            model: 15
            Item {
                property int val: _root._baseAlt + (index - 7) * _root._tickInterval
                width:  parent.width
                height: 1
                y:      parent.height / 2 - ((index - 7) * _root._tickInterval * _root._pixelsPerUnit) + _root._pixelOffset

                // Tick mark — major (10s) vs minor (5s)
                Rectangle {
                    anchors.left: parent.left
                    width:  val % 10 === 0 ? ScreenTools.defaultFontPixelWidth * 2.0 : ScreenTools.defaultFontPixelWidth * 1.0
                    height: val % 10 === 0 ? 2 : 1
                    color:  TacticalTheme.primary
                    opacity: val % 10 === 0 ? 0.9 : 0.45
                }

                // Label — only on major ticks
                QGCLabel {
                    anchors.left:          parent.left
                    anchors.leftMargin:    ScreenTools.defaultFontPixelWidth * 2.4
                    anchors.verticalCenter: parent.verticalCenter
                    text:          val.toString()
                    font.family:   ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.82
                    color:         TacticalTheme.primary
                    visible:       val % 10 === 0
                }
            }
        }
    }

    // ── Center readout bug ────────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:    parent.width + 2     // slight overshoot for pointer feel
        height:   ScreenTools.defaultFontPixelHeight * 1.6
        color:    TacticalTheme.primary
        radius:   0                    // sharp corners — tactical

        QGCLabel {
            anchors.centerIn: parent
            text:             _root.altitude.toFixed(1)
            font.family:      ScreenTools.monoDataFontFamily
            font.pointSize:   ScreenTools.defaultFontPointSize * 0.85
            font.bold:        true
            color:            TacticalTheme.textOnAccent
        }
    }
}
