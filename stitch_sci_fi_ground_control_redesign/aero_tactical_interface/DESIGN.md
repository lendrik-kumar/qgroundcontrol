---
name: Aero-Tactical Interface
colors:
  surface: '#0f1419'
  surface-dim: '#0f1419'
  surface-bright: '#353a3f'
  surface-container-lowest: '#0a0f14'
  surface-container-low: '#171c21'
  surface-container: '#1b2025'
  surface-container-high: '#252a30'
  surface-container-highest: '#30353b'
  on-surface: '#dee3ea'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#dee3ea'
  inverse-on-surface: '#2c3137'
  outline: '#849495'
  outline-variant: '#3a494b'
  surface-tint: '#00dbe7'
  primary: '#e1fdff'
  on-primary: '#00363a'
  primary-container: '#00f2ff'
  on-primary-container: '#006a71'
  inverse-primary: '#00696f'
  secondary: '#ffdb9d'
  on-secondary: '#412d00'
  secondary-container: '#feb700'
  on-secondary-container: '#6b4b00'
  tertiary: '#fff5f4'
  on-tertiary: '#680008'
  tertiary-container: '#ffd0cb'
  on-tertiary-container: '#c2031a'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#74f5ff'
  primary-fixed-dim: '#00dbe7'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#ffdea8'
  secondary-fixed-dim: '#ffba20'
  on-secondary-fixed: '#271900'
  on-secondary-fixed-variant: '#5e4200'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410003'
  on-tertiary-fixed-variant: '#930010'
  background: '#0f1419'
  on-background: '#dee3ea'
  surface-variant: '#30353b'
typography:
  display-tactical:
    fontFamily: Archivo Narrow
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: 0.05em
  headline-lg:
    fontFamily: Archivo Narrow
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-sm:
    fontFamily: Archivo Narrow
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.2'
  body-md:
    fontFamily: Archivo Narrow
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.4'
  label-caps:
    fontFamily: Space Mono
    fontSize: 10px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.1em
  data-mono:
    fontFamily: Space Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.0'
  display-tactical-mobile:
    fontFamily: Archivo Narrow
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.1'
spacing:
  unit: 4px
  margin-mobile: 12px
  gutter-sm: 8px
  stack-compact: 4px
  safe-area-top: 44px
---

## Brand & Style
The design system is engineered for high-stakes, real-time drone telemetry and ground control. It targets professional operators requiring rapid data ingestion in low-light environments. 

The aesthetic is **Tactical Glassmorphism**, blending the precision of military instrumentation with futuristic, holographic layering. The interface should feel like a "Heads-Up Display" (HUD) projected onto a glass cockpit. Visuals are defined by high-density information, sharp geometric cut-outs, and a sense of layered depth. Every element must feel functional, technical, and urgent.

## Colors
This design system utilizes a "Deep Space" palette to preserve night vision and maximize contrast for tactical overlays.

- **Primary (Neon Cyan):** Used for active telemetry, stable flight paths, and primary UI borders. It represents the "normal" operational state.
- **Secondary (Amber):** Reserved for warnings, mid-level alerts, and navigational waypoints.
- **Tertiary (Signal Red):** Critical failures, low battery, and restricted zones.
- **Neutral/Background:** A multi-layered dark slate (#0A0F14).
- **Glass Surfaces:** Semi-transparent fills (approx. 10-15% opacity) with heavy backdrop blurs to create the holographic effect.

## Typography
The typography system prioritizes legibility under duress and high information density. 

**Archivo Narrow** is the primary typeface, chosen for its condensed footprint which allows for more data points on mobile screens without sacrificing vertical clarity. **Space Mono** is used exclusively for technical readouts, coordinates, and labels to evoke a computer-terminal aesthetic and ensure character alignment in streaming data. All labels should be uppercase to enhance the "instrumental" feel.

## Layout & Spacing
The layout follows a **High-Density Fluid Grid** optimized for mobile portrait and landscape orientations.

- **Grid Model:** A 12-column fluid grid is used, but elements often snap to a 4px hard grid to maintain "pixel-perfect" technical alignment.
- **Margins:** Tight 12px side margins on mobile to maximize the visual field for maps and video feeds.
- **Padding:** Internal component padding is aggressive (often 4px or 8px) to allow for more data visualization per square inch.
- **Responsive Behavior:** On mobile, the interface uses "Edge-to-Edge" video/map backgrounds with floating UI "widgets" docked to the corners, mimicking a drone controller's physical layout.

## Elevation & Depth
Depth is created through **Glassmorphic Stacking** rather than traditional shadows.

- **Base Layer:** The camera feed or tactical map.
- **Mid Layer:** Semi-transparent "Glass Panels" (Backdrop filter: blur 20px) with 1px inner strokes in Primary Cyan (20% opacity).
- **Top Layer:** Interactive elements and critical alerts. These use "Glow" effects (outer-glow with 0px spread, 8px blur) in the primary or secondary color to simulate light emission from a holographic display.
- **Lines:** Use ultra-thin (0.5pt to 1pt) lines for connectors and grid overlays to maintain a precise, technical look.

## Shapes
The shape language is strictly **Geometric and Angular**. 

Use sharp 90-degree corners for most containers. For decorative or high-tech emphasis, use "Clipped Corners" (45-degree chamfers) on one or two edges of a button or card. This "stealth-fighter" geometry reinforces the tactical nature of the system. Circular elements are reserved exclusively for compasses, radar sweeps, and analog-style gauges.

## Components
- **Primary Action Buttons:** Sharp-edged, ghost-style borders (1px Cyan). On "Active," they fill with a subtle cyan gradient (10% to 30% opacity) and a slight outer glow.
- **Data Chips:** Small, rectangular modules with `label-caps` typography. They should have a semi-transparent background and a left-accent border 2px thick.
- **HUD Overlays:** Crosshairs and horizon lines should be drawn with 0.5px Cyan lines, using "bracket" shapes `[ ]` to frame active targets.
- **Input Fields:** Bottom-border only, or a thin "U" shape frame. The cursor should be a solid block (blinking) to match the monospaced font style.
- **Status Indicators:** Small geometric dots (diamonds or squares). Pulsing animations (0.5s duration) denote active recording or signal transmission.
- **Cards:** No solid backgrounds. Use `backdrop-filter: blur()` and a thin, low-opacity primary border.