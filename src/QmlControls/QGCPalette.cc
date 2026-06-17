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
    // ── Aero-Tactical Deep Space Palette ─────────────────────────────────────
    //   #0F1419  Void Black   (Background)
    //   #1B222A  Deep Slate   (Surface)
    //   #2C3640  Gunmetal     (Border/Active)
    //   #00DBE7  Neon Cyan    (Primary Accent)
    //   #FFB700  Amber        (Warning)
    //   #C2031A  Signal Red   (Critical)
    // ─────────────────────────────────────────────────────────────────────────
    //                                      Light                 Dark
    //                                      Disabled   Enabled    Disabled   Enabled
    DECLARE_QGC_COLOR(window,               "#e8e8e8", "#f0f0f0", "#090d11", "#0f1419")
    DECLARE_QGC_COLOR(windowTransparent,    "#ccf0f0f0", "#ccf0f0f0", "#cc0f1419", "#cc0f1419")
    DECLARE_QGC_COLOR(windowShadeLight,     "#dcdcdc", "#cccccc", "#161d25", "#1b222a")
    DECLARE_QGC_COLOR(windowShade,          "#cccccc", "#bbbbbb", "#1b222a", "#2c3640")
    DECLARE_QGC_COLOR(windowShadeDark,      "#bbbbbb", "#aaaaaa", "#202831", "#333e4a")
    DECLARE_QGC_COLOR(text,                 "#202020", "#000000", "#a0aab5", "#e0e8f0")
    DECLARE_QGC_COLOR(warningText,          "#997000", "#b38000", "#ffb700", "#ffb700")
    DECLARE_QGC_COLOR(button,               "#e0e0e0", "#d0d0d0", "#1b222a", "#2c3640")
    DECLARE_QGC_COLOR(buttonBorder,         "#808080", "#606060", "#3a4a5a", "#00dbe7")
    DECLARE_QGC_COLOR(buttonText,           "#202020", "#000000", "#d0d8e0", "#ffffff")
    DECLARE_QGC_COLOR(buttonHighlight,      "#a0eef5", "#00dbe7", "#2c3640", "#00dbe7")
    DECLARE_QGC_COLOR(buttonHighlightText,  "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(primaryButton,        "#00b5bf", "#00dbe7", "#00b5bf", "#00dbe7")
    DECLARE_QGC_COLOR(primaryButtonText,    "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(textField,            "#ffffff", "#ffffff", "#161d25", "#1b222a")
    DECLARE_QGC_COLOR(textFieldText,        "#000000", "#000000", "#e0e8f0", "#ffffff")
    DECLARE_QGC_COLOR(mapButton,            "#2c3640", "#1b222a", "#1b222a", "#2c3640")
    DECLARE_QGC_COLOR(mapButtonHighlight,   "#00dbe7", "#00dbe7", "#00dbe7", "#00dbe7")
    DECLARE_QGC_COLOR(mapIndicator,         "#00dbe7", "#00dbe7", "#00dbe7", "#00dbe7")
    DECLARE_QGC_COLOR(mapIndicatorChild,    "#00b5bf", "#00dbe7", "#00dbe7", "#00dbe7")
    DECLARE_QGC_COLOR(colorGreen,           "#00a040", "#00a040", "#00e7a0", "#00e7a0")
    DECLARE_QGC_COLOR(colorYellow,          "#b38000", "#b38000", "#ffb700", "#ffb700")
    DECLARE_QGC_COLOR(colorYellowGreen,     "#60a000", "#60a000", "#a0e700", "#a0e700")
    DECLARE_QGC_COLOR(colorOrange,          "#d06000", "#d06000", "#ff9000", "#ff9000")
    DECLARE_QGC_COLOR(colorRed,             "#a00010", "#a00010", "#c2031a", "#c2031a")
    DECLARE_QGC_COLOR(colorGrey,            "#606060", "#606060", "#606060", "#606060")
    DECLARE_QGC_COLOR(colorBlue,            "#0080c0", "#00b5bf", "#0080c0", "#00dbe7")
    DECLARE_QGC_COLOR(alertBackground,      "#ffb700", "#ffb700", "#b38000", "#ffb700")
    DECLARE_QGC_COLOR(alertBorder,          "#806000", "#806000", "#ffd700", "#ffd700")
    DECLARE_QGC_COLOR(alertText,            "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(missionItemEditor,    "#d0d8e0", "#e0e8f0", "#161d25", "#1b222a")
    DECLARE_QGC_COLOR(toolStripHoverColor,  "#a0eef5", "#00dbe7", "#1b222a", "#333e4a")
    DECLARE_QGC_COLOR(statusFailedText,     "#a00010", "#a00010", "#c2031a", "#c2031a")
    DECLARE_QGC_COLOR(statusPassedText,     "#00a040", "#00a040", "#00e7a0", "#00e7a0")
    DECLARE_QGC_COLOR(statusPendingText,    "#b38000", "#b38000", "#ffb700", "#ffb700")
    DECLARE_QGC_COLOR(toolbarBackground,    "#00ffffff", "#00ffffff", "#e60f1419", "#e60f1419")
    DECLARE_QGC_COLOR(groupBorder,          "#606060", "#3a4a5a", "#3a4a5a", "#606060")
    DECLARE_QGC_COLOR(modifiedParamValue,   "#d06000", "#d06000", "#ff9000", "#ff9000")

    // Colors not affecting by theming
    //                                                      Disabled     Enabled
    DECLARE_QGC_NONTHEMED_COLOR(brandingPurple,             "#0f1419", "#2c3640")
    DECLARE_QGC_NONTHEMED_COLOR(brandingBlue,               "#3a4a5a", "#00dbe7")
    DECLARE_QGC_NONTHEMED_COLOR(toolStripFGColor,           "#a0aab5", "#ffffff")
    DECLARE_QGC_NONTHEMED_COLOR(photoCaptureButtonColor,    "#e0e8f0", "#ffffff")
    DECLARE_QGC_NONTHEMED_COLOR(videoCaptureButtonColor,    "#a00010", "#c2031a")

    // Colors not affecting by theming or enable/disable
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderLight,          "#ffffff")
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderDark,           "#0f1419")
    DECLARE_QGC_SINGLE_COLOR(mapMissionTrajectory,          "#ffb700")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonInterior,         "#00e7a0")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonTerrainCollision, "#c2031a")

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
