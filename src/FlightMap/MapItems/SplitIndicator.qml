import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

Rectangle {
    id:             _root
    width:          ScreenTools.defaultFontPixelHeight * 1.5
    height:         width
    radius:         width / 2
    border.color:   indicatorColor
    color:          "transparent"
    opacity:        0.85

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: indicatorColor
        opacity: 0.35
    }

    property color indicatorColor: "white"

    signal clicked

    Rectangle {
        anchors.margins:            _root.height / 6
        anchors.top:                parent.top
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      1
        color:                      indicatorColor
        opacity:                    0.85
    }

    Rectangle {
        anchors.margins:            _root.height / 6
        anchors.left:               parent.left
        anchors.right:              parent.right
        anchors.verticalCenter:     parent.verticalCenter
        height:                     1
        color:                      indicatorColor
        opacity:                    0.85
    }

    QGCMouseArea {
        fillItem:   parent
        onClicked:  _root.clicked()
    }
}
