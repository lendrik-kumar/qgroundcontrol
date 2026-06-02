import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Item {
    id:             control
    implicitWidth:  mainLayout.width + (_toolsMargin * 2)
    implicitHeight: mainLayout.height + (_toolsMargin * 2)

    property real extraWidth: 0 ///< Extra width to add to the background rectangle
    property real _toolsMargin: ScreenTools.defaultFontPixelHeight * 0.5
    property real _accentWidth: Math.max(1, ScreenTools.defaultFontPixelWidth * 0.3)
    property real _accentLength: ScreenTools.defaultFontPixelHeight * 1.2

    property alias factValueGrid:           factValueGrid
    property alias settingsGroup:           factValueGrid.settingsGroup
    property alias specificVehicleForCard:  factValueGrid.specificVehicleForCard

    QGCPalette { id: qgcPal }

    Rectangle {
        id:         backgroundRect
        width:      control.width + extraWidth
        height:     control.height
        color:      qgcPal.windowShade
        radius:     ScreenTools.defaultBorderRadius
        opacity:    0.90
        clip:       true

        // Main HUD container border
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: qgcPal.colorBlue
            opacity: 0.6
        }

        // Left accent bar
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: _accentWidth
            color: qgcPal.colorBlue
        }

        // Diagonal cut / sci-fi styling accent
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: _accentLength
            height: _accentWidth
            color: qgcPal.colorBlue
        }
    }

    ColumnLayout {
        id:                 mainLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

        RowLayout {
            visible: factValueGrid.settingsUnlocked

            QGCColoredImage {
                source:             "qrc:/InstrumentValueIcons/lock-open.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.colorBlue
                fillMode:           Image.PreserveAspectFit

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    factValueGrid.settingsUnlocked = false
                }
            }
        }

        HorizontalFactValueGrid {
            id: factValueGrid
        }
    }

    QGCMouseArea {
        id:                         mouseArea
        x:                          mainLayout.x
        y:                          mainLayout.y
        width:                      mainLayout.width
        height:                     mainLayout.height
        acceptedButtons:            Qt.LeftButton | Qt.RightButton
        propagateComposedEvents:    true
        visible:                    !factValueGrid.settingsUnlocked

        onClicked: (mouse) => {
            if (!ScreenTools.isMobile && mouse.button === Qt.RightButton) {
                factValueGrid.settingsUnlocked = true
                mouse.accepted = true
            }
        }

        onPressAndHold: (mouse) => {
            factValueGrid.settingsUnlocked = true
            mouse.accepted = true
        }
    }
}
