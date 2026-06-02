#include "QGCPalette.h"
#include "QGCCorePlugin.h"

#include <QtCore/QDebug>

QList<QGCPalette*>   QGCPalette::_paletteObjects;

QGCPalette::Theme QGCPalette::_theme = QGCPalette::Dark;

QMap<int, QMap<int, QMap<QString, QColor>>> QGCPalette::_colorInfoMap;

QStringList QGCPalette::_colors;

QGCPalette::QGCPalette(QObject* parent) :
    QObject(parent),
    _colorGroupEnabled(true)
{
    if (_colorInfoMap.isEmpty()) {
        _buildMap();
    }

    // We have to keep track of all QGCPalette objects in the system so we can signal theme change to all of them
    _paletteObjects += this;
}

QGCPalette::~QGCPalette()
{
    bool fSuccess = _paletteObjects.removeOne(this);
    if (!fSuccess) {
        qWarning() << "Internal error";
    }
}

void QGCPalette::_buildMap()
{
    // ── Palette derived from user design: ────────────────────────────────────
    //   #0A2239  deep navy    (darkest background)
    //   #0B5E7C  ocean teal   (shade / panel bg)
    //   #4A7D8F  slate        (borders, muted elements)
    //   #6BBCD9  sky blue     (highlight, interactive)
    //   #E8F4F5  ice white    (primary text on dark)
    // ─────────────────────────────────────────────────────────────────────────
    //                                      Light                 Dark
    //                                      Disabled   Enabled    Disabled   Enabled
    DECLARE_QGC_COLOR(window,               "#ddedf2", "#e8f4f5", "#071828", "#0a2239")
    DECLARE_QGC_COLOR(windowTransparent,    "#ccE8F4F5", "#ccE8F4F5", "#cc0a2239", "#cc0a2239")
    DECLARE_QGC_COLOR(windowShadeLight,     "#c1dce6", "#b5d5e2", "#0c2d42", "#0d3350")
    DECLARE_QGC_COLOR(windowShade,          "#9ec9d8", "#8dc2d4", "#0b3a52", "#0b5e7c")
    DECLARE_QGC_COLOR(windowShadeDark,      "#76afc2", "#6aa5bb", "#084a64", "#09526d")
    DECLARE_QGC_COLOR(text,                 "#1a3a4a", "#0d2535", "#a8cdd9", "#e8f4f5")
    DECLARE_QGC_COLOR(warningText,          "#b82a30", "#b82a30", "#ff3c50", "#ff3c50")
    DECLARE_QGC_COLOR(button,               "#e0eff4", "#e8f4f5", "#0b3a52", "#0b5e7c")
    DECLARE_QGC_COLOR(buttonBorder,         "#4a7d8f", "#6bbcd9", "#4a7d8f", "#6bbcd9")
    DECLARE_QGC_COLOR(buttonText,           "#1a3a4a", "#0d2535", "#9ec0ce", "#e8f4f5")
    DECLARE_QGC_COLOR(buttonHighlight,      "#aad4e8", "#6bbcd9", "#0d3a52", "#6bbcd9")
    DECLARE_QGC_COLOR(buttonHighlightText,  "#071828", "#071828", "#071828", "#071828")
    DECLARE_QGC_COLOR(primaryButton,        "#3ea8ca", "#6bbcd9", "#0b5e7c", "#6bbcd9")
    DECLARE_QGC_COLOR(primaryButtonText,    "#071828", "#071828", "#071828", "#071828")
    DECLARE_QGC_COLOR(textField,            "#e8f4f5", "#e8f4f5", "#0c2333", "#0d2e42")
    DECLARE_QGC_COLOR(textFieldText,        "#0d2535", "#0d2535", "#c5dfe8", "#e8f4f5")
    DECLARE_QGC_COLOR(mapButton,            "#4a7d8f", "#3a6a7e", "#0b3a52", "#0b5e7c")
    DECLARE_QGC_COLOR(mapButtonHighlight,   "#6bbcd9", "#6bbcd9", "#6bbcd9", "#6bbcd9")
    DECLARE_QGC_COLOR(mapIndicator,         "#3ea8ca", "#6bbcd9", "#6bbcd9", "#6bbcd9")
    DECLARE_QGC_COLOR(mapIndicatorChild,    "#2e8aa8", "#4a9dbc", "#4a9dbc", "#4a9dbc")
    DECLARE_QGC_COLOR(colorGreen,           "#1aaa6a", "#1aaa6a", "#00e07a", "#00e07a")
    DECLARE_QGC_COLOR(colorYellow,          "#c2a020", "#c2a020", "#ffd020", "#ffd020")
    DECLARE_QGC_COLOR(colorYellowGreen,     "#7ab030", "#7ab030", "#aade30", "#aade30")
    DECLARE_QGC_COLOR(colorOrange,          "#d47830", "#d47830", "#ff8020", "#ff8020")
    DECLARE_QGC_COLOR(colorRed,             "#c03040", "#c03040", "#ff3050", "#ff3050")
    DECLARE_QGC_COLOR(colorGrey,            "#4a7d8f", "#4a7d8f", "#4a7d8f", "#4a7d8f")
    DECLARE_QGC_COLOR(colorBlue,            "#3ea8ca", "#6bbcd9", "#3ea8ca", "#6bbcd9")
    DECLARE_QGC_COLOR(alertBackground,      "#e0860a", "#f0920c", "#c07010", "#d97e12")
    DECLARE_QGC_COLOR(alertBorder,          "#b86a00", "#c87800", "#ff9a00", "#ffac00")
    DECLARE_QGC_COLOR(alertText,            "#071828", "#071828", "#e8f4f5", "#e8f4f5")
    DECLARE_QGC_COLOR(missionItemEditor,    "#d5ecf2", "#e0f2f8", "#0b3a52", "#0b5e7c")
    DECLARE_QGC_COLOR(toolStripHoverColor,  "#aad4e8", "#6bbcd9", "#0b3a52", "#0d4d68")
    DECLARE_QGC_COLOR(statusFailedText,     "#b82a30", "#b82a30", "#ff3c50", "#ff3c50")
    DECLARE_QGC_COLOR(statusPassedText,     "#1a8a5a", "#1a8a5a", "#00e07a", "#00e07a")
    DECLARE_QGC_COLOR(statusPendingText,    "#8a7020", "#8a7020", "#ffd020", "#ffd020")
    DECLARE_QGC_COLOR(toolbarBackground,    "#000d2535", "#000d2535", "#1a0a2239", "#1a0a2239")
    DECLARE_QGC_COLOR(groupBorder,          "#4a7d8f", "#6bbcd9", "#4a7d8f", "#6bbcd9")
    DECLARE_QGC_COLOR(modifiedParamValue,   "#d47830", "#d47830", "#ff8020", "#ff8020")

    // Colors not affecting by theming
    //                                                      Disabled     Enabled
    DECLARE_QGC_NONTHEMED_COLOR(brandingPurple,             "#0a2239", "#0b5e7c")
    DECLARE_QGC_NONTHEMED_COLOR(brandingBlue,               "#4a7d8f", "#6bbcd9")
    DECLARE_QGC_NONTHEMED_COLOR(toolStripFGColor,           "#a8cdd9", "#e8f4f5")
    DECLARE_QGC_NONTHEMED_COLOR(photoCaptureButtonColor,    "#c5dfe8", "#e8f4f5")
    DECLARE_QGC_NONTHEMED_COLOR(videoCaptureButtonColor,    "#e03248", "#ff3050")

    // Colors not affecting by theming or enable/disable
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderLight,          "#e8f4f5")
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderDark,           "#0a2239")
    DECLARE_QGC_SINGLE_COLOR(mapMissionTrajectory,          "#ff8020")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonInterior,         "#00e07a")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonTerrainCollision, "#ff3050")

}

void QGCPalette::setColorGroupEnabled(bool enabled)
{
    _colorGroupEnabled = enabled;
    emit paletteChanged();
}

void QGCPalette::setGlobalTheme(Theme newTheme)
{
    // Mobile build does not have themes
    if (_theme != newTheme) {
        _theme = newTheme;
        _signalPaletteChangeToAll();
    }
}

void QGCPalette::_signalPaletteChangeToAll()
{
    // Notify all objects of the new theme
    for (QGCPalette *palette : std::as_const(_paletteObjects)) {
        palette->_signalPaletteChanged();
    }
}

void QGCPalette::_signalPaletteChanged()
{
    emit paletteChanged();
}
