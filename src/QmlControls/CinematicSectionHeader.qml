import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

RowLayout {
    id: root

    property alias text: titleLabel.text
    property color accentColor: qgcPal.brandingBlue

    spacing: ScreenTools.defaultFontPixelWidth
    implicitHeight: Math.max(titleLabel.implicitHeight, ScreenTools.defaultFontPixelHeight)

    QGCPalette { id: qgcPal; colorGroupEnabled: root.enabled }

    Rectangle {
        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 0.75
        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight
        radius: width / 2
        color: root.accentColor
        opacity: 0.9
    }

    QGCLabel {
        id: titleLabel
        Layout.fillWidth: true
        font.pointSize: ScreenTools.smallFontPointSize
        font.weight: Font.DemiBold
        color: qgcPal.text
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
        Layout.preferredHeight: 1
        color: root.accentColor
        opacity: 0.45
    }
}
