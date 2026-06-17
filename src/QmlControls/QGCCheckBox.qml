import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls

CheckBox {
    id:             control
    spacing:        _noText ? 0 : ScreenTools.defaultFontPixelWidth
    focusPolicy:    Qt.ClickFocus
    leftPadding:    0

    Component.onCompleted: {
        if (_noText) {
            rightPadding = 0
        }
    }

    property color  textColor:          qgcPal.buttonText
    property bool   textBold:           false
    property real   textFontPointSize:  ScreenTools.defaultFontPointSize
    property ButtonGroup buttonGroup: null

    property bool _noText: text === ""

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    onButtonGroupChanged: {
        if (buttonGroup) {
            buttonGroup.addButton(control)
        }
    }

    contentItem: Text {
        leftPadding:        control.indicator.width + control.spacing
        verticalAlignment:  Text.AlignVCenter
        text:               control.text
        font.pointSize:     textFontPointSize
        font.bold:          control.textBold
        font.family:        ScreenTools.monoDataFontFamily
        font.letterSpacing: 0.6
        color:              control.textColor
    }

    indicator:  Rectangle {
        id:             indicatorRect
        implicitWidth:  ScreenTools.implicitCheckBoxHeight
        implicitHeight: implicitWidth
        x:              control.leftPadding
        y:              parent.height / 2 - height / 2
        color:          "transparent"
        border.color:   control.checked ? TacticalTheme.primary : TacticalTheme.outlineSubtle
        border.width:   1
        radius:         0    // Jarvis: sharp edges
        opacity:        control.enabled ? (control.checkedState === Qt.PartiallyChecked ? 0.5 : 1.0) : TacticalTheme.opacityDisabled

        // Inner glowing fill when checked
        Rectangle {
            anchors.fill:   parent
            anchors.margins: 3
            color:          TacticalTheme.primary
            visible:        control.checked
            opacity:        0.9
            layer.enabled:  true
            layer.effect:   MultiEffect {
                shadowEnabled: true
                shadowColor: TacticalTheme.glowCyan
                shadowBlur: 1.0
            }
        }

        // Hover effect
        Rectangle {
            anchors.fill:   parent
            color:          TacticalTheme.primary
            opacity:        control.hovered && !control.checked ? 0.1 : 0
        }
    }
}
