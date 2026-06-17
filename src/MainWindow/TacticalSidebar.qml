import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls

/// TacticalSidebar — Persistent left navigation panel
///
/// Implements the Aero-Tactical shell sidebar with:
///   - Logo/wordmark at top
///   - Vehicle status badge (ID + armed state)
///   - Navigation items (Fly, Mission, Media, Configure, Settings)
///   - Collapsed icon-only mode for small screens
///   - Action Center button at bottom
///
Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string activeView: "fly"    // "fly" | "plan" | "analyze" | "configure" | "settings"
    property bool   collapsed:  false    // true: icon-only (64px), false: full (220px)

    signal viewRequested(string view)

    // ── Internals ─────────────────────────────────────────────────────────────
    property var  _vehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    width: collapsed ? TacticalTheme.sidebarIconWidth : TacticalTheme.sidebarWidth
    Behavior on width { NumberAnimation { duration: TacticalTheme.durationStandard; easing.type: Easing.OutCubic } }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(TacticalTheme.surfaceContainer.r, TacticalTheme.surfaceContainer.g, TacticalTheme.surfaceContainer.b, 0.95)

        // Right edge — Jarvis glow border
        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            width:          1
            color:          Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.4)
            layer.enabled:  true
            layer.effect:   MultiEffect {
                shadowEnabled: true
                shadowColor: TacticalTheme.glowCyan
                shadowBlur: 1.0
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header: Logo + Wordmark ───────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height:           TacticalTheme.sidebarIconWidth

            Row {
                anchors.left:            parent.left
                anchors.leftMargin:      root.collapsed ? 0 : TacticalTheme.spaceMD
                anchors.verticalCenter:  parent.verticalCenter
                anchors.horizontalCenter: root.collapsed ? parent.horizontalCenter : undefined
                spacing:                 TacticalTheme.spaceSM

                Image {
                    width:    22
                    height:   22
                    source:   "/res/darshak_logo.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap:   true
                    anchors.verticalCenter: parent.verticalCenter
                }

                QGCLabel {
                    visible:          !root.collapsed
                    text:             "ORBITAL-GCS-V4.2"
                    font.family:      ScreenTools.monoDataFontFamily
                    font.pointSize:   ScreenTools.smallFontPointSize * 0.9
                    font.bold:        true
                    font.letterSpacing: 1.0
                    color:            TacticalTheme.primary
                    anchors.verticalCenter: parent.verticalCenter
                    opacity:          root.collapsed ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
                }
            }

            // Bottom border
            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                anchors.bottom: parent.bottom
                height:         1
                color:          TacticalTheme.outlineSubtle
            }
        }

        // ── Vehicle Status Badge ──────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height:           _vehicle ? 52 : 0
            visible:          _vehicle !== null && _vehicle !== undefined
            clip:             true

            Behavior on height { NumberAnimation { duration: TacticalTheme.durationStandard } }

            RowLayout {
                anchors.fill:            parent
                anchors.leftMargin:      TacticalTheme.spaceMD
                anchors.rightMargin:     TacticalTheme.spaceSM
                anchors.topMargin:       TacticalTheme.spaceXS
                anchors.bottomMargin:    TacticalTheme.spaceXS
                spacing:                 TacticalTheme.spaceXS

                // Pulse dot — armed/disarmed state
                Rectangle {
                    width:    8
                    height:   8
                    radius:   4
                    color:    _vehicle && _vehicle.armed ? TacticalTheme.signalRed : TacticalTheme.statusOk
                    Layout.alignment: Qt.AlignVCenter

                    SequentialAnimation on opacity {
                        loops:   Animation.Infinite
                        running: _vehicle !== null && _vehicle !== undefined
                        NumberAnimation { to: 0.25; duration: TacticalTheme.durationPulse; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: TacticalTheme.durationPulse; easing.type: Easing.InOutSine }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible:          !root.collapsed
                    spacing:          0

                    opacity:          root.collapsed ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }

                    QGCLabel {
                        Layout.fillWidth: true
                        text:             _vehicle ? ("VHC-" + String(_vehicle.id).padStart(2, "0")) : ""
                        font.family:      ScreenTools.monoDataFontFamily
                        font.pointSize:   ScreenTools.defaultFontPointSize
                        font.bold:        true
                        color:            TacticalTheme.textPrimary
                        elide:            Text.ElideRight
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        text:             _vehicle
                                              ? ((_vehicle.armed ? "ARMED" : "DISARMED") + "  —  " +
                                                 (_vehicle.flightMode ? _vehicle.flightMode.toUpperCase() : "STANDBY"))
                                              : ""
                        font.family:      ScreenTools.monoDataFontFamily
                        font.pointSize:   ScreenTools.smallFontPointSize * 0.82
                        color:            _vehicle && _vehicle.armed ? TacticalTheme.signalRed : TacticalTheme.statusOk
                        elide:            Text.ElideRight
                    }
                }
            }

            // Bottom border
            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                anchors.bottom: parent.bottom
                height:         1
                color:          TacticalTheme.outlineSubtle
            }
        }

        // Top nav spacer
        Item { height: TacticalTheme.spaceSM; Layout.fillWidth: true }

        // ── Navigation Items ──────────────────────────────────────────────────
        TacticalNavItem {
            Layout.fillWidth: true
            viewId:           "fly"
            iconSource:       "/res/FlyingPaperPlane.svg"
            label:            "FLY"
            isActive:         root.activeView === "fly"
            isCollapsed:      root.collapsed
            onClicked:        root.viewRequested("fly")
        }

        TacticalNavItem {
            Layout.fillWidth: true
            viewId:           "plan"
            iconSource:       "/qmlimages/Plan.svg"
            label:            "MISSION"
            isActive:         root.activeView === "plan"
            isCollapsed:      root.collapsed
            onClicked:        root.viewRequested("plan")
        }

        TacticalNavItem {
            Layout.fillWidth: true
            viewId:           "analyze"
            iconSource:       "/qmlimages/Analyze.svg"
            label:            "MEDIA"
            isActive:         root.activeView === "analyze"
            isCollapsed:      root.collapsed
            onClicked:        root.viewRequested("analyze")
        }

        TacticalNavItem {
            Layout.fillWidth: true
            viewId:           "configure"
            iconSource:       "/res/GearWithPaperPlane.svg"
            label:            "CONFIGURE"
            isActive:         root.activeView === "configure"
            isCollapsed:      root.collapsed
            onClicked:        root.viewRequested("configure")
        }

        TacticalNavItem {
            Layout.fillWidth: true
            viewId:           "settings"
            iconSource:       "/qmlimages/Gear.svg"
            label:            "SETTINGS"
            isActive:         root.activeView === "settings"
            isCollapsed:      root.collapsed
            onClicked:        root.viewRequested("settings")
        }

        // Flexible spacer — pushes Action Center to bottom
        Item { Layout.fillHeight: true }

        // ── Action Center Button ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:           44
            color:            _acHovered ? Qt.rgba(1, 0.718, 0, 0.12) : "transparent"
            property bool _acHovered: false

            Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }

            // Top border
            Rectangle {
                anchors.left:  parent.left
                anchors.right: parent.right
                anchors.top:   parent.top
                height:        1
                color:         TacticalTheme.outlineSubtle
            }

            RowLayout {
                anchors.fill:            parent
                anchors.leftMargin:      root.collapsed ? 0 : TacticalTheme.spaceMD
                spacing:                 TacticalTheme.spaceSM
                layoutDirection:         Qt.LeftToRight

                QGCLabel {
                    Layout.alignment:   root.collapsed ? Qt.AlignHCenter | Qt.AlignVCenter : Qt.AlignVCenter
                    Layout.fillWidth:   root.collapsed
                    text:               "⚡"
                    font.pointSize:     ScreenTools.defaultFontPointSize * 0.9
                    color:              TacticalTheme.amber
                }

                QGCLabel {
                    Layout.fillWidth:   true
                    visible:            !root.collapsed
                    text:               "ACTION CENTER"
                    font.family:        ScreenTools.monoDataFontFamily
                    font.pointSize:     ScreenTools.defaultFontPointSize * 0.82
                    font.bold:          true
                    font.letterSpacing: 0.8
                    color:              TacticalTheme.amber
                    opacity:            root.collapsed ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
                }
            }

            QGCMouseArea {
                fillItem:     parent
                hoverEnabled: true
                onEntered:    parent._acHovered = true
                onExited:     parent._acHovered = false
                onClicked: {
                    mainWindow.showFlyView()
                    root.viewRequested("fly")
                }
            }
        }

        // ── Collapse toggle ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:           28
            color:            _colHovered ? TacticalTheme.surfaceContainerHigh : "transparent"
            property bool _colHovered: false

            Rectangle {
                anchors.left:  parent.left
                anchors.right: parent.right
                anchors.top:   parent.top
                height:        1
                color:         TacticalTheme.outlineSubtle
            }

            QGCLabel {
                anchors.centerIn: parent
                text:             root.collapsed ? "▶" : "◀"
                font.pointSize:   ScreenTools.smallFontPointSize * 0.85
                color:            TacticalTheme.textSecondary
            }

            QGCMouseArea {
                fillItem:     parent
                hoverEnabled: true
                onEntered:    parent._colHovered = true
                onExited:     parent._colHovered = false
                onClicked:    root.collapsed = !root.collapsed
            }
        }
    }
}
