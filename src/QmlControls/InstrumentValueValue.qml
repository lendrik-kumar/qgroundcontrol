import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

ColumnLayout {
    property var    instrumentValueData:            null
    property bool   settingsUnlocked:               false
    property alias  contentWidth:                   label.contentWidth

    property var    _rgFontSizes:                   [ ScreenTools.defaultFontPointSize, ScreenTools.smallFontPointSize, ScreenTools.mediumFontPointSize, ScreenTools.largeFontPointSize ]
    property var    _rgFontSizeRatios:              [ 1, ScreenTools.smallFontPointRatio, ScreenTools.mediumFontPointRatio, ScreenTools.largeFontPointRatio ]
    property real   _doubleDescent:                 ScreenTools.defaultFontDescent * 2
    property real   _tightDefaultFontHeight:        ScreenTools.defaultFontPixelHeight - _doubleDescent
    property var    _rgFontSizeTightHeights:        [ _tightDefaultFontHeight * _rgFontSizeRatios[0] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[1] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[2] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[3] + 2 ]
    property real   _tightHeight:                   _rgFontSizeTightHeights[instrumentValueData.factValueGrid.fontSize]
    property real   _fontSize:                      _rgFontSizes[instrumentValueData.factValueGrid.fontSize]
    property real   _horizontalLabelSpacing:        ScreenTools.defaultFontPixelWidth
    property real   _width:                         0
    property real   _height:                        0

    // Smoothing interpolation for numeric values
    property bool _isNumericFact: instrumentValueData && instrumentValueData.fact && typeof instrumentValueData.fact.value === "number" && (!instrumentValueData.fact.enumStrings || instrumentValueData.fact.enumStrings.length === 0)
    property real _targetValue: _isNumericFact ? instrumentValueData.fact.value : 0
    property real _smoothedValue: _targetValue

    on_TargetValueChanged: _smoothedValue = _targetValue

    QGCPalette { id: qgcPal }

    Behavior on _smoothedValue {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    QGCLabel {
        id:                 label
        Layout.alignment:   Qt.AlignVCenter
        font.pointSize:     _fontSize
        font.letterSpacing: 1.0
        font.weight:        Font.Medium
        color:              instrumentValueData.isValidColor(instrumentValueData.currentColor) ? instrumentValueData.currentColor : qgcPal.text
        text:               valueText()

        function valueText() {
            if (instrumentValueData.fact) {
                var valStr = ""
                if (_isNumericFact) {
                    // Try to use fact's decimalPlaces if available, otherwise fallback to 1
                    var decimals = instrumentValueData.fact.decimalPlaces !== undefined ? instrumentValueData.fact.decimalPlaces : 1;
                    valStr = Number(_smoothedValue).toFixed(decimals);
                } else {
                    valStr = instrumentValueData.fact.enumOrValueString;
                }
                return valStr + (instrumentValueData.showUnits ? " " + instrumentValueData.fact.units : "")
            } else {
                return qsTr("–")
            }
        }
    }
}
