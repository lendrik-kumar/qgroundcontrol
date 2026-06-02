import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

Text {
    font.pointSize:     ScreenTools.defaultFontPointSize
    font.family:        ScreenTools.normalFontFamily
    font.letterSpacing: 0.3
    color:              qgcPal.text
    antialiasing:       true
    elide:              Text.ElideRight
    clip:               false

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
}
