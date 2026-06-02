import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap

ColumnLayout {
    spacing: ScreenTools.defaultFontPixelHeight / 2

    QGCPalette { id: qgcPal }

    Rectangle {
        Layout.fillWidth: true
        height: ScreenTools.defaultFontPixelHeight / 4
        radius: height / 2
        color: qgcPal.buttonBorder
        opacity: 0.45
    }

    TerrainProgress {
        Layout.fillWidth: true
    }

    // We use a Loader to load the photoVideoControlComponent only when we have an active vehicle and a camera manager.
    // This make it easier to implement PhotoVideoControl without having to check for the mavlink camera
    // to be null all over the place
    Loader {
        id:                 photoVideoControlLoader
        Layout.alignment:   Qt.AlignRight
        sourceComponent:    globals.activeVehicle && globals.activeVehicle.cameraManager ? photoVideoControlComponent : undefined

        property real rightEdgeCenterInset: visible ? parent.width - x : 0

        Component {
            id: photoVideoControlComponent

            PhotoVideoControl {
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: ScreenTools.defaultFontPixelHeight / 4
        radius: height / 2
        color: qgcPal.buttonBorder
        opacity: 0.35
    }
}
