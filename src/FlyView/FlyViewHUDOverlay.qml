import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// FlyViewHUDOverlay — Aero-Tactical Canvas HUD crosshair + horizon overlay
///
/// Draws thin 0.5px cyan bracket frames and a roll/pitch horizon band
/// over the video feed. Shown only when video is active.
///
Item {
    id: root

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real roll:         activeVehicle && !isNaN(activeVehicle.roll.value)  ? activeVehicle.roll.value  : 0
    property real pitch:        activeVehicle && !isNaN(activeVehicle.pitch.value) ? activeVehicle.pitch.value : 0
    property bool targetLocked: false   // set externally by OnScreenCameraTrackingController

    // Smooth the artificial horizon
    property real _smoothRoll:  roll
    property real _smoothPitch: pitch
    Behavior on _smoothRoll  { NumberAnimation { duration: 120 } }
    Behavior on _smoothPitch { NumberAnimation { duration: 120 } }

    // ── Bracketed corner frames ───────────────────────────────────────────────
    // Four L-shaped corner brackets defining the field of view frame
    Canvas {
        id: bracketCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property real len:   44    // bracket arm length (px)
        property real thick: 0.8   // line thickness

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Qt.rgba(0, 0.859, 0.906, 0.7)   // #00DBE7 at 70%
            ctx.lineWidth   = thick

            var m = 28  // inset from screen edge

            // Top-left
            ctx.beginPath(); ctx.moveTo(m, m + len); ctx.lineTo(m, m); ctx.lineTo(m + len, m); ctx.stroke()
            // Top-right
            ctx.beginPath(); ctx.moveTo(width - m - len, m); ctx.lineTo(width - m, m); ctx.lineTo(width - m, m + len); ctx.stroke()
            // Bottom-left
            ctx.beginPath(); ctx.moveTo(m, height - m - len); ctx.lineTo(m, height - m); ctx.lineTo(m + len, height - m); ctx.stroke()
            // Bottom-right
            ctx.beginPath(); ctx.moveTo(width - m - len, height - m); ctx.lineTo(width - m, height - m); ctx.lineTo(width - m, height - m - len); ctx.stroke()
        }

        Component.onCompleted: requestPaint()
        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
    }

    // ── Crosshair / boresight center ─────────────────────────────────────────
    Canvas {
        id: crosshairCanvas
        anchors.centerIn: parent
        width:  60
        height: 60

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Qt.rgba(0, 0.859, 0.906, 0.8)
            ctx.lineWidth   = 0.8

            var cx = width / 2
            var cy = height / 2
            var gap = 6     // gap around center point

            // Horizontal arms
            ctx.beginPath(); ctx.moveTo(0, cy); ctx.lineTo(cx - gap, cy); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(cx + gap, cy); ctx.lineTo(width, cy); ctx.stroke()
            // Vertical arms
            ctx.beginPath(); ctx.moveTo(cx, 0); ctx.lineTo(cx, cy - gap); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(cx, cy + gap); ctx.lineTo(cx, height); ctx.stroke()
        }
        Component.onCompleted: requestPaint()
    }

    // ── Artificial horizon line (rotates with roll) ───────────────────────────
    Item {
        anchors.centerIn: parent
        width:   parent.width * 0.5
        height:  4
        rotation: -_smoothRoll

        // pitch offset shifts the bar vertically (3px per degree of pitch)
        transform: Translate { y: _smoothPitch * 3 }

        Rectangle {
            anchors.fill:    parent
            anchors.margins: parent.height
            height:          1
            color:           TacticalTheme.amber
            opacity:         0.7
        }
    }

    // ── Target lock box (amber, appears when targetLocked = true) ─────────────
    Rectangle {
        anchors.centerIn: parent
        width:    48
        height:   48
        color:    "transparent"
        border.color: targetLocked ? TacticalTheme.signalRed  : TacticalTheme.amber
        border.width: 1.5
        visible:      targetLocked || _lockPulse.running

        SequentialAnimation on opacity {
            id:      _lockPulse
            loops:   5
            running: false
            NumberAnimation { to: 0.2; duration: 200 }
            NumberAnimation { to: 1.0; duration: 200 }
        }

        onVisibleChanged: { if (visible) _lockPulse.start() }
    }
}
