import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls

/// TargetTelemetryPanel — Aero-Tactical data readout panel
/// Intended for the Analyze View or split Media view.
Item {
    id: root

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    implicitWidth:  ScreenTools.defaultFontPixelWidth * 35
    implicitHeight: mainLayout.implicitHeight + (TacticalTheme.panelPadding * 2)

    Rectangle {
        anchors.fill: parent
        color:        TacticalTheme.surfaceContainer
        border.color: TacticalTheme.cyanAccent
        border.width: 1
        radius:       0
        opacity:      0.9

        // Top accent
        Rectangle {
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height:        2
            color:         TacticalTheme.cyanAccent
        }
    }

    ColumnLayout {
        id:              mainLayout
        anchors.fill:    parent
        anchors.margins: TacticalTheme.panelPadding
        spacing:         TacticalTheme.spaceMD

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing:          TacticalTheme.spaceSM

            Rectangle {
                width:  3
                height: ScreenTools.defaultFontPixelHeight
                color:  TacticalTheme.cyanAccent
            }

            QGCLabel {
                Layout.fillWidth: true
                text:             "TARGET TELEMETRY"
                font.family:      ScreenTools.tacticalFontFamily
                font.pointSize:   ScreenTools.defaultFontPointSize * TacticalTheme.labelCapsSize
                font.bold:        true
                font.letterSpacing: TacticalTheme.labelCapsLetterSpacing
                color:            TacticalTheme.cyanAccent
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: TacticalTheme.outlineSubtle }

        // Telemetry Grid
        GridLayout {
            Layout.fillWidth: true
            columns:          2
            rowSpacing:       TacticalTheme.spaceMD
            columnSpacing:    TacticalTheme.spaceLG

            // ALT
            ColumnLayout {
                spacing: 0
                QGCLabel {
                    text: "ALTITUDE (m)"
                    font.family: ScreenTools.tacticalFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                    color: TacticalTheme.textSecondary
                }
                QGCLabel {
                    text: activeVehicle ? activeVehicle.altitudeRelative.value.toFixed(1) : "---.-"
                    font.family: ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.largeFontPointSize
                    font.bold: true
                    color: TacticalTheme.cyanAccent
                }
            }

            // SPD
            ColumnLayout {
                spacing: 0
                QGCLabel {
                    text: "GROUND SPD (m/s)"
                    font.family: ScreenTools.tacticalFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                    color: TacticalTheme.textSecondary
                }
                QGCLabel {
                    text: activeVehicle ? activeVehicle.groundSpeed.value.toFixed(1) : "--.-"
                    font.family: ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.largeFontPointSize
                    font.bold: true
                    color: TacticalTheme.cyanAccent
                }
            }

            // HDG
            ColumnLayout {
                spacing: 0
                QGCLabel {
                    text: "HEADING (deg)"
                    font.family: ScreenTools.tacticalFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                    color: TacticalTheme.textSecondary
                }
                QGCLabel {
                    text: activeVehicle ? activeVehicle.heading.value.toFixed(0) : "---"
                    font.family: ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.largeFontPointSize
                    font.bold: true
                    color: TacticalTheme.cyanAccent
                }
            }

            // BAT
            ColumnLayout {
                spacing: 0
                QGCLabel {
                    text: "BATTERY (%)"
                    font.family: ScreenTools.tacticalFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                    color: TacticalTheme.textSecondary
                }
                QGCLabel {
                    text: activeVehicle && activeVehicle.batteries.count > 0 ? activeVehicle.batteries.get(0).percentRemaining.value.toFixed(0) : "--"
                    font.family: ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.largeFontPointSize
                    font.bold: true
                    color: activeVehicle && activeVehicle.batteries.count > 0 && activeVehicle.batteries.get(0).percentRemaining.value < 20 ? TacticalTheme.amber : TacticalTheme.statusOk
                }
            }
        }
    }
}
