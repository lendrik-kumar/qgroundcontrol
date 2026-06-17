pragma Singleton

import QtQuick

import QGroundControl
import QGroundControl.Controls

/// Aero-Tactical Design System — Global Token Singleton
///
/// All QML files in the Aero-Tactical UI should import this singleton
/// for consistent design tokens (colors, spacing, animation durations,
/// typography scales). Do NOT hard-code design values; always reference
/// TacticalTheme.<property>.
///
/// Usage:
///     import QGroundControl.Controls
///     Rectangle { color: TacticalTheme.surfaceContainer }
///
Item {
    id: _root

    // ── Color Tokens ──────────────────────────────────────────────────────────
    // Base surfaces (layered depth from darkest to lightest)
    readonly property color void_:                  "#020617"    // Absolute darkest — camera/map bg
    readonly property color surfaceBase:            "#0c1324"    // Primary background
    readonly property color surfaceDim:             "#0c1324"    // Same as base (alias)
    readonly property color surfaceContainerLow:    "#151b2d"    // Slightly elevated panels
    readonly property color surfaceContainer:       "#1d2335"    // Standard panel background
    readonly property color surfaceContainerHigh:   "#23293e"    // Elevated card/frame
    readonly property color surfaceContainerHighest:"#2e344a"    // Topmost surface (borders, dividers)
    readonly property color surfaceBright:          "#33394c"    // Bright surface for focus states

    // Primary (Neon Cyan) — Active state, telemetry readouts, stable flight, borders
    readonly property color primary:                "#00f2ff"    // Text on primary bg
    readonly property color textOnPrimary:          "#00363a"    // Dark text on primary element
    readonly property color primaryContainer:       "#004a4e"    // Filled primary state
    readonly property color cyanAccent:             "#00f2ff"    // Main cyan accent (most used)
    readonly property color cyanDim:                "#00dbe7"    // Dimmed cyan for inactive

    // Secondary (Pinkish red / amber equivalent in Jarvis theme)
    readonly property color amber:                  "#ccc2dc"    // Secondary from jarvis
    readonly property color amberDim:               "#e8def8"    // Dimmed secondary

    // Tertiary (Signal Red) — Critical failures, restricted zones, recording
    readonly property color signalRed:              "#ffb4ab"    // Main signal red
    readonly property color signalRedBright:        "#ffdad6"    // Bright signal red (active errors)

    // Text hierarchy
    readonly property color textPrimary:            "#e2e2e9"    // Body text on dark bg
    readonly property color textSecondary:          "#c4c6d0"    // Muted / secondary text
    readonly property color textOnAccent:           "#002022"    // Dark text on cyan bg
    readonly property color textOnAmber:            "#1d192b"    // Dark text on amber bg

    // Outlines & borders
    readonly property color outlineStrong:          "#8e9099"    // Standard borders
    readonly property color outlineSubtle:          "#44474e"    // Thin borders/dividers
    readonly property color glassStroke:            "#4d00f2ff"  // 30% opacity cyan stroke for glass

    // Semantic status colors
    readonly property color statusOk:               "#00f2ff"    // Cyan — all systems nominal
    readonly property color statusWarn:             "#ffb2bc"    // Pink — caution
    readonly property color statusCritical:         "#ffb4ab"    // Red — critical failure
    readonly property color statusInactive:         "#8e9099"    // Grey — offline/inactive

    // ── Glow Effects ─────────────────────────────────────────────────────────
    // QML doesn't support CSS box-shadow natively. Use Rectangle + blur layer.
    // The color values here are intended for use with:
    //   layer.effect: MultiEffect { shadowEnabled: true; shadowColor: TacticalTheme.glowCyan }
    readonly property color glowCyan:              "#8000f2ff"   // 50% opacity cyan glow
    readonly property color glowAmber:             "#80ffb2bc"   // 50% opacity amber/pink glow
    readonly property color glowRed:               "#80ffb4ab"   // 50% opacity red glow

    // ── Spacing (4px grid) ────────────────────────────────────────────────────
    readonly property real unit:                    4            // Base grid unit (px)
    readonly property real spaceXS:                 4            // 1 unit
    readonly property real spaceSM:                 8            // 2 units
    readonly property real spaceMD:                 12           // 3 units — mobile side margins
    readonly property real spaceLG:                 16           // 4 units
    readonly property real spaceXL:                 24           // 6 units
    readonly property real space2XL:               32           // 8 units

    // Component-specific spacing
    readonly property real panelPadding:            spaceMD      // Internal panel padding
    readonly property real cardPadding:             spaceSM      // Data chip / small card padding
    readonly property real sidebarWidth:            220          // Persistent sidebar width (px)
    readonly property real sidebarIconWidth:        64           // Collapsed icon-only sidebar width
    readonly property real toolbarHeight:           36           // Slim top status bar

    // ── Border Radii ─────────────────────────────────────────────────────────
    // Jarvis language: sharp corners everywhere, 0px radius
    readonly property real radiusNone:              0            // Panels, data tables
    readonly property real radiusXS:                0            // Subtle rounding for tight elements
    readonly property real radiusSM:                0            // Buttons (slight chamfer)
    readonly property real radiusMD:                0            // Dialog corners
    readonly property real radiusCircle:            999          // Circular elements (radar, compass)

    // ── Border widths ────────────────────────────────────────────────────────
    readonly property real borderThin:              0.5          // HUD crosshair lines, grid overlays
    readonly property real borderStandard:          1            // Panel borders, ghost buttons
    readonly property real borderAccent:            2            // Left accent bar on active nav item

    // ── Animation Durations ──────────────────────────────────────────────────
    readonly property int durationFast:             150          // State transitions
    readonly property int durationStandard:         250          // Standard transitions
    readonly property int durationSlow:             500          // Status pulses, fades
    readonly property int durationPulse:            800          // Heartbeat-style animations

    // ── Opacity Levels ────────────────────────────────────────────────────────
    readonly property real opacityGlass:            0.88         // Glass panel background opacity
    readonly property real opacityOverlay:          0.65         // Dark dimming overlay
    readonly property real opacitySubtle:           0.35         // Inactive element opacity
    readonly property real opacityDisabled:         0.4          // Disabled control opacity

    // ── Typography Scale (relative to ScreenTools.defaultFontPointSize) ───────
    // Use font.family: ScreenTools.tacticalFontFamily for Archivo Narrow
    // Use font.family: ScreenTools.monoDataFontFamily for Space Mono
    readonly property real labelCapsSize:           0.75         // * defaultFontPointSize — uppercase chip labels
    readonly property real bodyMdSize:              1.0          // Standard body text
    readonly property real headlineSmSize:          1.25         // Section headers
    readonly property real headlineLgSize:          1.6          // Major headers (panel titles)
    readonly property real displaySize:             2.2          // HUD large values (ALT, SPD)

    // Letter spacing for label-caps style (uppercase small labels)
    readonly property real labelCapsLetterSpacing:  1.0          // em * (pointSize / 10)

    // ── Z-Order Layers ────────────────────────────────────────────────────────
    // Mirrors QGroundControl z-order constants but for tactical overlay layers
    readonly property int zBase:                    0
    readonly property int zMapOverlay:              1
    readonly property int zHUDWidgets:              10
    readonly property int zPanels:                  20
    readonly property int zSidebar:                 30
    readonly property int zToolbar:                 40
    readonly property int zAlerts:                  50
    readonly property int zModals:                  100

    // ── Helper functions ──────────────────────────────────────────────────────
    /// Returns the appropriate status color for a given status string
    function statusColor(status) {
        switch (status.toUpperCase()) {
            case "OK":      case "ONLINE":  case "ARMED":   case "ACTIVE":  return statusOk
            case "WARN":    case "WARNING":                                 return statusWarn
            case "ERROR":   case "CRITICAL": case "FAILED":                return statusCritical
            default:                                                        return statusInactive
        }
    }

    /// Returns uppercase string (for label-caps typography convention)
    function caps(str) { return str ? str.toUpperCase() : "" }
}
