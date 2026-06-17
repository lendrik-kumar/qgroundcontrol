import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical SectionHeader
/// Thin top cyan line + uppercase Archivo Narrow label + expand chevron.
/// Matches the reference DESIGN.md "label-caps" section divider style.
CheckBox {
    id:             control
    focusPolicy:    Qt.ClickFocus
    checked:        true
    leftPadding:    0

    property var            color:       TacticalTheme.cyanAccent
    property bool           showSpacer:  true
    property ButtonGroup    buttonGroup: null

    property real _spacer: ScreenTools.defaultFontPixelWidth * 0.5

    onButtonGroupChanged: {
        if (buttonGroup) buttonGroup.addButton(control)
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    contentItem: ColumnLayout {
        spacing: 0

        Item {
            Layout.preferredHeight: control._spacer
            width:                  1
            visible:                control.showSpacer
        }

        // Top cyan accent line
        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            control.color
            opacity:          0.7
        }

        // Label row
        RowLayout {
            Layout.fillWidth: true
            spacing:          TacticalTheme.spaceXS

            QGCLabel {
                Layout.fillWidth: true
                text:             control.text.toUpperCase()
                font.family:      ScreenTools.tacticalFontFamily
                font.pointSize:   ScreenTools.defaultFontPointSize * TacticalTheme.labelCapsSize
                font.bold:        true
                font.letterSpacing: TacticalTheme.labelCapsLetterSpacing
                color:            control.color
            }

            QGCColoredImage {
                width:   ScreenTools.defaultFontPixelHeight * 0.5
                height:  width
                source:  control.checked ? "/qmlimages/arrow-down.png" : "/qmlimages/arrow-down.png"
                color:   control.color
                rotation: control.checked ? 0 : -90
                Behavior on rotation { NumberAnimation { duration: TacticalTheme.durationFast } }
            }
        }

        // Bottom subtle divider line
        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            TacticalTheme.outlineSubtle
            opacity:          0.6
        }

        Item {
            Layout.preferredHeight: control._spacer * 0.5
            width:                  1
        }
    }

    indicator: Item {}
}
