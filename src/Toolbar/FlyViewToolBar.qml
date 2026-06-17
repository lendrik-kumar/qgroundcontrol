import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

/// FlyViewToolBar — Aero-Tactical slim status bar (Phase 3)
///
/// Design: 36px tall transparent header with Space Mono telemetry readouts.
/// Left:   vehicle ID + main status + flight mode
/// Center: guided action confirm (when active)
/// Right:  BAT / GPS / LINK / SIG indicators in monospaced cyan
///
Item {
    required property var guidedValueSlider

    id:     control
    width:  parent.width
    height: TacticalTheme.toolbarHeight

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property var    _guidedController:  globals.guidedControllerFlyView
    property real   _hPad:             TacticalTheme.spaceMD

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator()
    }

    QGCPalette { id: qgcPal }

    // ── Background — fully transparent, map/video shows through ──────────────
    Rectangle {
        anchors.fill: parent
        color:        "#E80F1419"   // 91% opacity deep space
    }

    // ── Bottom 1px cyan separator ─────────────────────────────────────────────
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          TacticalTheme.primary
        opacity:        0.5
        layer.enabled:  true
        layer.effect:   MultiEffect {
            shadowEnabled: true
            shadowColor: TacticalTheme.glowCyan
            shadowBlur: 1.0
        }
    }

    // ── Layout: Left | Center | Right ────────────────────────────────────────
    RowLayout {
        anchors.fill:            parent
        anchors.leftMargin:      _hPad
        anchors.rightMargin:     _hPad
        spacing:                 0

        // ── LEFT: Status + Mode ───────────────────────────────────────────────
        Row {
            spacing: TacticalTheme.spaceSM
            Layout.alignment: Qt.AlignVCenter

            // Main status (armed/disarmed + errors)
            MainStatusIndicator {
                id:     mainStatusIndicator
                height: control.height
            }

            // Separator
            Rectangle {
                width:   1
                height:  control.height * 0.55
                color:   TacticalTheme.outlineSubtle
                anchors.verticalCenter: parent.verticalCenter
                visible: _activeVehicle !== null
            }

            // Flight mode
            FlightModeIndicator {
                height:  control.height
                visible: _activeVehicle !== null
            }
        }

        // ── CENTER: Guided action confirm ─────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height:           control.height

            GuidedActionConfirm {
                id:                         guidedActionConfirm
                height:                     parent.height
                anchors.horizontalCenter:   parent.horizontalCenter
                guidedController:           control._guidedController
                guidedValueSlider:          control.guidedValueSlider
                messageDisplay:             guidedActionMessageDisplay
            }
        }

        // ── RIGHT: Telemetry readouts in Space Mono ───────────────────────────
        Row {
            spacing: TacticalTheme.spaceLG
            Layout.alignment: Qt.AlignVCenter
            visible: _activeVehicle !== null

            // BAT
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                QGCLabel {
                    text:           "BAT"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.72
                    color:          TacticalTheme.textSecondary
                    font.letterSpacing: 0.8
                }
                QGCLabel {
                    text:           _activeVehicle ? (_activeVehicle.battery.percentRemaining.value.toFixed(0) + "%") : "---"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.9
                    color:          {
                        if (!_activeVehicle) return TacticalTheme.textSecondary
                        var pct = _activeVehicle.battery.percentRemaining.value
                        return pct < 20 ? TacticalTheme.signalRed : pct < 40 ? TacticalTheme.amber : TacticalTheme.primary
                    }
                    font.bold: true
                }
            }

            // GPS
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                QGCLabel {
                    text:           "GPS"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.72
                    color:          TacticalTheme.textSecondary
                    font.letterSpacing: 0.8
                }
                QGCLabel {
                    text:           _activeVehicle && _activeVehicle.gps.lock.rawValue >= 3 ? "LOCK" : "SRCH"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.9
                    color:          _activeVehicle && _activeVehicle.gps.lock.rawValue >= 3 ? TacticalTheme.primary : TacticalTheme.amber
                    font.bold:      true
                }
            }

            // LINK
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                QGCLabel {
                    text:           "LINK"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.72
                    color:          TacticalTheme.textSecondary
                    font.letterSpacing: 0.8
                }
                QGCLabel {
                    text:           _activeVehicle ? (_activeVehicle.vehicleLinkManager.communicationLostEnabled ? "LOST" :
                                        (_activeVehicle.mavlinkMessageStatusMsgs.length > 0 ? "OK" : "---")) : "---"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.9
                    color:          _communicationLost ? TacticalTheme.signalRed : TacticalTheme.primary
                    font.bold:      true
                }
            }

            // SIG (RC RSSI)
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter
                visible: _activeVehicle && _activeVehicle.rcRSSI !== 255

                QGCLabel {
                    text:           "SIG"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.72
                    color:          TacticalTheme.textSecondary
                    font.letterSpacing: 0.8
                }
                QGCLabel {
                    text:           _activeVehicle ? (_activeVehicle.rcRSSI + "%") : "---"
                    font.family:    ScreenTools.monoDataFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize * 0.9
                    color:          TacticalTheme.primary
                    font.bold:      true
                }
            }

            // Icon indicators row (battery, gps, link icons)
            FlyViewToolBarIndicators {
                id:     flyViewIndicators
                height: control.height
            }
        }

        // Disconnect button (communication lost state)
        QGCButton {
            id:         disconnectButton
            text:       qsTr("Disconnect")
            primary:    true
            visible:    _activeVehicle && _communicationLost
            Layout.alignment: Qt.AlignVCenter
            onClicked:  _activeVehicle.closeVehicle()
        }
    }

    // ── Guided action message display ─────────────────────────────────────────
    Rectangle {
        id:                    guidedActionMessageDisplay
        anchors.top:           control.bottom
        anchors.topMargin:     TacticalTheme.spaceXS
        x:                     guidedActionConfirm.x + _sidebar.width + (guidedActionConfirm.width - width) / 2
        width:                 messageLabel.contentWidth + TacticalTheme.spaceLG
        height:                messageLabel.contentHeight + TacticalTheme.spaceSM
        color:                 TacticalTheme.surfaceContainerHigh
        border.width:          1
        border.color:          TacticalTheme.primary
        visible:               guidedActionConfirm.visible
        opacity:               0.95

        QGCLabel {
            id:          messageLabel
            x:           TacticalTheme.spaceSM
            y:           TacticalTheme.spaceXS
            width:       ScreenTools.defaultFontPixelWidth * 30
            wrapMode:    Text.WordWrap
            text:        guidedActionConfirm.message
            font.family: ScreenTools.monoDataFontFamily
            color:       TacticalTheme.textPrimary
        }

        PropertyAnimation {
            id:       messageOpacityAnimation
            target:   guidedActionMessageDisplay
            property: "opacity"
            from:     1
            to:       0
            duration: 500
        }

        Timer {
            id:          messageFadeTimer
            interval:    4000
            onTriggered: messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}
