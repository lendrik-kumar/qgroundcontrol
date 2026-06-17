import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap
import QGroundControl.Viewer3D

// This is the ui overlay layer for the widgets/tools for Fly View
Item {
    id: _root

    property var    parentToolInsets
    property var    totalToolInsets:        _totalToolInsets
    property var    mapControl

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _planMasterController:  globals.planMasterControllerFlyView
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _guidedController:      globals.guidedControllerFlyView
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property real   _layoutMargin:          ScreenTools.defaultFontPixelWidth * 0.75
    property real   _layoutSpacing:         ScreenTools.defaultFontPixelWidth * 0.75
    property bool   _showSingleVehicleUI:   true

    QGCPalette { id: qgcPal }

    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeTopInset:       toolStrip.leftEdgeTopInset
        leftEdgeCenterInset:    toolStrip.leftEdgeCenterInset
        leftEdgeBottomInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.leftEdgeBottomInset : parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      rightZoneContainer.rightEdgeTopInset
        rightEdgeCenterInset:   rightZoneContainer.rightEdgeCenterInset
        rightEdgeBottomInset:   rightZoneContainer.rightEdgeBottomInset
        topEdgeLeftInset:       toolStrip.topEdgeLeftInset
        topEdgeCenterInset:     mapScale.topEdgeCenterInset
        topEdgeRightInset:      rightZoneContainer.topEdgeRightInset
        bottomEdgeLeftInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeLeftInset : parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  rightZoneContainer.bottomEdgeCenterInset
        bottomEdgeRightInset:   virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeRightInset : rightZoneContainer.bottomEdgeRightInset
    }

    Item {
        id:                 rightZoneContainer
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              Math.min(Math.max(_root.width * 0.22, ScreenTools.defaultFontPixelWidth * 24), ScreenTools.defaultFontPixelWidth * 42)
        visible:            !QGroundControl.videoManager.fullScreen && !ScreenTools.isTinyScreen

        property real rightEdgeTopInset:    visible ? width + _layoutMargin : 0
        property real rightEdgeCenterInset: visible ? width + _layoutMargin : 0
        property real rightEdgeBottomInset: visible ? width + _layoutMargin : 0
        property real topEdgeRightInset:    visible ? height : 0
        property real bottomEdgeRightInset: visible ? width + _layoutMargin : 0
        property real bottomEdgeCenterInset: visible ? ScreenTools.defaultFontPixelHeight * 2.5 : 0

        ColumnLayout {
            anchors.fill:       parent
            anchors.margins:    _layoutMargin
            spacing:            _layoutSpacing

            TacticalPanelFrame {
                Layout.fillWidth:       true
                Layout.preferredHeight: parent.height * 0.6 - (_layoutSpacing / 2)
                title:                  qsTr("FLIGHT")
                accentColor:            TacticalTheme.primary

                ColumnLayout {
                    anchors.fill: parent
                    spacing:      _layoutSpacing

                    FlyViewTopRightPanel {
                        id:                     topRightPanel
                        Layout.fillWidth:       true
                        Layout.fillHeight:      true
                        maximumHeight:          parent.height
                    }

                    FlyViewTopRightColumnLayout {
                        id:                 topRightColumnLayout
                        Layout.fillWidth:   true
                        visible:           !topRightPanel.visible
                    }
                }
            }

            TacticalPanelFrame {
                Layout.fillWidth:       true
                Layout.fillHeight:      true
                title:                  qsTr("SYS OPS")
                accentColor:            TacticalTheme.amber

                ColumnLayout {
                    anchors.fill: parent

                    FlyViewBottomRightRowLayout {
                        id:                 bottomRightRowLayout
                        Layout.fillWidth:   true
                        Layout.alignment:   Qt.AlignBottom
                    }
                }
            }
        }
    }

    FlyViewMissionCompleteDialog {
        missionController:      _missionController
        geoFenceController:     _geoFenceController
        rallyPointController:   _rallyPointController
    }

    //-- Virtual Joystick
    Loader {
        id:                         virtualJoystickMultiTouch
        z:                          QGroundControl.zOrderTopMost + 1
        anchors.right:              parent.right
        anchors.rightMargin:        anchors.leftMargin
        height:                     Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
        visible:                    _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       bottomLoaderMargin
        anchors.left:               parent.left
        anchors.leftMargin:         ( y > toolStrip.y + toolStrip.height ? toolStrip.width / 2 : toolStrip.width * 1.05 + toolStrip.x)
        source:                     "qrc:/qml/QGroundControl/FlyView/VirtualJoystick.qml"
        active:                     _virtualJoystickEnabled && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

        property real bottomEdgeLeftInset:     parent.height-y
        property bool autoCenterThrottle:      QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue
        property bool leftHandedMode:          QGroundControl.settingsManager.appSettings.virtualJoystickLeftHandedMode.rawValue
        property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
        property real bottomEdgeRightInset:    parent.height-y
        property var  _pipViewMargin:          _pipView.visible ? parentToolInsets.bottomEdgeLeftInset + ScreenTools.defaultFontPixelHeight * 2 :
                                               bottomRightRowLayout.height + ScreenTools.defaultFontPixelHeight * 1.5

        property var  bottomLoaderMargin:      _pipViewMargin >= parent.height / 2 ? parent.height / 2 : _pipViewMargin

        // Width is difficult to access directly hence this hack which may not work in all circumstances
        property real leftEdgeBottomInset:  visible ? bottomEdgeLeftInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rightEdgeBottomInset: visible ? bottomEdgeRightInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rootWidth:            _root.width
        property var  itemX:                virtualJoystickMultiTouch.x   // real X on screen

        onRootWidthChanged: virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth : undefined
        onItemXChanged:     virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiRealX = itemX : undefined

        //Loader status logic
        onLoaded: {
            if (virtualJoystickMultiTouch.visible) {
                virtualJoystickMultiTouch.item.calibration = true
                virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth
                virtualJoystickMultiTouch.item.uiRealX = itemX
            } else {
                virtualJoystickMultiTouch.item.calibration = false
            }
        }
    }

    FlyViewToolStrip {
        id:                     toolStrip
        anchors.left:           parent.left
        anchors.top:            parent.top
        z:                      QGroundControl.zOrderWidgets
        maxHeight:              parent.height - y - parentToolInsets.bottomEdgeLeftInset - _toolsMargin
        visible:                !QGroundControl.videoManager.fullScreen

        onDisplayPreFlightChecklist: {
            if (!preFlightChecklistLoader.active) {
                preFlightChecklistLoader.active = true
            }
            preFlightChecklistLoader.item.open()
        }

        property real topEdgeLeftInset:     visible ? y + height : 0
        property real leftEdgeTopInset:     visible ? x + width : 0
        property real leftEdgeCenterInset:  leftEdgeTopInset
    }

    VehicleWarnings {
        anchors.centerIn:   parent
        z:                  QGroundControl.zOrderTopMost
    }

    MapScale {
        id:                 mapScale
        anchors.left:       toolStrip.right
        anchors.leftMargin: _toolsMargin
        anchors.top:        parent.top
        mapControl:         _mapControl
        autoHide:           true
        visible:            !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale && QGCViewer3DManager.displayMode !== QGCViewer3DManager.View3D && mapControl.pipState.state === mapControl.pipState.fullState

        property real topEdgeCenterInset: visible ? y + height : 0
    }

    Loader {
        id: preFlightChecklistLoader
        sourceComponent: preFlightChecklistPopup
        active: false
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {
        }
    }

    // Tactical Command Center Overlay
    TacticalActionOverlay {
        id: tacticalOverlay
        z: QGroundControl.zOrderTopMost + 2
    }

    // ── HUD Crosshair + Artificial Horizon overlay ────────────────────────────
    FlyViewHUDOverlay {
        id:           _hudOverlay
        anchors.fill: parent
        z:            QGroundControl.zOrderWidgets - 1
        visible:      !QGroundControl.videoManager.fullScreen
    }

    // ── Tactical Bottom Action Bar ────────────────────────────────────────────
    TacticalBottomActionBar {
        id:                     _tacticalActionBar
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:                  Math.min(parent.width * 0.7, ScreenTools.defaultFontPixelWidth * 60)
        z:                      QGroundControl.zOrderWidgets
        visible:                !QGroundControl.videoManager.fullScreen && _showSingleVehicleUI
    }

    // Sci-Fi Boot Loader / Scanning Vector when no vehicle is connected
    Rectangle {
        id:                 bootLoaderOverlay
        anchors.fill:       parent
        color:              "transparent"
        visible:            false

        // Dark dimming overlay to focus on the scanner
        Rectangle {
            anchors.fill: parent
            color:        "#040B14"
            opacity:      0.65
        }

        Item {
            anchors.centerIn: parent
            width:  ScreenTools.defaultFontPixelWidth * 35
            height: ScreenTools.defaultFontPixelWidth * 35

            // ── Darshak Logo ─────────────────────────────────────────────────
            Image {
                anchors.centerIn: parent
                width:  parent.width * 0.4
                height: width
                source: "qrc:/res/darshak_logo.png"
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }

            // ── Canvas-based Radial Sweep ────────────────────────────────────
            Canvas {
                id: radialCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = (width / 2) * 0.75
                    
                    // Background track
                    ctx.beginPath()
                    ctx.lineWidth = ScreenTools.defaultFontPixelWidth * 0.3
                    ctx.strokeStyle = "rgba(0, 229, 255, 0.15)"
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                    ctx.stroke()

                    // Cyber-blue active sweep arc (90 degrees)
                    ctx.beginPath()
                    ctx.lineWidth = ScreenTools.defaultFontPixelWidth * 0.6
                    ctx.strokeStyle = "#6BBCD9"  // sky-blue from palette
                    ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI / 2)
                    ctx.stroke()
                }

                RotationAnimation on rotation {
                    loops:      Animation.Infinite
                    from:       0
                    to:         360
                    duration:   2000
                    running:    bootLoaderOverlay.visible
                }
            }

            // ── Sequential Target Nodes ──────────────────────────────────────
            Repeater {
                model: 4
                Rectangle {
                    width:  ScreenTools.defaultFontPixelWidth * 1.5
                    height: width
                    radius: width / 2
                    color:  qgcPal.window
                    border.color: qgcPal.colorBlue
                    border.width: ScreenTools.defaultFontPixelWidth * 0.3
                    
                    x: parent.width/2 - width/2 + (parent.width/2 * 0.75) * Math.cos(index * Math.PI/2)
                    y: parent.height/2 - height/2 + (parent.height/2 * 0.75) * Math.sin(index * Math.PI/2)
                    
                    opacity: 0
                    SequentialAnimation on opacity {
                        loops:      Animation.Infinite
                        running:    bootLoaderOverlay.visible
                        PauseAnimation { duration: index * 500 }
                        NumberAnimation { to: 1.0; duration: 250; easing.type: Easing.OutCubic }
                        PauseAnimation { duration: 2000 - index * 500 - 500 }
                        NumberAnimation { to: 0.0; duration: 250; easing.type: Easing.OutCubic }
                    }
                }
            }

            // ── DARSHAK Wordmark & Sub-label ─────────────────────────────────
            Column {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelHeight * 0.4
                
                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:               "DARSHAK"
                    font.family:        "Courier New"
                    font.pointSize:     ScreenTools.largeFontPointSize * 1.2
                    font.bold:          true
                    font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.6
                    color:              qgcPal.colorBlue
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:               "OBSERVER MODE — ACQUIRING LINK"
                    font.family:        "Courier New"
                    font.pointSize:     ScreenTools.smallFontPointSize
                    font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.2
                    color:              qgcPal.colorBlue
                    
                    SequentialAnimation on opacity {
                        loops:      Animation.Infinite
                        running:    bootLoaderOverlay.visible
                        NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.9; duration: 800; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
    }

    // ─── Tactical Notification Drawer ─────────────────────────────────────────
    // Semi-transparent severity-coded alert log, docked to the right edge.
    // Toggle via the pill button that stays permanently visible.

    property bool _notifDrawerOpen: false

    TacticalNotificationDrawer {
        id:             _notifDrawer
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        activeVehicle:  _root._activeVehicle
        drawerOpen:     _root._notifDrawerOpen
        z:              QGroundControl.zOrderWidgets + 1
    }

    // Toggle pill — always anchored to the right edge, vertically centred
    Rectangle {
        id:                     _notifToggleBtn
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:    _root._notifDrawerOpen ? _notifDrawer.width : 0
        width:                  ScreenTools.defaultFontPixelHeight * 1.6
        height:                 ScreenTools.defaultFontPixelHeight * 5
        radius:                 ScreenTools.defaultFontPixelHeight * 0.3
        color:                  qgcPal.window
        border.color:           qgcPal.colorBlue
        border.width:           ScreenTools.defaultFontPixelHeight * 0.08
        opacity:                0.92
        z:                      QGroundControl.zOrderWidgets + 2

        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        // Alert bell icon (text label as fallback)
        QGCLabel {
            anchors.centerIn:   parent
            text:               "🔔"
            font.pointSize:     ScreenTools.defaultFontPointSize * 0.85
            color:              qgcPal.colorBlue
        }

        QGCMouseArea {
            fillItem: parent
            onClicked: _root._notifDrawerOpen = !_root._notifDrawerOpen
        }
    }
}
