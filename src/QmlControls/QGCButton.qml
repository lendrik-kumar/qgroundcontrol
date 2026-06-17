import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls

/// ORBITAL-GCS-v4.2 (Jarvis) QGCButton
/// Sharp corners, JetBrains Mono font, uppercase label, cyan glow effects.
Button {
    property bool   primary:             false
    property bool   showBorder:          true
    property real   backRadius:          TacticalTheme.radiusNone
    property real   heightFactor:        0.5
    property string iconSource:          ""
    property real   fontWeight:          Font.Bold
    property real   pointSize:           ScreenTools.defaultFontPointSize
    property bool   cutCorners:          false    // kept for API compat

    property alias wrapMode:             text.wrapMode
    property alias horizontalAlignment:  text.horizontalAlignment
    property alias backgroundColor:      _baseFill.color
    property alias textColor:            text.color

    id: control
    hoverEnabled:   !ScreenTools.isMobile
    topPadding:     _vPad
    bottomPadding:  _vPad
    leftPadding:    _hPad
    rightPadding:   _hPad
    focusPolicy:    Qt.ClickFocus
    font.family:    ScreenTools.monoDataFontFamily
    text:           ""

    property bool _active:   enabled && (pressed || checked)
    property int  _hPad:     ScreenTools.defaultFontPixelWidth * 1.8
    property int  _vPad:     Math.round(ScreenTools.defaultFontPixelHeight * heightFactor) - (iconSource === "" ? 0 : (_iconH - ScreenTools.defaultFontPixelHeight) / 2)
    property real _iconH:    text.height * 1.5

    // Semantic colors for Jarvis theme
    // Primary: border=primary, fill=primary/10, text=primary
    // Secondary: border=primary/40, fill=transparent, text=primary
    property color _borderColor:  primary ? TacticalTheme.primary : Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.4)
    property color _fillColor:    primary ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.1) : "transparent"
    property color _textColor:    TacticalTheme.primary

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    background: Item {
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight

        Rectangle {
            id:           _baseFill
            anchors.fill: parent
            radius:       0 // Sharp corners
            color:        control._active 
                              ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.3)
                              : control._fillColor
            border.width: showBorder ? 1 : 0
            border.color: control.enabled ? control._borderColor : TacticalTheme.outlineSubtle
            opacity:      control.enabled ? 1.0 : TacticalTheme.opacityDisabled

            Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }
        }

        // Hover fill layer
        Rectangle {
            anchors.fill: parent
            radius:       0
            color:        primary 
                              ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.2)
                              : Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.1)
            opacity:      !control._active && control.enabled && control.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
        }
        
        // Glow effect for primary buttons
        Rectangle {
            anchors.fill: parent
            radius:       0
            color:        "transparent"
            border.width: 1
            border.color: TacticalTheme.primary
            opacity:      (primary || control.hovered) && control.enabled ? 0.3 : 0
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: TacticalTheme.glowCyan
                shadowBlur: 1.0 // This corresponds to about 10-15px spread
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }
            Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
        }
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth * 0.8

        QGCColoredImage {
            id:                 icon
            Layout.alignment:   Qt.AlignHCenter
            source:             control.iconSource
            height:             _iconH
            width:              height
            color:              text.color
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            visible:            control.iconSource !== ""
        }

        QGCLabel {
            id:                  text
            Layout.alignment:    Qt.AlignHCenter
            Layout.fillWidth:    true
            horizontalAlignment: Text.AlignHCenter
            elide:               Text.ElideRight
            text:                control.text.toUpperCase()
            font.pointSize:      control.pointSize
            font.family:         ScreenTools.monoDataFontFamily
            font.weight:         fontWeight
            font.letterSpacing:  1.5
            color:               control.enabled
                                     ? control._textColor
                                     : TacticalTheme.textSecondary
            visible:             control.text !== ""
            layer.enabled:       true
            layer.effect:        MultiEffect {
                shadowEnabled: true
                shadowColor: TacticalTheme.glowCyan
                shadowBlur: 0.5
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }
        }
    }
}
