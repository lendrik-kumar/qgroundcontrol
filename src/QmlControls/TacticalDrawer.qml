import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

TacticalPanelFrame {
    id: root

    default property alias drawerContent: contentColumn.data

    property bool expanded: true
    property string headerText: ""

    title: headerText
    implicitHeight: expanded ? contentColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 4 : ScreenTools.defaultFontPixelHeight * 3

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: ScreenTools.defaultFontPixelHeight * 0.5
        opacity: root.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }
}
