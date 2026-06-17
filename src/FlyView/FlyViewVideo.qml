import QtQuick

import QGroundControl
import QGroundControl.Controls

Item {
    id: _root

    property Item pipView
    property Item pipState: videoPipState
    property real _hudLineWidth: Math.max(1, ScreenTools.defaultFontPixelWidth * 0.2)
    property real _hudBracketLength: ScreenTools.defaultFontPixelHeight * 1.2
    property real _hudCrosshairSize: ScreenTools.defaultFontPixelHeight * 7
    property real _hudScanSpacing: ScreenTools.defaultFontPixelHeight * 0.35

    QGCPalette { id: qgcPal }

    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id:           videoStartDelay
        interval:     2000;
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }

    //-- Video Streaming
    FlightDisplayViewVideo {
        id:             videoStreaming
        anchors.fill:   parent
        useSmallFont:   _root.pipState.state !== _root.pipState.fullState
        visible:        QGroundControl.videoManager.isStreamSource || QGroundControl.videoManager.isUvc
    }

    // Tactical Video HUD Overlay
    Item {
        id: tacticalHudOverlay
        anchors.fill: parent
        visible: videoStreaming.visible

        // Scanline effect overlay
        Repeater {
            model: Math.floor(parent.height / _root._hudScanSpacing)
            Rectangle {
                y: index * _root._hudScanSpacing
                width: parent.width
                height: _root._hudLineWidth
                color: TacticalTheme.primary
                opacity: 0.05
            }
        }

        // Center Crosshair
        Item {
            anchors.centerIn: parent
            width: _root._hudCrosshairSize
            height: _root._hudCrosshairSize

            Rectangle {
                anchors.centerIn: parent
                width: _root._hudLineWidth
                height: parent.height
                color: TacticalTheme.primary
                opacity: 0.4
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: _root._hudLineWidth
                color: TacticalTheme.primary
                opacity: 0.4
            }

            // Crosshair brackets
            Rectangle { anchors.left: parent.left; anchors.top: parent.top; width: _root._hudBracketLength; height: _root._hudLineWidth; color: qgcPal.brandingBlue }
            Rectangle { anchors.left: parent.left; anchors.top: parent.top; width: _root._hudLineWidth; height: _root._hudBracketLength; color: qgcPal.brandingBlue }

            Rectangle { anchors.right: parent.right; anchors.top: parent.top; width: _root._hudBracketLength; height: _root._hudLineWidth; color: qgcPal.brandingBlue }
            Rectangle { anchors.right: parent.right; anchors.top: parent.top; width: _root._hudLineWidth; height: _root._hudBracketLength; color: qgcPal.brandingBlue }

            Rectangle { anchors.left: parent.left; anchors.bottom: parent.bottom; width: _root._hudBracketLength; height: _root._hudLineWidth; color: qgcPal.brandingBlue }
            Rectangle { anchors.left: parent.left; anchors.bottom: parent.bottom; width: _root._hudLineWidth; height: _root._hudBracketLength; color: qgcPal.brandingBlue }

            Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: _root._hudBracketLength; height: _root._hudLineWidth; color: qgcPal.brandingBlue }
            Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: _root._hudLineWidth; height: _root._hudBracketLength; color: qgcPal.brandingBlue }
        }
    }

    QGCLabel {
        text: qsTr("Double-click to exit full screen")
        font.pointSize: ScreenTools.largeFontPointSize
        visible: QGroundControl.videoManager.fullScreen
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                labelAnimation.start()
            }
        }

        PropertyAnimation on opacity {
            id: labelAnimation
            duration: 10000
            from: 1.0
            to: 0.0
            easing.type: Easing.InExpo
        }
    }

    OnScreenGimbalController {
        id:                      onScreenGimbalController
        anchors.fill:            parent
        cameraTrackingEnabled:   !!(videoStreaming._camera && videoStreaming._camera.trackingEnabled)
    }

    OnScreenCameraTrackingController {
        id:                      cameraTrackingController
        anchors.fill:            parent
        camera:                  videoStreaming._camera
        videoWidth:              videoStreaming.getWidth()
        videoHeight:             videoStreaming.getHeight()
    }

    MouseArea {
        id:                         flyViewVideoMouseArea
        anchors.fill:               parent
        enabled:                    pipState.state === pipState.fullState

        property real _pressX:      0
        property real _pressY:      0
        property bool _dragging:    false
        readonly property real _dragThreshold: 10

        onDoubleClicked: QGroundControl.videoManager.fullScreen = !QGroundControl.videoManager.fullScreen

        onPressed: (mouse) => {
            _pressX = mouse.x
            _pressY = mouse.y
            _dragging = false
        }

        onPositionChanged: (mouse) => {
            if (!_dragging && (Math.abs(mouse.x - _pressX) >= _dragThreshold || Math.abs(mouse.y - _pressY) >= _dragThreshold)) {
                _dragging = true
                onScreenGimbalController.mouseDragStart(_pressX, _pressY)
                cameraTrackingController.mouseDragStart(_pressX, _pressY)
            }
            if (_dragging) {
                onScreenGimbalController.mouseDragPositionChanged(mouse.x, mouse.y)
                cameraTrackingController.mouseDragPositionChanged(mouse.x, mouse.y)
            }
        }

        onReleased: (mouse) => {
            if (_dragging) {
                onScreenGimbalController.mouseDragEnd()
                cameraTrackingController.mouseDragEnd(mouse.x, mouse.y)
            } else {
                onScreenGimbalController.mouseClicked(mouse.x, mouse.y)
                cameraTrackingController.mouseClicked(mouse.x, mouse.y)
            }
            _dragging = false
        }
    }

    ProximityRadarVideoView{
        anchors.fill:   parent
        vehicle:        QGroundControl.multiVehicleManager.activeVehicle
    }

    ObstacleDistanceOverlayVideo {
        id: obstacleDistance
        showText: pipState.state === pipState.fullState
    }
}
