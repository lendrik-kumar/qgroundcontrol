import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls

Item {
    id:         _root

    property Fact   _editorDialogFact: Fact { }
    property int    _rowHeight:         ScreenTools.defaultFontPixelHeight * 2
    property int    _rowWidth:          10 // Dynamic adjusted at runtime
    property bool   _searchFilter:      searchText.text.trim() != "" || controller.showModifiedOnly || controller.showFavoritesOnly  ///< true: showing results of search
    property var    _searchResults      ///< List of parameter names from search results
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _showRCToParam:     _activeVehicle.px4Firmware
    property var    _appSettings:       QGroundControl.settingsManager.appSettings
    property var    _controller:        controller
    property var    _favorites:         controller.favoriteParameterNames
    property real   _margins:           ScreenTools.defaultFontPixelHeight / 2

    ParameterEditorController {
        id: controller
    }

    Timer {
        id:         clearTimer
        interval:   100;
        running:    false;
        repeat:     false
        onTriggered: {
            searchText.text = ""
            controller.searchText = ""
        }
    }

    QGCMenu {
        id:                 toolsMenu
        QGCMenuItem {
            text:           qsTr("Refresh")
            onTriggered:	controller.refresh()
        }
        QGCMenuItem {
            text:           qsTr("Reset all to firmware's defaults")
            onTriggered:    QGroundControl.showMessageDialog(_root, qsTr("Reset All"),
                                                         qsTr("Select Reset to reset all parameters to their defaults.\n\nNote that this will also completely reset everything, including UAVCAN nodes, all vehicle settings, setup and calibrations."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToDefaults() })
        }
        QGCMenuItem {
            text:           qsTr("Reset to vehicle's configuration defaults")
            visible:        !_activeVehicle.apmFirmware
            onTriggered:    QGroundControl.showMessageDialog(_root, qsTr("Reset All"),
                                                         qsTr("Select Reset to reset all parameters to the vehicle's configuration defaults."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToVehicleConfiguration() })
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Load from file for review...")
            onTriggered: {
                fileDialog.title =          qsTr("Load Parameters")
                fileDialog.openForLoad()
            }
        }
        QGCMenuItem {
            text:           qsTr("Save to file...")
            onTriggered: {
                fileDialog.title =          qsTr("Save Parameters")
                fileDialog.openForSave()
            }
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Clear all favorites")
            onTriggered:    controller.clearAllFavorites()
        }
        QGCMenuSeparator { visible: _showRCToParam }
        QGCMenuItem {
            text:           qsTr("Clear all RC to Param")
            onTriggered:	_activeVehicle.clearAllParamMapRC()
            visible:        _showRCToParam
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Reboot Vehicle")
            onTriggered:    QGroundControl.showMessageDialog(_root, qsTr("Reboot Vehicle"),
                                                         qsTr("Select Ok to reboot vehicle."),
                                                         Dialog.Cancel | Dialog.Ok,
                                                         function() { _activeVehicle.rebootVehicle() })
        }
    }


    QGCFileDialog {
        id:             fileDialog
        folder:         _appSettings.parameterSavePath
        nameFilters:    [ qsTr("Parameter Files (*.%1)").arg(_appSettings.parameterFileExtension) , qsTr("All Files (*)") ]

        onAcceptedForSave: (file) => {
            controller.saveToFile(file)
            close()
        }

        onAcceptedForLoad: (file) => {
            close()
            if (controller.buildDiffFromFile(file)) {
                parameterDiffDialogFactory.open()
            }
        }
    }

    QGCPopupDialogFactory {
        id: editorDialogFactory

        dialogComponent: editorDialogComponent
    }

    Component {
        id: editorDialogComponent

        ParameterEditorDialog {
            fact:           _editorDialogFact
            showRCToParam:  _showRCToParam
        }
    }

    QGCPopupDialogFactory {
        id: parameterDiffDialogFactory

        dialogComponent: parameterDiffDialog
    }

    Component {
        id: parameterDiffDialog

        ParameterDiffDialog {
            paramController: _controller
        }
    }

    // Tactical color tokens — now sourced from TacticalTheme singleton
    readonly property color _accentCyan:    TacticalTheme.cyanAccent
    readonly property color _warnAmber:     TacticalTheme.amber
    readonly property color _critCrimson:   TacticalTheme.signalRed

    RowLayout {
        id:             header
        anchors.left:   parent.left
        anchors.right:  parent.right

        RowLayout {
            Layout.alignment:   Qt.AlignLeft
            spacing:            ScreenTools.defaultFontPixelWidth

            // Search field with active cyan underline accent
            Item {
                implicitWidth:  searchText.implicitWidth + ScreenTools.defaultFontPixelWidth * 2
                implicitHeight: searchText.implicitHeight

                QGCTextField {
                    id:                     searchText
                    anchors.fill:           parent
                    placeholderText:        qsTr("Search parameters…")
                    onDisplayTextChanged:   controller.searchText = displayText
                }

                // Cyan bottom accent — activates on focus
                Rectangle {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    anchors.bottom: parent.bottom
                    height:         ScreenTools.defaultFontPixelHeight * 0.1
                    color:          _accentCyan
                    opacity:        searchText.activeFocus ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }

            QGCButton {
                text: qsTr("Clear")
                onClicked: {
                    if(ScreenTools.isMobile) {
                        Qt.inputMethod.hide();
                    }
                    clearTimer.start()
                }
            }

            QGCCheckBox {
                text:       qsTr("Hide read-only")
                checked:    controller.hideReadOnly
                onClicked:  controller.hideReadOnly = checked
            }
        }

        QGCButton {
            Layout.alignment:   Qt.AlignRight
            text:               qsTr("Tools")
            onClicked:          toolsMenu.popup()
        }
    }

    QGCTabBar {
        id:             tabBar
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.top:        header.bottom
        anchors.topMargin:  _margins

        QGCTabButton { text: qsTr("Full List") }
        QGCTabButton { text: qsTr("Modified") }
        QGCTabButton { text: qsTr("Favorites") }

        onCurrentIndexChanged: {
            controller.showModifiedOnly  = (currentIndex === 1)
            controller.showFavoritesOnly = (currentIndex === 2)
        }
    }

    /// Group buttons
    QGCFlickable {
        id :                groupScroll
        width:              ScreenTools.defaultFontPixelWidth * 25
        anchors.top:        tabBar.bottom
        anchors.topMargin:  _margins
        anchors.bottom:     parent.bottom
        clip:               true
        pixelAligned:       true
        contentHeight:      groupedViewCategoryColumn.height
        flickableDirection: Flickable.VerticalFlick
        visible:            !_searchFilter

        ColumnLayout {
            id:             groupedViewCategoryColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)

            Repeater {
                model: controller.categories

                Column {
                    Layout.fillWidth:   true
                    spacing:            Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)

                    SectionHeader {
                        id:             categoryHeader
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           object.name
                        checked:        object == controller.currentCategory

                        onCheckedChanged: {
                            if (checked) {
                                controller.currentCategory = object
                            }
                        }
                    }

                    Repeater {
                        model: categoryHeader.checked ? object.groups : 0

                        // Tactical group button with cyan left-border when selected
                        Item {
                            width:  ScreenTools.defaultFontPixelWidth * 25
                            height: _rowHeight

                            // Cyber-cyan left border — visible when this group is active
                            Rectangle {
                                id:     groupAccentBar
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                anchors.bottom: parent.bottom
                                width:  ScreenTools.defaultFontPixelHeight * 0.18
                                color:  _root._accentCyan
                                opacity: object == controller.currentGroup ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            }

                            QGCButton {
                                anchors.left:   groupAccentBar.right
                                anchors.right:  parent.right
                                anchors.top:    parent.top
                                anchors.bottom: parent.bottom
                                text:           object.name
                                checked:        object == controller.currentGroup
                                autoExclusive:  true

                                onClicked: {
                                    if (!checked) _rowWidth = 10
                                    checked = true
                                    controller.currentGroup = object
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    HorizontalHeaderView {
        id:                 headerView
        anchors.left:       tableView.left
        anchors.right:      tableView.right
        anchors.top:        tabBar.bottom
        anchors.topMargin:  _margins
        syncView:           tableView
        clip:               true

        delegate: Rectangle {
            implicitWidth:  column === 0 ? ScreenTools.implicitCheckBoxHeight + ScreenTools.defaultFontPixelWidth
                                         : headerLabel.contentWidth + ScreenTools.defaultFontPixelWidth
            implicitHeight: headerLabel.contentHeight + ScreenTools.defaultFontPixelHeight * 0.5
            color:          TacticalTheme.surfaceContainerHigh

            QGCLabel {
                id:                     headerLabel
                anchors.left:           parent.left
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth / 2
                anchors.verticalCenter: parent.verticalCenter
                text:                   display
                font.family:            ScreenTools.tacticalFontFamily
                font.bold:              true
                font.letterSpacing:     0.6
                color:                  TacticalTheme.textSecondary
            }

            // Top border
            Rectangle {
                anchors.top:    parent.top
                width:          parent.width
                height:         1
                color:          qgcPal.groupBorder
            }

            // Left border
            Rectangle {
                anchors.left:   parent.left
                height:         parent.height
                width:          1
                color:          qgcPal.groupBorder
            }

            // Right border (last column only)
            Rectangle {
                anchors.right:  parent.right
                height:         parent.height
                width:          1
                color:          qgcPal.groupBorder
                visible:        column == 3
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                width:          parent.width
                height:         1
                color:          qgcPal.groupBorder
            }
        }
    }

    TableView {
        id:                 tableView
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        anchors.top:        headerView.bottom
        anchors.bottom:     parent.bottom
        anchors.left:       _searchFilter ? parent.left : groupScroll.right
        anchors.right:      parent.right
        columnSpacing:      0
        rowSpacing:         0
        model:              controller.parameters
        contentWidth:       width
        clip:               true

        // Qt is supposed to adjust column widths automatically when larger widths come into view.
        // But it doesn't work. So we have to do it force a layout manually when we scroll.
        Timer {
            id:             forceLayoutTimer
            interval:       500
            repeat:         false
            onTriggered:    tableView.forceLayout()
        }

        onTopRowChanged: forceLayoutTimer.start()
        onModelChanged: {
            positionViewAtRow(0, TableView.AlignLeft | TableView.AlignTop)
            forceLayoutTimer.start()
        }

        delegate: Rectangle {
            implicitWidth:  column === 0 ? ScreenTools.implicitCheckBoxHeight + ScreenTools.defaultFontPixelWidth
                                         : column === 1 ? nameRow.implicitWidth + ScreenTools.defaultFontPixelWidth
                                         : column === 2 ? ScreenTools.defaultFontPixelWidth * 16
                                                        : label.contentWidth + ScreenTools.defaultFontPixelWidth
            implicitHeight: label.contentHeight + ScreenTools.defaultFontPixelHeight * 0.5
            color:          row % 2 === 0 ? "transparent" : TacticalTheme.surfaceContainer
            clip:           true

            // Bottom grid line
            Rectangle {
                anchors.bottom: parent.bottom
                width:          parent.width
                height:         1
                color:          TacticalTheme.outlineSubtle
            }

            // Left grid line
            Rectangle {
                anchors.left:   parent.left
                height:         parent.height
                width:          1
                color:          qgcPal.groupBorder
            }

            // Right grid line (last column only)
            Rectangle {
                anchors.right:  parent.right
                height:         parent.height
                width:          1
                color:          qgcPal.groupBorder
                visible:        column == 3
            }

            QGCCheckBox {
                visible:                column === 0
                anchors.centerIn:       parent
                checked:                _root._favorites.indexOf(fact.name) >= 0
                z:                      1
                onClicked:              controller.toggleFavorite(fact.name)
            }

            Row {
                id:                     nameRow
                visible:                column === 1
                anchors.left:           parent.left
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth / 2
                anchors.verticalCenter: parent.verticalCenter
                spacing:               lockIcon.visible ? ScreenTools.defaultFontPixelWidth / 3 : 0

                QGCLabel {
                    text:               column === 1 ? display : ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                QGCColoredImage {
                    id:                 lockIcon
                    visible:            fact.readOnly
                    source:             "qrc:/InstrumentValueIcons/lock-closed.svg"
                    color:              qgcPal.text
                    width:              ScreenTools.defaultFontPixelHeight * 0.8
                    height:             width
                    sourceSize.width:   width
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            QGCLabel {
                id:                 label
                visible:            column !== 0 && column !== 1
                anchors.left:       parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                anchors.verticalCenter: parent.verticalCenter
                width:              column == 2 ? ScreenTools.defaultFontPixelWidth * 15 : implicitWidth
                text:               column == 2 ? col1String() : display
                color:              column == 2 && fact.defaultValueAvailable && !fact.valueEqualsDefault ? qgcPal.modifiedParamValue : qgcPal.text
                font.bold:          column == 2 && fact.defaultValueAvailable && !fact.valueEqualsDefault
                // Monospaced font for value column — prevents digit-jitter during live telemetry updates
                font.family:        column == 2 ? ScreenTools.monoDataFontFamily : ScreenTools.tacticalFontFamily
                maximumLineCount:   1
                elide:              column == 2 ? Text.ElideRight : Text.ElideNone

                function col1String() {
                    if (fact.enumStrings.length === 0) {
                        return fact.valueString + " " + fact.units
                    }
                    if (fact.bitmaskStrings.length != 0) {
                        return fact.selectedBitmaskStrings.join(',')
                    }
                    return fact.enumStringValue
                }
            }

            QGCMouseArea {
                anchors.fill: parent
                visible:      column !== 0
                onClicked: mouse => {
                    _editorDialogFact = fact
                    editorDialogFactory.open()
                }
            }
        }
    }

    // ─── Pending Changes FAB ───────────────────────────────────────────────────
    // Floats above the parameter table when any parameter deviates from default.
    // Forces a tactical review before the operator navigates away.
    property bool _hasPendingChanges: {
        // Walk the parameter model to detect any modified values
        if (!controller || !controller.parameters) return false
        var model = controller.parameters
        for (var r = 0; r < model.rowCount(); r++) {
            var idx = model.index(r, 0)
            var f = model.data(idx, Qt.UserRole)
            if (f && f.defaultValueAvailable && !f.valueEqualsDefault) return true
        }
        return false
    }

    Rectangle {
        id:                     pendingFAB
        anchors.right:          parent.right
        anchors.bottom:         parent.bottom
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth * 1.5
        anchors.bottomMargin:   ScreenTools.defaultFontPixelHeight * 1.5
        width:                  fabLabel.implicitWidth + ScreenTools.defaultFontPixelWidth * 3
        height:                 ScreenTools.defaultFontPixelHeight * 2.2
        radius:                 0       // tactical: sharp corners
        color:                  TacticalTheme.cyanAccent
        visible:                _root._hasPendingChanges
        z:                      10

        opacity: visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        transform: Translate {
            id: fabTranslate
            y: pendingFAB.visible ? 0 : ScreenTools.defaultFontPixelHeight * 2
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }

        QGCLabel {
            id:                 fabLabel
            anchors.centerIn:   parent
            text:               qsTr("⚠  Review Pending Changes")
            color:              "#0B0F19"
            font.bold:          true
            font.pointSize:     ScreenTools.defaultFontPointSize * 0.95
        }

        QGCMouseArea {
            fillItem: parent
            onClicked: {
                // Open the Modified tab to surface all pending changes
                tabBar.currentIndex = 1
            }
        }
    }
}
