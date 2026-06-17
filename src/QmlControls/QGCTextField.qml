import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical QGCTextField
/// Bottom-border only (no box), monospace data font, block cursor, validation error in red.
TextField {
    id: control

    color:              qgcPal.textFieldText
    selectionColor:     TacticalTheme.cyanAccent
    selectedTextColor:  TacticalTheme.textOnAccent
    activeFocusOnPress: true
    antialiasing:       true
    font.pointSize:     ScreenTools.defaultFontPointSize
    font.family:        ScreenTools.monoDataFontFamily    // Space Mono for data inputs
    inputMethodHints:   numericValuesOnly && !ScreenTools.isiOS ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
    leftPadding:        _pad
    rightPadding:       _pad + unitsHelpLayout.width
    topPadding:         _pad * 0.5
    bottomPadding:      _pad * 1.2
    EnterKey.type:      Qt.EnterKeyDone

    property bool   showUnits:         false
    property bool   showHelp:          false
    property string unitsLabel:        ""
    property string extraUnitsLabel:   ""
    property bool   numericValuesOnly: false
    property alias  textColor:         control.color
    property bool   validationError:   false

    property real _helpLayoutWidth:    0
    property real _pad:                ScreenTools.defaultFontPixelHeight * 0.32

    signal helpClicked()

    Component.onCompleted:  checkActiveFocus()
    onActiveFocusChanged:   checkActiveFocus()

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    onEditingFinished: {
        if (ScreenTools.isMobile) {
            focus = false
        }
    }

    function checkActiveFocus() {
        if (activeFocus) {
            selectAll()
            if (validationError) validationToolTip.visible = true
        } else {
            validationToolTip.visible = false
        }
    }

    function showValidationError(errorString, originalValidValue = undefined, preventViewSwitch = true) {
        validationToolTip.text = errorString
        validationToolTip.originalValidValue = originalValidValue
        validationToolTip.visible = true
        if (!validationError) {
            validationError = true
            if (preventViewSwitch) globals.validationErrorCount++
        }
    }

    function clearValidationError(preventViewSwitch = true) {
        validationToolTip.visible = false
        validationToolTip.originalValidValue = undefined
        if (validationError) {
            validationError = false
            if (preventViewSwitch) globals.validationErrorCount--
        }
    }

    background: Item {
        implicitWidth:  ScreenTools.implicitTextFieldWidth
        implicitHeight: ScreenTools.implicitTextFieldHeight

        // Transparent fill — completely hollow
        Rectangle {
            anchors.fill: parent
            color:        "transparent"
        }

        // Bottom border only — the defining feature of this component
        Rectangle {
            id:             bottomBorder
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height:         1
            color:          control.validationError
                                ? TacticalTheme.signalRed
                                : control.activeFocus
                                  ? TacticalTheme.primary
                                  : TacticalTheme.outlineSubtle
            opacity:        control.activeFocus ? 1.0 : 0.6

            Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }
        }

        // Active focus highlight glow
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height:         1
            color:          "transparent"
            border.width:   1
            border.color:   control.validationError ? TacticalTheme.signalRed : TacticalTheme.primary
            opacity:        control.activeFocus ? 0.6 : 0
            layer.enabled:  true
            layer.effect:   MultiEffect {
                shadowEnabled: true
                shadowColor: control.validationError ? TacticalTheme.glowRed : TacticalTheme.glowCyan
                shadowBlur: 1.0
            }
            Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
        }

        // Units / help row
        RowLayout {
            id:                     unitsHelpLayout
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.right:          parent.right
            anchors.rightMargin:    control.activeFocus ? 2 : control._pad
            spacing:                ScreenTools.defaultFontPixelWidth / 4
            layoutDirection:        Qt.RightToLeft

            Component.onCompleted:  control._helpLayoutWidth = unitsHelpLayout.width
            onWidthChanged:         control._helpLayoutWidth = unitsHelpLayout.width

            Rectangle {
                id:                     helpButton
                Layout.margins:         2
                Layout.leftMargin:      0
                Layout.rightMargin:     1
                Layout.fillHeight:      true
                Layout.preferredWidth:  helpLabel.contentWidth * 3
                Layout.alignment:       Qt.AlignVCenter
                color:                  control.color
                visible:                control.showHelp && control.activeFocus

                QGCLabel {
                    id:              helpLabel
                    anchors.centerIn: parent
                    color:           qgcPal.textField
                    text:            "?"
                    font.family:     ScreenTools.tacticalFontFamily
                    font.pointSize:  ScreenTools.smallFontPointSize * 0.8
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text:             control.extraUnitsLabel
                font.pointSize:   ScreenTools.smallFontPointSize
                font.family:      ScreenTools.monoDataFontFamily
                antialiasing:     true
                color:            TacticalTheme.textSecondary
                visible:          control.showUnits && text !== ""
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text:             control.unitsLabel
                font.pointSize:   control.activeFocus ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize
                font.family:      ScreenTools.monoDataFontFamily
                antialiasing:     true
                color:            TacticalTheme.textSecondary
                visible:          control.showUnits && text !== ""
            }
        }
    }

    ToolTip {
        id: validationToolTip
        property var originalValidValue: undefined

        QGCMouseArea {
            anchors.fill: parent
            onClicked: {
                if (validationToolTip.originalValidValue !== undefined) {
                    control.text = validationToolTip.originalValidValue
                    control.clearValidationError()
                }
            }
        }
    }

    MouseArea {
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        width:          control._helpLayoutWidth
        enabled:        helpButton.visible
        onClicked:      control.helpClicked()
    }
}
