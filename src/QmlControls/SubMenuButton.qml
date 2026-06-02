import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// Important Note: SubMenuButtons must manage their checked state manually in order to support
// view switch prevention. This means they can't be checkable or autoExclusive.

Button {
    id:             control
    text:           "Button"
    focusPolicy:    Qt.ClickFocus
    hoverEnabled:   !ScreenTools.isMobile
    implicitHeight: ScreenTools.defaultFontPixelHeight * 2.5

    property bool   setupComplete:  true
    property var    imageColor:     undefined
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"
    property bool   largeSize:      false
    property bool   showHighlight:  control.pressed | control.checked

    property size   sourceSize:     Qt.size(ScreenTools.defaultFontPixelHeight * 1.5, ScreenTools.defaultFontPixelHeight * 1.5)

    property ButtonGroup buttonGroup: null
    onButtonGroupChanged: {
        if (buttonGroup) {
            buttonGroup.addButton(control)
        }
    }

    onCheckedChanged: checkable = false

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  control.enabled
    }

    background: Rectangle {
        color:        qgcPal.windowShade
        border.width: 1
        border.color: showHighlight ? qgcPal.buttonHighlight : qgcPal.buttonBorder
        radius:       2

        Rectangle {
            anchors.fill:   parent
            color:          qgcPal.buttonHighlight
            opacity:        showHighlight ? 0.22 : control.enabled && control.hovered ? .1 : 0
            radius:         parent.radius
        }
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth * 0.75

        QGCColoredImage {
            id:                     image
            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 1.5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
            Layout.alignment:       Qt.AlignVCenter
            fillMode:               Image.PreserveAspectFit
            mipmap:                 true
            color:                  imageColor ? imageColor : (control.setupComplete ? titleBar.color : qgcPal.colorRed)
            source:                 control.imageResource
            sourceSize:             control.sourceSize
        }

        QGCLabel {
            id:                 titleBar
            Layout.fillWidth:   true
            Layout.alignment:   Qt.AlignVCenter
            color:              showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
            text:               control.text
            elide:              Text.ElideRight
            font.letterSpacing: 0.4
        }
    }
}
