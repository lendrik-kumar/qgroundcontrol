import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

/// TacticalBottomActionBar — Aero-Tactical bottom action strip
///
/// Square icon buttons with ghost borders in a centered row.
/// Active button fills amber. Recording shows pulsing red dot.
/// Connects to existing GuidedActionsController actions.
///
Item {
    id: root

    property var guidedController:    globals.guidedControllerFlyView
    property var activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool isRecording:        false  // bound to VideoManager
    property bool isTracking:         false

    height: TacticalTheme.sidebarIconWidth   // 64px tall action bar
    QGCPalette { id: qgcPal }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        TacticalTheme.surfaceContainerLow
        opacity:      0.92

        // Top border
        Rectangle {
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.top:   parent.top
            height:        1
            color:         TacticalTheme.primary
            opacity:       0.35
        }
    }

    // ── Action Button Row ─────────────────────────────────────────────────────
    Row {
        anchors.centerIn: parent
        spacing:          TacticalTheme.spaceMD

        // LAUNCH / TAKEOFF
        TacticalActionButton {
            id:         launchBtn
            label:      guidedController && guidedController.showTakeoff ? "LAUNCH" : "ARM"
            iconCode:   "▲"
            enabled:    guidedController && (guidedController.showTakeoff || guidedController.showArm)
            accentColor: TacticalTheme.primary
            onTapped: {
                if (guidedController.showTakeoff)
                    guidedController.confirmAction(guidedController.actionTakeoff)
                else if (guidedController.showArm)
                    guidedController.confirmAction(guidedController.actionArm)
            }
        }

        // SNAP (photo capture)
        TacticalActionButton {
            id:         snapBtn
            label:      "SNAP"
            iconCode:   "⊙"
            enabled:    activeVehicle !== null
            accentColor: TacticalTheme.primary
            onTapped:   QGroundControl.videoManager.grabImage()
        }

        // REC (video record toggle)
        TacticalActionButton {
            id:         recBtn
            label:      root.isRecording ? "STOP" : "REC"
            iconCode:   "●"
            enabled:    activeVehicle !== null
            accentColor: root.isRecording ? TacticalTheme.signalRed : TacticalTheme.primary
            isActive:   root.isRecording
            onTapped: {
                if (root.isRecording) QGroundControl.videoManager.stopRecording()
                else                  QGroundControl.videoManager.startRecording()
                root.isRecording = !root.isRecording
            }

            // Pulsing red dot on top-right when recording
            Rectangle {
                anchors.top:        parent.top
                anchors.topMargin:  4
                anchors.right:      parent.right
                anchors.rightMargin: 4
                width:   6
                height:  6
                radius:  3
                color:   TacticalTheme.signalRed
                visible: root.isRecording

                SequentialAnimation on opacity {
                    loops:   Animation.Infinite
                    running: root.isRecording
                    NumberAnimation { to: 0.1; duration: 600 }
                    NumberAnimation { to: 1.0; duration: 600 }
                }
            }
        }

        // TRACK (object tracking toggle)
        TacticalActionButton {
            id:          trackBtn
            label:       root.isTracking ? "UNTRACK" : "TRACK"
            iconCode:    "◎"
            enabled:     activeVehicle !== null
            accentColor: root.isTracking ? TacticalTheme.amber : TacticalTheme.primary
            isActive:    root.isTracking
            onTapped:    root.isTracking = !root.isTracking
        }

        // RTL (Return to Launch)
        TacticalActionButton {
            id:          rtlBtn
            label:       "RTL"
            iconCode:    "↩"
            enabled:     guidedController && guidedController.showRTL
            accentColor: TacticalTheme.signalRed
            onTapped:    guidedController && guidedController.confirmAction(guidedController.actionRTL)
        }

        // PAUSE
        TacticalActionButton {
            id:         pauseBtn
            label:      "PAUSE"
            iconCode:   "⏸"
            enabled:    guidedController && guidedController.showPause
            accentColor: TacticalTheme.amber
            onTapped:   guidedController && guidedController.confirmAction(guidedController.actionPause)
        }
    }

    // ── Inner component: single action button ─────────────────────────────────
    component TacticalActionButton: Rectangle {
        id:         _btn
        width:      52
        height:     52
        color:      isActive ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.18) : "transparent"
        border.color: enabled ? accentColor : TacticalTheme.outlineSubtle
        border.width: 1
        radius:     0

        property string label:       ""
        property string iconCode:    ""
        property color  accentColor: TacticalTheme.primary
        property bool   isActive:    false

        signal tapped()

        Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }

        // Hover fill
        Rectangle {
            anchors.fill: parent
            color:        Qt.rgba(_btn.accentColor.r, _btn.accentColor.g, _btn.accentColor.b, 0.1)
            visible:      _hoverArea.containsMouse && _btn.enabled
        }

        Column {
            anchors.centerIn: parent
            spacing:          2

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text:             _btn.iconCode
                font.pointSize:   ScreenTools.defaultFontPointSize
                color:            _btn.enabled ? _btn.accentColor : TacticalTheme.outlineSubtle
            }

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text:             _btn.label
                font.family:      ScreenTools.monoDataFontFamily
                font.pointSize:   ScreenTools.smallFontPointSize * 0.72
                font.bold:        true
                font.letterSpacing: 0.4
                color:            _btn.enabled ? _btn.accentColor : TacticalTheme.outlineSubtle
            }
        }

        QGCMouseArea {
            id:          _hoverArea
            fillItem:    parent
            hoverEnabled: true
            onClicked:   if (_btn.enabled) _btn.tapped()
        }
    }
}
