import QtQuick

import QGroundControl
import QGroundControl.Controls

TacticalPanelFrame {
    id: root

    property alias heading: root.title
    property bool critical: false

    alert: critical
    panelOpacity: 0.96
    contentMargins: ScreenTools.defaultFontPixelHeight
}
