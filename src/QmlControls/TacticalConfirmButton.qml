import QtQuick

import QGroundControl
import QGroundControl.Controls

Item {
    id: control

    // Properties
    property string text:           "CONFIRM"
    property string activeText:     "CONFIRMING..."
    property bool   isEmergency:    false
    property bool   useHoldMode:    true

    property real   minimumHitArea: ScreenTools.defaultFontPixelHeight * 2.5
    property real   trackPadding:   ScreenTools.defaultFontPixelHeight * 0.15

    implicitWidth:  Math.max(ScreenTools.defaultFontPixelWidth * 25, minimumHitArea * 3)
    implicitHeight: Math.max(minimumHitArea, ScreenTools.defaultFontPixelHeight * 3)
    
    signal confirmed()
    signal cancelled()

    QGCPalette { id: qgcPal }

    // Colors
    property color baseColor: isEmergency ? qgcPal.colorRed : qgcPal.colorOrange
    property color bgColor:   qgcPal.windowShade

    Rectangle {
        id:             container
        anchors.fill:   parent
        radius:         height / 2
        color:          control.bgColor
        border.color:   control.baseColor
        border.width:   1
        clip:           true

        Item {
            id: swipeContainer
            anchors.fill: parent
            visible: !control.useHoldMode

            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: swipeHandle.x + swipeHandle.width / 2
                radius: parent.radius
                color: control.baseColor
                opacity: 0.3
            }

            QGCLabel {
                anchors.centerIn:   parent
                text:               qsTr("SWIPE TO ") + control.text.toUpperCase()
                font.pointSize:     ScreenTools.mediumFontPointSize
                font.letterSpacing: 1.5
                font.weight:        Font.DemiBold
                color:              control.baseColor
                opacity:            Math.max(0.25, 1.0 - (swipeHandle.x / Math.max(1, swipeContainer.width - swipeHandle.width)))
            }

            Rectangle {
                id:                 swipeHandle
                width:              height
                height:             parent.height - control.trackPadding * 2
                radius:             height / 2
                anchors.verticalCenter: parent.verticalCenter
                x:                  control.trackPadding
                color:              control.baseColor

                QGCColoredImage {
                    anchors.centerIn: parent
                    width: parent.width * 0.5
                    height: parent.height * 0.5
                    source: "/res/ArrowRight.svg"
                    color: qgcPal.windowShade
                    fillMode: Image.PreserveAspectFit
                }

                DragHandler {
                    id:             dragHandler
                    yAxis.enabled:  false
                    xAxis.enabled:  true
                    xAxis.minimum:  control.trackPadding
                    xAxis.maximum:  swipeContainer.width - swipeHandle.width - control.trackPadding

                    onActiveChanged: {
                        if (!active) {
                            if (swipeHandle.x >= xAxis.maximum) {
                                control.confirmed()
                                swipeHandle.x = control.trackPadding
                            } else {
                                snapBackAnim.start()
                                control.cancelled()
                            }
                        }
                    }
                }

                NumberAnimation on x {
                    id: snapBackAnim
                    to: control.trackPadding
                    duration: 200
                    easing.type: Easing.OutQuad
                    running: false
                }
            }
        }

        Item {
            id: holdContainer
            anchors.fill: parent
            visible: control.useHoldMode

            Rectangle {
                id: holdFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (holdTimer.progress)
                radius: parent.radius
                color: control.baseColor
                opacity: 0.3
            }
            
            QGCLabel {
                anchors.centerIn:   parent
                text:               holdMouseArea.pressed ? control.activeText.toUpperCase() : qsTr("HOLD TO ") + control.text.toUpperCase()
                font.pointSize:     ScreenTools.mediumFontPointSize
                font.letterSpacing: 1.5
                font.weight:        Font.DemiBold
                color:              control.baseColor
            }
            
            MouseArea {
                id: holdMouseArea
                anchors.fill: parent
                
                onPressed: holdTimer.start()
                onReleased: {
                    if (holdTimer.running) {
                        holdTimer.stop()
                        control.cancelled()
                    }
                }
                onCanceled: {
                    holdTimer.stop()
                    control.cancelled()
                }
            }
            
            Timer {
                id: holdTimer
                interval: 2000
                repeat: false

                property real progress: 0.0
                
                onRunningChanged: {
                    if (!running && !holdMouseArea.pressed) {
                        progress = 0.0 // Reset if interrupted
                    }
                }
                
                onTriggered: {
                    control.confirmed()
                    progress = 0.0
                }
            }

            NumberAnimation {
                target: holdTimer
                property: "progress"
                from: 0.0
                to: 1.0
                duration: 2000
                running: holdTimer.running
                onStopped: {
                    if (!holdMouseArea.pressed) {
                        holdTimer.progress = 0.0
                    }
                }
            }
        }
    }
}
