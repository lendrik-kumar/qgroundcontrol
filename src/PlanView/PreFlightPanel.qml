import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

/// PreFlightPanel — Aero-Tactical pre-flight checklist and global parameters
///
/// Displayed in the right panel of PlanView. Provides:
///   - GLOBAL PARAMETERS section (RTL Altitude, Loss of Comms action)
///   - SYSTEM CHECK section (pre-flight checklist)
///   - UPLOAD MISSION primary CTA button at bottom
///
Item {
    id: root

    property var planMasterController: null

    property var _missionController: planMasterController ? planMasterController.missionController : null
    property var _appSettings:       QGroundControl.settingsManager.appSettings
    property var _flyViewSettings:   QGroundControl.settingsManager.flyViewSettings

    QGCPalette { id: qgcPal }

    // ── Background glass panel ────────────────────────────────────────────────
    Rectangle {
        anchors.fill:  parent
        color:         TacticalTheme.surfaceContainer
        border.color:  TacticalTheme.primary
        border.width:  1
        radius:        0

        // Top accent bar
        Rectangle {
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height:        2
            color:         TacticalTheme.primary
            opacity:       0.7
        }
    }

    ColumnLayout {
        anchors.fill:        parent
        anchors.margins:     TacticalTheme.spaceMD
        spacing:             TacticalTheme.spaceLG

        // ── PANEL HEADER ──────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: TacticalTheme.spaceXS

            Rectangle {
                width:  2; height: ScreenTools.defaultFontPixelHeight * 0.85
                color:  TacticalTheme.primary
                radius: 0
            }

            QGCLabel {
                text:              "PRE-FLIGHT"
                font.family:       ScreenTools.monoDataFontFamily
                font.pointSize:    ScreenTools.defaultFontPointSize * TacticalTheme.labelCapsSize
                font.bold:         true
                font.letterSpacing: TacticalTheme.labelCapsLetterSpacing
                color:             TacticalTheme.primary
            }
        }

        // ── GLOBAL PARAMETERS ─────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing:          TacticalTheme.spaceXS

            QGCLabel {
                text:              "GLOBAL PARAMETERS"
                font.family:       ScreenTools.monoDataFontFamily
                font.pointSize:    ScreenTools.smallFontPointSize * 0.82
                font.bold:         true
                font.letterSpacing: 0.9
                color:             TacticalTheme.textSecondary
            }

            // Subtle divider
            Rectangle { Layout.fillWidth: true; height: 1; color: TacticalTheme.outlineSubtle }

            // RTL Altitude
            RowLayout {
                Layout.fillWidth: true
                spacing: TacticalTheme.spaceSM

                QGCLabel {
                    Layout.fillWidth:  true
                    text:              "RTL ALT (m)"
                    font.family:       ScreenTools.monoDataFontFamily
                    font.pointSize:    ScreenTools.defaultFontPointSize * 0.9
                    color:             TacticalTheme.textPrimary
                }

                QGCTextField {
                    id:                  rtlAltField
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                    text:                _appSettings ? _appSettings.defaultMissionItemAltitude.rawValue.toFixed(1) : "50.0"
                    numericValuesOnly:   true
                    onEditingFinished: {
                        if (_appSettings) _appSettings.defaultMissionItemAltitude.rawValue = parseFloat(text)
                    }
                }
            }

            // Loss of comms
            RowLayout {
                Layout.fillWidth: true
                spacing: TacticalTheme.spaceSM

                QGCLabel {
                    Layout.fillWidth: true
                    text:             "LOSS COMM"
                    font.family:      ScreenTools.monoDataFontFamily
                    font.pointSize:   ScreenTools.defaultFontPointSize * 0.9
                    color:            TacticalTheme.textPrimary
                }

                QGCLabel {
                    text:             "RTL"
                    font.family:      ScreenTools.monoDataFontFamily
                    font.pointSize:   ScreenTools.defaultFontPointSize * 0.85
                    font.bold:        true
                    color:            TacticalTheme.amber
                }
            }
        }

        // ── SYSTEM CHECK ──────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing:          TacticalTheme.spaceXS

            QGCLabel {
                text:              "SYSTEM CHECK"
                font.family:       ScreenTools.monoDataFontFamily
                font.pointSize:    ScreenTools.smallFontPointSize * 0.82
                font.bold:         true
                font.letterSpacing: 0.9
                color:             TacticalTheme.textSecondary
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: TacticalTheme.outlineSubtle }

            Repeater {
                model: [
                    { label: "FCU ONLINE",          ok: true  },
                    { label: "GPS LOCK",             ok: true  },
                    { label: "BATTERY",              ok: false },
                    { label: "RC LINK",              ok: true  },
                    { label: "DATA LINK",            ok: true  },
                    { label: "FENCE CONFIGURED",     ok: false },
                    { label: "CHECKLIST CLEARED",    ok: false }
                ]

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing:          TacticalTheme.spaceSM

                    // Square status indicator
                    Rectangle {
                        width:  8
                        height: 8
                        radius: 0
                        color:  modelData.ok ? TacticalTheme.statusOk : TacticalTheme.outlineSubtle
                        border.color: modelData.ok ? TacticalTheme.statusOk : TacticalTheme.outlineStrong
                        border.width: 1
                    }

                    QGCLabel {
                        Layout.fillWidth:  true
                        text:              modelData.label
                        font.family:       ScreenTools.monoDataFontFamily
                        font.pointSize:    ScreenTools.defaultFontPointSize * 0.85
                        color:             modelData.ok ? TacticalTheme.textPrimary : TacticalTheme.textSecondary
                    }

                    QGCLabel {
                        text:           modelData.ok ? "OK" : "PEND"
                        font.family:    ScreenTools.monoDataFontFamily
                        font.pointSize: ScreenTools.smallFontPointSize * 0.78
                        font.bold:      true
                        color:          modelData.ok ? TacticalTheme.statusOk : TacticalTheme.amber
                    }
                }
            }
        }

        // ── Spacer ────────────────────────────────────────────────────────────
        Item { Layout.fillHeight: true }

        // ── MISSION STATS ─────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing:          TacticalTheme.spaceXS
            visible:          _missionController && _missionController.visualItems.count > 1

            Rectangle { Layout.fillWidth: true; height: 1; color: TacticalTheme.outlineSubtle }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    Layout.fillWidth: true
                    text:             "WAYPOINTS"
                    font.family:      ScreenTools.monoDataFontFamily
                    font.pointSize:   ScreenTools.smallFontPointSize * 0.85
                    color:            TacticalTheme.textSecondary
                }
                QGCLabel {
                    text:           _missionController ? Math.max(0, _missionController.visualItems.count - 1).toString() : "0"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.defaultFontPointSize
                    font.bold:      true
                    color:          TacticalTheme.primary
                }
            }
        }

        // ── UPLOAD MISSION — Primary CTA ──────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:           ScreenTools.defaultFontPixelHeight * 2.5
            color:            _uploadHovered ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.2)
                                             : "transparent"
            border.color:     TacticalTheme.primary
            border.width:     1
            radius:           0

            property bool _uploadHovered: false
            Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }

            QGCLabel {
                anchors.centerIn:  parent
                text:              "UPLOAD MISSION"
                font.family:       ScreenTools.monoDataFontFamily
                font.pointSize:    ScreenTools.defaultFontPointSize
                font.bold:         true
                font.letterSpacing: 1.0
                color:             TacticalTheme.primary
            }

            QGCMouseArea {
                fillItem:     parent
                hoverEnabled: true
                onEntered:    parent._uploadHovered = true
                onExited:     parent._uploadHovered = false
                onClicked: {
                    if (planMasterController) planMasterController.upload()
                }
            }
        }
    }
}
