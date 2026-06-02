import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Button {
    id:             control
    padding:        ScreenTools.defaultFontPixelWidth * 0.75
    hoverEnabled:   !ScreenTools.isMobile
    autoExclusive:  true
    icon.color:     textColor

    property color textColor: checked || pressed ? qgcPal.buttonHighlightText : qgcPal.buttonText
    property bool expandable: false
    property bool expanded:   false

    signal toggleExpand()

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  control.enabled
    }

    background: Rectangle {
        color:      checked || pressed ? Qt.rgba(0.42, 0.74, 0.85, 0.18) : (enabled && hovered ? Qt.rgba(0.42, 0.74, 0.85, 0.07) : "transparent")
        border.color: checked || pressed ? qgcPal.colorBlue : (enabled && hovered ? Qt.rgba(0.42, 0.74, 0.85, 0.35) : "transparent")
        border.width: 1
        radius:     2

        // Left accent bracket indicator
        Rectangle {
            anchors.left: parent.left
            width: 3
            height: parent.height
            color: checked ? qgcPal.colorBlue : "transparent"
        }
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth

        Loader {
            sourceComponent: control.icon.source.toString().endsWith(".svg") ? svgIcon : pngIcon
            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight
            Layout.alignment:       Qt.AlignVCenter

            Component {
                id: svgIcon
                QGCColoredImage {
                    source: control.icon.source
                    color:  control.icon.color
                    anchors.fill: parent
                }
            }
            Component {
                id: pngIcon
                Image {
                    source: control.icon.source
                    sourceSize.height: ScreenTools.defaultFontPixelHeight
                    sourceSize.width: ScreenTools.defaultFontPixelHeight
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    anchors.fill: parent
                }
            }
        }

        QGCLabel {
            id:                     displayText
            Layout.fillWidth:       true
            text:                   control.text
            color:                  control.textColor
            font.family:            ScreenTools.fixedFontFamily
            font.bold:              true
            font.pixelSize:         ScreenTools.defaultFontPixelSize * 0.9
            horizontalAlignment:    QGCLabel.AlignLeft
        }

        QGCColoredImage {
            visible:    control.expandable
            source:     "/InstrumentValueIcons/cheveron-right.svg"
            color:      control.textColor
            width:      ScreenTools.defaultFontPixelHeight * 0.75
            height:     width
            rotation:   control.expanded ? 90 : 0

            MouseArea {
                anchors.fill: parent
                anchors.margins: -ScreenTools.defaultFontPixelWidth
                onClicked: control.toggleExpand()
            }
        }
    }
}
