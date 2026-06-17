import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// We implement our own TabButton to get around the fact that QtQuick.Controls TabBar does not
// support hiding tabs. This version supports hiding tabs by setting the visible property
// on the QGCTabButton instances.
Button {
    id: control
    Layout.fillWidth: true
    topPadding: _verticalPadding
    bottomPadding: _verticalPadding
    leftPadding: _horizontalPadding
    rightPadding: _horizontalPadding
    focusPolicy: Qt.ClickFocus
    checkable: true

    property bool primary: false ///< primary button for a group of buttons
    property real pointSize: ScreenTools.defaultFontPointSize ///< Point size for button text
    property bool showBorder: qgcPal.globalTheme === QGCPalette.Light
    property real backRadius: ScreenTools.defaultBorderRadius
    property real heightFactor: 0.5

    property bool _showSeparator: false
    property bool _showHighlight: enabled && (pressed | checked)
    property int _horizontalPadding: ScreenTools.defaultFontPixelWidth
    property int _verticalPadding: Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)
    property bool _showIcon: control.icon.source != ""

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id: backRect
        implicitWidth: ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        color: "transparent"
        border.width: 0

        // Hover fill
        Rectangle {
            anchors.fill: parent
            color:        TacticalTheme.cyanAccent
            opacity:      !control._showHighlight && control.enabled && control.hovered ? 0.08 : 0
            Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
        }

        // Active: cyan bottom underline
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height:         2
            color:          TacticalTheme.cyanAccent
            visible:        control.checked
            opacity:        0.95
        }

        // Subtle right separator between inactive tabs
        Rectangle {
            anchors.right:        parent.right
            anchors.top:          parent.top
            anchors.bottom:       parent.bottom
            anchors.topMargin:    _vertMargin
            anchors.bottomMargin: _vertMargin
            width:                1
            color:                TacticalTheme.outlineSubtle
            visible:              control._showSeparator

            property real _vertMargin: ScreenTools.defaultFontPixelHeight * 0.25
        }
    }

    contentItem: Item {
        implicitWidth:  _showIcon ? icon.width : text.implicitWidth
        implicitHeight: _showIcon ? icon.height : text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        QGCColoredImage {
            id:                icon
            anchors.centerIn:  parent
            source:            control.icon.source
            height:            source === "" ? 0 : ScreenTools.defaultFontPixelHeight
            width:             height
            color:             control.checked ? TacticalTheme.cyanAccent : TacticalTheme.textSecondary
            fillMode:          Image.PreserveAspectFit
            sourceSize.height: height
            visible:           _showIcon
        }

        Text {
            id:               text
            anchors.centerIn: parent
            antialiasing:     true
            text:             control.text.toUpperCase()
            font.pointSize:   control.pointSize * 0.9
            font.family:      ScreenTools.tacticalFontFamily
            font.bold:        control.checked
            font.letterSpacing: 0.7
            color:            control.checked ? TacticalTheme.cyanAccent : TacticalTheme.textSecondary
            visible:          !_showIcon
        }
    }
}
