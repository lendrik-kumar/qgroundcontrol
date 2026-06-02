import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactControls
import QGroundControl.Controls

Item {
    id: root

    default property alias contentItem: mainLayout.data
    property int sectionFilter: -1

    QGCFlickable {
        anchors.fill:   parent
        contentWidth:   mainLayout.width
        contentHeight:  mainLayout.height

        ColumnLayout {
            id:         mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: ScreenTools.defaultFontPixelWidth * 2
            spacing:    ScreenTools.defaultFontPixelHeight * 1.5
        }
    }
}
