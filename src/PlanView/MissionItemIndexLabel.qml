import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

Canvas {
    id:     root

    width:  _width
    height: _height

    signal clicked(point position)

    property string label                           ///< Label to show to the side of the index indicator
    property int    index:                  0       ///< Index to show in the indicator, 0 will show single char label instead, -1 first char of label in indicator full label to the side
    property bool   checked:                false
    property bool   small:                  !checked
    property bool   child:                  false
    property bool   highlightSelected:      false
    property var    color:                  checked ? TacticalTheme.primary : (child ? TacticalTheme.surfaceContainerHigh : TacticalTheme.surfaceContainerHighest)
    property real   anchorPointX:           _height / 2
    property real   anchorPointY:           _height / 2
    property bool   specifiesCoordinate:    true
    property real   gimbalYaw
    property real   vehicleYaw
    property bool   showGimbalYaw:          false
    property bool   showSequenceNumbers:    true

    property real   _width:             showGimbalYaw ? Math.max(_gimbalYawWidth, labelControl.visible ? labelControl.width : indicator.width) : (labelControl.visible ? labelControl.width : indicator.width)
    property real   _height:            showGimbalYaw ? _gimbalYawWidth : (labelControl.visible ? labelControl.height : indicator.height)
    property real   _gimbalYawRadius:   ScreenTools.defaultFontPixelHeight
    property real   _gimbalYawWidth:    _gimbalYawRadius * 2
    property real   _smallRadiusRaw:    Math.ceil((ScreenTools.defaultFontPixelHeight * ScreenTools.smallFontPointRatio) / 2)
    property real   _smallRadius:       _smallRadiusRaw + ((_smallRadiusRaw % 2 == 0) ? 1 : 0) // odd number for better centering
    property real   _normalRadiusRaw:   Math.ceil(ScreenTools.defaultFontPixelHeight * 0.66)
    property real   _normalRadius:      _normalRadiusRaw + ((_normalRadiusRaw % 2 == 0) ? 1 : 0)
    property real   _indicatorRadius:   small ? _smallRadius : _normalRadius
    property real   _gimbalRadians:     degreesToRadians(vehicleYaw + gimbalYaw - 90)
    property real   _labelMargin:       2
    property real   _labelRadius:       _indicatorRadius + _labelMargin
    property color  _labelTextColor:    qgcPal.text
    property string _label:             label.length > 1 ? label : ""
    property string _index:             index === 0 || index === -1 ? label.charAt(0) : (showSequenceNumbers ? index : "")

    onColorChanged:         requestPaint()
    onShowGimbalYawChanged: requestPaint()
    onGimbalYawChanged:     requestPaint()
    onVehicleYawChanged:    requestPaint()

    QGCPalette { id: qgcPal }

    function degreesToRadians(degrees) {
        return (Math.PI/180)*degrees
    }

    function paintGimbalYaw(context) {
        if (showGimbalYaw) {
            context.save()
            context.globalAlpha = 0.75
            context.beginPath()
            context.moveTo(anchorPointX, anchorPointY)
            context.arc(anchorPointX, anchorPointY, _gimbalYawRadius,  _gimbalRadians + degreesToRadians(45), _gimbalRadians + degreesToRadians(-45), true /* clockwise */)
            context.closePath()
            context.fillStyle = "white"
            context.fill()
            context.restore()
        }
    }

    onPaint: {
        var context = getContext("2d")
        context.clearRect(0, 0, width, height)
        paintGimbalYaw(context)
    }

    Rectangle {
        id:                     labelControl
        anchors.leftMargin:     -((_labelMargin * 2) + indicator.width)
        anchors.rightMargin:    -(_labelMargin * 2)
        anchors.fill:           labelControlLabel
        color:                  TacticalTheme.surfaceContainer
        opacity:                0.9
        radius:                 0
        visible:                _label.length !== 0 && !small
        border.width:           1
        border.color:           TacticalTheme.outlineSubtle

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: "transparent"
            border.width: 1
            border.color: TacticalTheme.primary
            opacity: checked ? 0.8 : 0.0
        }
    }

    QGCLabel {
        id:                     labelControlLabel
        anchors.topMargin:      -_labelMargin
        anchors.bottomMargin:   -_labelMargin
        anchors.leftMargin:     _labelMargin
        anchors.left:           indicator.right
        anchors.top:            indicator.top
        anchors.bottom:         indicator.bottom
        color:                  _labelTextColor
        text:                   _label
        verticalAlignment:      Text.AlignVCenter
        visible:                labelControl.visible
    }

    Item {
        id:                             indicator
        anchors.horizontalCenter:       parent.left
        anchors.verticalCenter:         parent.top
        anchors.horizontalCenterOffset: anchorPointX
        anchors.verticalCenterOffset:   anchorPointY
        width:                          _indicatorRadius * 2
        height:                         width

        // Rotated Diamond Background
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height * 0.9
            rotation: 45
            color: "transparent"
            border.width: 1
            border.color: root.color

            Rectangle {
                anchors.fill: parent
                color: root.color
                opacity: checked ? 0.7 : 0.25
            }
        }

        QGCLabel {
            anchors.fill:           parent
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  TacticalTheme.textPrimary
            font.family:            ScreenTools.monoDataFontFamily
            font.pointSize:         ScreenTools.defaultFontPointSize
            font.weight:            Font.Bold
            fontSizeMode:           Text.Fit
            text:                   _index
        }
    }

    // Pulsing diamond bracket to indicate selection
    Rectangle {
        width:          indicator.width * 1.5
        height:         width
        rotation:       45
        color:          "transparent"
        border.color:   root.color
        border.width:   2
        visible:        checked && highlightSelected
        anchors.centerIn: indicator

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: checked && highlightSelected
            NumberAnimation { to: 0.2; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
    }

    // The mouse click area is always the size of a normal indicator
    Item {
        id:                 mouseAreaFill
        anchors.margins:    small ? -(_normalRadius - _smallRadius) : 0
        anchors.fill:       indicator
    }

    QGCMouseArea {
        fillItem:   mouseAreaFill
        onClicked: (mouse) => {
            focus = true
            parent.clicked(Qt.point(mouse.x, mouse.y))
        }
    }
}
