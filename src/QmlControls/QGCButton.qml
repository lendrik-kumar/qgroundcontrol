import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Standard push button control:
///     If there is both an icon and text the icon will be to the left of the text
///     If icon only, icon will be centered
Button {
    property bool primary: false
    property bool showBorder: true
    property real backRadius: ScreenTools.defaultBorderRadius
    property real heightFactor: 0.5
    property string iconSource: ""
    property real fontWeight: Font.Normal // default for qml Text
    property real pointSize: ScreenTools.defaultFontPointSize
    property bool cutCorners: true

    property alias wrapMode: text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment
    property alias backgroundColor: baseFill.color
    property alias textColor: text.color

    id: control
    hoverEnabled: !ScreenTools.isMobile
    topPadding: _verticalPadding
    bottomPadding: _verticalPadding
    leftPadding: _horizontalPadding
    rightPadding: _horizontalPadding
    focusPolicy: Qt.ClickFocus
    font.family: ScreenTools.normalFontFamily
    text: ""

    property bool _showHighlight: enabled && (pressed | checked)
    property int _horizontalPadding: ScreenTools.defaultFontPixelWidth * 2
    property int _verticalPadding: Math.round(ScreenTools.defaultFontPixelHeight * heightFactor) - (iconSource === "" ? 0 : (_iconHeight - ScreenTools.defaultFontPixelHeight)  / 2)
    property real _iconHeight: text.height * 1.5

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    background: Item {
        id: backRect
        implicitWidth: ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight

        Rectangle {
            id: baseFill
            anchors.fill: parent
            radius: cutCorners ? Math.max(2, backRadius - 2) : backRadius
            color: primary ? qgcPal.primaryButton : qgcPal.button
            border.width: showBorder ? 1 : 0
            border.color: qgcPal.buttonBorder
        }

        Rectangle {
            id: edgeGlow
            anchors.fill: parent
            radius: backRadius
            color: "transparent"
            border.width: 1
            border.color: _showHighlight ? qgcPal.buttonHighlight : qgcPal.buttonBorder
            opacity: _showHighlight ? 0.9 : control.enabled && control.hovered ? 0.5 : 0.25
        }

        Rectangle {
            anchors.fill: parent
            radius: backRadius
            color: qgcPal.buttonHighlight
            opacity: _showHighlight ? 0.22 : control.enabled && control.hovered ? 0.12 : 0
        }
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth

        QGCColoredImage {
            id: icon
            Layout.alignment: Qt.AlignHCenter
            source: control.iconSource
            height: _iconHeight
            width: height
            color: text.color
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
            visible: control.iconSource !== ""
        }

        QGCLabel {
            id: text
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: control.text
            font.pointSize: control.pointSize
            font.family: control.font.family
            font.weight: fontWeight
            font.letterSpacing: 0.6
            color: _showHighlight ? qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
            visible: control.text !== ""
        }
    }
}
