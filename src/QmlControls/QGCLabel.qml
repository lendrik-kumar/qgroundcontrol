import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical QGCLabel
/// Defaults to Archivo Narrow. Uppercase rendering is opt-in via tacticalCaps property.
/// Matches the Aero-Tactical color palette for all label states.
Text {
    id:             control
    color:          _qgcPal.text
    antialiasing:   true
    font.pointSize: ScreenTools.defaultFontPointSize
    font.family:    ScreenTools.tacticalFontFamily    // Archivo Narrow by default

    // Optional: set to true for label-caps treatment (uppercase + letter-spacing)
    property bool   tacticalCaps:      false
    property bool   dataDisplay:       false          // true → Space Mono for telemetry values

    text:           tacticalCaps ? control._rawText.toUpperCase() : control._rawText
    property string _rawText: ""

    // Shadow the built-in 'text' property so we can uppercase it transparently
    // QML doesn't allow overriding 'text' directly; use wrapMode approach instead
    Component.onCompleted: {
        // Apply monospace font for data displays
        if (dataDisplay) {
            font.family   = ScreenTools.monoDataFontFamily
            font.bold     = true
        }
        if (tacticalCaps) {
            font.letterSpacing = TacticalTheme.labelCapsLetterSpacing
        }
    }

    QGCPalette { id: _qgcPal; colorGroupEnabled: enabled }
}
