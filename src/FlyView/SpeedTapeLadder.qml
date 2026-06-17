import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical Speed Tape Ladder
/// Dark glass panel, neon cyan ticks (amber when > warnSpeed), Space Mono readout
Item {
    id: _root
    width:  ScreenTools.defaultFontPixelWidth * 8
    height: ScreenTools.defaultFontPixelHeight * 16
    clip:   true

    property var  activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real speed:         activeVehicle && activeVehicle.groundSpeed && !isNaN(activeVehicle.groundSpeed.value)
                                     ? activeVehicle.groundSpeed.value : 0.0
    property real warnSpeed:     15.0

    property real _smoothedSpeed: speed
    Behavior on _smoothedSpeed {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    readonly property int  _tickInterval:  2
    readonly property real _pixelsPerUnit: ScreenTools.defaultFontPixelHeight * 2.0
    property int  _baseSpeed:             Math.floor(_smoothedSpeed / _tickInterval) * _tickInterval
    property real _pixelOffset:           (_smoothedSpeed - _baseSpeed) * _pixelsPerUnit

    // Semantic accent color: amber when overspeeding, cyan otherwise
    property color _bugColor: speed >= warnSpeed ? TacticalTheme.amber : TacticalTheme.primary

    QGCPalette { id: qgcPal }

    // ── Glass background ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill:  parent
        color:         TacticalTheme.surfaceContainer
        opacity:       TacticalTheme.opacityGlass
        border.color:  _root._bugColor
        border.width:  1
        radius:        0
    }

    // ── Left edge accent ──────────────────────────────────────────────────────
    Rectangle {
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        width:          2
        color:          _root._bugColor
        opacity:        0.6
    }

    // ── Sliding tape ──────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        Repeater {
            model: 15
            Item {
                property int val: _root._baseSpeed + (index - 7) * _root._tickInterval
                width:  parent.width
                height: 1
                y:      parent.height / 2 - ((index - 7) * _root._tickInterval * _root._pixelsPerUnit) + _root._pixelOffset

                // Tick — right-aligned (speed tape is on the left, ticks face right)
                Rectangle {
                    anchors.right: parent.right
                    width:  val % 10 === 0 ? ScreenTools.defaultFontPixelWidth * 2.0 : ScreenTools.defaultFontPixelWidth * 1.0
                    height: val % 10 === 0 ? 2 : 1
                    color:  _root._bugColor
                    opacity: val % 10 === 0 ? 0.9 : 0.45
                }

                QGCLabel {
                    anchors.right:         parent.right
                    anchors.rightMargin:   ScreenTools.defaultFontPixelWidth * 2.4
                    anchors.verticalCenter: parent.verticalCenter
                    text:          val.toString()
                    font.family:   ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.82
                    color:         _root._bugColor
                    visible:       val % 10 === 0
                }
            }
        }
    }

    // ── Center readout bug ────────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:    parent.width + 2
        height:   ScreenTools.defaultFontPixelHeight * 1.6
        color:    _root._bugColor
        radius:   0

        QGCLabel {
            anchors.centerIn: parent
            text:             _root.speed.toFixed(1)
            font.family:      ScreenTools.monoDataFontFamily
            font.pointSize:   ScreenTools.defaultFontPointSize * 0.85
            font.bold:        true
            color:            TacticalTheme.textOnAccent
        }
    }
}
