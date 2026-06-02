import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    required property var guidedValueSlider

    id:     control
    width:  parent.width
    height: ScreenTools.toolbarHeight

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.colorBlue
    property real   _leftRightMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property var    _guidedController:  globals.guidedControllerFlyView
    property real   _segmentPadding:    ScreenTools.defaultFontPixelWidth * 0.6
    property real   _segmentRadius:     ScreenTools.defaultBorderRadius

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    // Unified NEXUS COMMAND toolbar background — single dark glassmorphism slab
    Rectangle {
        anchors.fill:   parent
        color:          qgcPal.windowShade
        opacity:        0.88
        z:              -1
    }

    // Bottom scanline separator — sky-blue from palette
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         2
        color:          qgcPal.colorBlue
        opacity:        0.85
    }

    QGCFlickable {
        anchors.fill:       parent
        contentWidth:       toolBarLayout.width
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id:         toolBarLayout
            height:     parent.height
            spacing:    0

            Item {
                id:     leftPanel
                width:  leftPanelLayout.implicitWidth + (_segmentPadding * 2)
                height: parent.height

                // Transparent — unified toolbar bg handles visuals
                Item { anchors.fill: parent }

                RowLayout {
                    id:         leftPanelLayout
                    anchors.fill: parent
                    anchors.margins: _segmentPadding
                    spacing:    ScreenTools.defaultFontPixelWidth * 1.5

                    RowLayout {
                        id:         mainStatusLayout
                        height:     parent.height
                        spacing:    0

                        QGCToolBarButton {
                            id:                 qgcButton
                            objectName:         "toolbar_qgcLogo"
                            Layout.fillHeight:  true
                            icon.source:        "/res/darshak_logo.png"
                            logo:               true
                            onClicked:          mainWindow.showToolSelectDialog()
                        }

                        MainStatusIndicator {
                            id:                 mainStatusIndicator
                            Layout.fillHeight:  true
                        }
                    }

                    FlightModeIndicator {
                        Layout.fillHeight:  true
                        visible:            _activeVehicle
                    }
                }
            }
            Item {
                id:     centerPanel
                // center panel takes up all remaining space in toolbar between left and right panels
                width:  Math.max(guidedActionConfirm.visible ? guidedActionConfirm.width : 0, control.width - (leftPanel.width + rightPanel.width))
                height: parent.height

                // Guided action highlight only when active
                Rectangle {
                    anchors.fill:    parent
                    anchors.margins: _segmentPadding
                    color:           "transparent"
                    border.width:    guidedActionConfirm.visible ? 1 : 0
                    border.color:    qgcPal.buttonHighlight
                    opacity:         guidedActionConfirm.visible ? 0.9 : 0
                }

                GuidedActionConfirm {
                    id:                         guidedActionConfirm
                    height:                     parent.height
                    anchors.horizontalCenter:   parent.horizontalCenter
                    guidedController:           control._guidedController
                    guidedValueSlider:          control.guidedValueSlider
                    messageDisplay:             guidedActionMessageDisplay
                }
            }

            Item {
                id:     rightPanel
                width:  flyViewIndicators.width + (_segmentPadding * 2)
                height: parent.height

                // Transparent — unified toolbar bg handles visuals
                Item { anchors.fill: parent }

                FlyViewToolBarIndicators {
                    id:     flyViewIndicators
                    height: parent.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: _segmentPadding
                }
            }
        }
    }

    // The guided action message display is outside of the GuidedActionConfirm control so that it doesn't end up as
    // part of the Flickable
        Rectangle {
            id:                         guidedActionMessageDisplay
        anchors.top:                control.bottom
        anchors.topMargin:          _margins
        x:                          control.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x + (guidedActionConfirm.width - guidedActionMessageDisplay.width) / 2
        width:                      messageLabel.contentWidth + (_margins * 2)
        height:                     messageLabel.contentHeight + (_margins * 2)
            color:                      qgcPal.windowShade
            radius:                     ScreenTools.defaultBorderRadius
            visible:                    guidedActionConfirm.visible

            border.width: 1
            border.color: qgcPal.buttonBorder

        QGCLabel {
            id:         messageLabel
            x:          _margins
            y:          _margins
            width:      ScreenTools.defaultFontPixelWidth * 30
            wrapMode:   Text.WordWrap
            text:       guidedActionConfirm.message
        }

        PropertyAnimation {
            id:         messageOpacityAnimation
            target:     guidedActionMessageDisplay
            property:   "opacity"
            from:       1
            to:         0
            duration:   500
        }

        Timer {
            id:             messageFadeTimer
            interval:       4000
            onTriggered:    messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }

    QGCButton {
        id:         disconnectButton
        text:       qsTr("Disconnect")
        anchors.right: rightPanel.left
        anchors.rightMargin: _leftRightMargin
        anchors.verticalCenter: parent.verticalCenter
        visible:    _activeVehicle && _communicationLost
        onClicked:  _activeVehicle.closeVehicle()
    }
}
