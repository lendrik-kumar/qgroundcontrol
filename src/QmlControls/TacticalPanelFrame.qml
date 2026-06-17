import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical Panel Frame
/// Sharp-cornered glass panel with optional title header in label-caps style.
/// The primary container for all HUD side panels (FLIGHT, SYS OPS, etc.)
Rectangle {
    id: root

    default property alias content: contentParent.data

    property string title:          ""
    property bool   alert:          false
    property real   panelOpacity:   0.92
    property real   contentMargins: ScreenTools.defaultFontPixelHeight * 0.65
    property color  accentColor:    alert ? TacticalTheme.signalRed : TacticalTheme.cyanAccent

    color:        TacticalTheme.surfaceContainer
    opacity:      panelOpacity
    radius:       0                 // Tactical: sharp corners
    border.width: 1
    border.color: accentColor
    clip:         true

    QGCPalette { id: qgcPal; colorGroupEnabled: root.enabled }

    // Top accent bar (2px)
    Rectangle {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        height:        2
        color:         accentColor
        opacity:       alert ? 0.9 : 0.7
    }

    // Subtle inner glow layer
    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        "transparent"
        border.width: 1
        border.color: TacticalTheme.glassStroke
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: root.contentMargins
        anchors.topMargin: root.title !== "" ? root.contentMargins : root.contentMargins
        spacing:         ScreenTools.defaultFontPixelHeight * 0.4

        // Panel header (title + optional accent line)
        RowLayout {
            Layout.fillWidth: true
            visible:          root.title !== ""
            spacing:          TacticalTheme.spaceXS

            // Left tick mark
            Rectangle {
                width:   3
                height:  ScreenTools.defaultFontPixelHeight * 0.9
                color:   root.accentColor
                radius:  0
            }

            QGCLabel {
                Layout.fillWidth:  true
                text:              root.title.toUpperCase()
                font.family:       ScreenTools.tacticalFontFamily
                font.pointSize:    ScreenTools.defaultFontPointSize * TacticalTheme.labelCapsSize
                font.bold:         true
                font.letterSpacing: TacticalTheme.labelCapsLetterSpacing
                color:             root.accentColor
            }

            // Pulsing dot for alert panels
            Rectangle {
                width:   6
                height:  6
                radius:  3
                color:   root.accentColor
                visible: root.alert

                SequentialAnimation on opacity {
                    loops:   Animation.Infinite
                    running: root.alert
                    NumberAnimation { to: 0.2; duration: TacticalTheme.durationPulse }
                    NumberAnimation { to: 1.0; duration: TacticalTheme.durationPulse }
                }
            }
        }

        // Thin divider after header
        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            root.accentColor
            opacity:          0.3
            visible:          root.title !== ""
        }

        Item {
            id:               contentParent
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth:    childrenRect.width
            implicitHeight:   childrenRect.height
        }
    }
}
