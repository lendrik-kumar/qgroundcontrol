import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Horizontal Step-Progress Timeline Banner for Wizard Flows
Item {
    id: _root
    width: parent.width
    height: ScreenTools.defaultFontPixelHeight * 4

    property int totalSteps: 3
    property int currentStep: 1 // 1-indexed
    property var stepLabels: [] // e.g. ["Orientation", "Compass", "Accel"]

    readonly property color _colorActive: TacticalTheme.cyanAccent
    readonly property color _colorPending: TacticalTheme.surfaceContainerHighest
    readonly property color _colorBorder: TacticalTheme.outlineSubtle

    RowLayout {
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: _root.totalSteps

            Item {
                width: ScreenTools.defaultFontPixelWidth * 12
                height: parent.height
                
                property bool isCompleted: index + 1 < _root.currentStep
                property bool isActive: index + 1 === _root.currentStep

                // Connecting Line (don't draw for the first element's left side)
                Rectangle {
                    visible: index > 0
                    anchors.right: nodeRect.left
                    anchors.verticalCenter: nodeRect.verticalCenter
                    width: parent.width / 2
                    height: 2
                    color: isCompleted || isActive ? _root._colorActive : _root._colorBorder
                }

                // Connecting Line (right side, don't draw for last element)
                Rectangle {
                    visible: index < _root.totalSteps - 1
                    anchors.left: nodeRect.right
                    anchors.verticalCenter: nodeRect.verticalCenter
                    width: parent.width / 2
                    height: 2
                    color: isCompleted ? _root._colorActive : _root._colorBorder
                }

                // Step Node
                Rectangle {
                    id: nodeRect
                    anchors.centerIn: parent
                    width: ScreenTools.defaultFontPixelHeight * 1.5
                    height: width
                    radius: 0
                    color: isActive || isCompleted ? _root._colorActive : _root._colorPending
                    border.color: isActive || isCompleted ? _root._colorActive : _root._colorBorder
                    border.width: 2

                    // Pulse animation for active step
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: isActive
                        NumberAnimation { to: 0.6; duration: 800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                    }

                    // Checkmark for completed
                    QGCColoredImage {
                        visible: isCompleted
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: width
                        source: "/qmlimages/check.svg"
                        color: "#0B0F19"
                    }
                    
                    // Number for active/pending
                    QGCLabel {
                        visible: !isCompleted
                        anchors.centerIn: parent
                        text: (index + 1).toString()
                        color: isActive ? TacticalTheme.surfaceBase : _root._colorBorder
                        font.family: ScreenTools.monoDataFontFamily
                        font.pointSize: ScreenTools.smallFontPointSize
                        font.bold: true
                    }
                }

                // Step Label
                QGCLabel {
                    anchors.top: nodeRect.bottom
                    anchors.topMargin: ScreenTools.defaultFontPixelHeight * 0.3
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: _root.stepLabels.length > index ? _root.stepLabels[index] : ""
                    font.family: ScreenTools.tacticalFontFamily
                    font.letterSpacing: 0.5
                    font.pointSize: ScreenTools.smallFontPointSize * 0.9
                    color: isActive ? _root._colorActive : (isCompleted ? TacticalTheme.textPrimary : _root._colorBorder)
                }
            }
        }
    }
    QGCPalette { id: _qgcPal }
}
