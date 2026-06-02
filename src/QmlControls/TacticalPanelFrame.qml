import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Rectangle {
    id: root

    default property alias content: contentParent.data

    property string title: ""
    property bool alert: false
    property real panelOpacity: 0.86
    property real contentMargins: ScreenTools.defaultFontPixelHeight * 0.75
    property color accentColor: alert ? qgcPal.colorRed : qgcPal.brandingBlue

    color: qgcPal.windowShade
    opacity: panelOpacity
    radius: ScreenTools.defaultBorderRadius
    border.width: 1
    border.color: accentColor
    clip: true

    QGCPalette { id: qgcPal; colorGroupEnabled: root.enabled }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: qgcPal.buttonBorder
        opacity: 0.35
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.contentMargins
        spacing: ScreenTools.defaultFontPixelHeight * 0.5

        CinematicSectionHeader {
            Layout.fillWidth: true
            text: root.title
            accentColor: root.accentColor
            visible: root.title !== ""
        }

        Item {
            id: contentParent
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
