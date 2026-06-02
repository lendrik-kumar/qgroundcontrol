import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.PlanView

Rectangle {
    id: _root
    width: parent.width
    height: ScreenTools.toolbarHeight
    color: qgcPal.toolbarBackground

    property var planMasterController
    property bool showRallyPointsHelp: false

    signal toolbarButtonClicked()

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real _controllerProgressPct: planMasterController.missionController.progressPct

    QGCPalette { id: qgcPal }
    property real _segmentPadding: ScreenTools.defaultFontPixelWidth * 0.6
    property real _segmentRadius: ScreenTools.defaultBorderRadius

    Rectangle {
        anchors.fill: parent
        color: qgcPal.windowShade
        border.width: 1
        border.color: qgcPal.buttonBorder
        radius: ScreenTools.defaultBorderRadius
        opacity: 0.95
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: qgcPal.buttonBorder
        opacity: 0.6
    }

    RowLayout {
        id: toolbarLayout
        anchors.fill: parent
        anchors.margins: _segmentPadding
        spacing: _segmentPadding

        Rectangle {
            id: leftSegment
            Layout.fillHeight: true
            Layout.preferredWidth: qgcButton.width + (ScreenTools.defaultFontPixelWidth * 2)
            radius: _segmentRadius
            color: qgcPal.windowShade
            border.width: 1
            border.color: qgcPal.buttonBorder
            opacity: 0.95

            QGCToolBarButton {
                id: qgcButton
                objectName: "toolbar_qgcLogo"
                height: parent.height
                icon.source: "/res/darshak_logo.png"
                logo: true
                anchors.centerIn: parent
                onClicked: mainWindow.showToolSelectDialog()
            }
        }

        Rectangle {
            id: actionsSegment
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: _segmentRadius
            color: qgcPal.windowShade
            border.width: 1
            border.color: qgcPal.buttonBorder
            opacity: 0.95

            QGCFlickable {
                id: toolsFlickable
                anchors.fill: parent
                anchors.margins: _segmentPadding
                contentWidth: toolIndicators.width
                flickableDirection: Flickable.HorizontalFlick

                PlanToolBarIndicators {
                    id: toolIndicators
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    planMasterController: _root.planMasterController
                    showRallyPointsHelp: _root.showRallyPointsHelp
                    onToolbarButtonClicked: _root.toolbarButtonClicked()
                }
            }
        }
    }

    // Small mission download progress bar
    Rectangle {
        id: progressBar
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: 4
        width: _controllerProgressPct * parent.width
        color: qgcPal.colorGreen
        visible: false
        z: 2

        onVisibleChanged: {
            if (visible) {
                largeProgressBar._userHide = false
            }
        }
    }

    // Large mission download progress bar
    Rectangle {
        id: largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        color: qgcPal.window
        visible: _showLargeProgress
        z: 3

        property bool _userHide: false
        property bool _showLargeProgress: progressBar.visible && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target: QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: _controllerProgressPct * parent.width
            color: qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn: parent
            text: qsTr("Syncing Mission")
            font.pointSize: ScreenTools.largeFontPointSize
            visible: _controllerProgressPct !== 1
        }

        QGCLabel {
            anchors.centerIn: parent
            text: qsTr("Done")
            font.pointSize: ScreenTools.largeFontPointSize
            visible: _controllerProgressPct === 1
        }

        QGCLabel {
            anchors.margins: _margin
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: largeProgressBar._userHide = true
        }
    }

    // Progress bar
    Connections {
        target: planMasterController.missionController

        function onProgressPctChanged(progressPct) {
            if (progressPct === 1) {
                if (_root.visible) {
                    resetProgressTimer.start()
                } else {
                    progressBar.visible = false
                }
            } else if (progressPct > 0) {
                progressBar.visible = true
            }
        }
    }

    Timer {
        id: resetProgressTimer
        interval: 3000
        onTriggered: progressBar.visible = false
    }
}
