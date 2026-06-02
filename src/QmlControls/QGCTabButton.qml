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
        // Transparent base — active state shown via bottom neon accent bar
        color: _showHighlight ? Qt.rgba(0, 0.85, 1.0, 0.10) : (control.enabled && control.hovered ? qgcPal.toolStripHoverColor : qgcPal.button)
        border.width: 0

        // Neon bottom-border active indicator (modern HUD tab style)
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height:         2
            color:          qgcPal.colorBlue
            visible:        control.checked
            opacity:        0.9
        }

        // Subtle right separator between inactive tabs
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: _vertMargin
            anchors.bottomMargin: _vertMargin
            width: 1
            color: Qt.darker(qgcPal.buttonText, 1.5)
            visible: control._showSeparator

            property real _vertMargin: ScreenTools.defaultFontPixelHeight * 0.25
        }
    }

    contentItem: Item {
        implicitWidth: _showIcon ? icon.width : text.implicitWidth
        implicitHeight: _showIcon ? icon.height : text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        QGCColoredImage {
            id: icon
            anchors.centerIn: parent
            source: control.icon.source
            height: source === "" ? 0 : ScreenTools.defaultFontPixelHeight
            width: height
            color: _showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
            visible: _showIcon
        }

        Text {
            id: text
            anchors.centerIn: parent
            antialiasing: true
            text: control.text
            font.pointSize: control.pointSize
            font.family: ScreenTools.normalFontFamily
            font.letterSpacing: 0.5
            color: _showHighlight ? qgcPal.colorBlue : qgcPal.buttonText
            visible: !_showIcon
        }
    }
}
