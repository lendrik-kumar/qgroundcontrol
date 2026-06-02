import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

TacticalPanelFrame {
    id: root

    property string label: ""
    property string value: ""
    property string units: ""
    property bool warning: false

    alert: warning
    implicitWidth: ScreenTools.defaultFontPixelWidth * 12
    implicitHeight: ScreenTools.defaultFontPixelHeight * 5
    contentMargins: ScreenTools.defaultFontPixelHeight * 0.5

    QGCPalette { id: qgcPal; colorGroupEnabled: root.enabled }

    ColumnLayout {
        anchors.fill: parent
        spacing: ScreenTools.defaultFontPixelHeight * 0.25

        QGCLabel {
            Layout.fillWidth: true
            text: root.label
            color: qgcPal.buttonText
            font.pointSize: ScreenTools.smallFontPointSize
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelWidth * 0.5

            QGCLabel {
                Layout.fillWidth: true
                text: root.value
                color: root.warning ? qgcPal.colorOrange : qgcPal.text
                font.pointSize: ScreenTools.largeFontPointSize
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            QGCLabel {
                text: root.units
                color: qgcPal.buttonText
                font.pointSize: ScreenTools.smallFontPointSize
                visible: root.units !== ""
            }
        }
    }
}
