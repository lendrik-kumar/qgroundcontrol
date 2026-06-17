import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls

/// TacticalNavItem — Individual sidebar navigation button
///
/// Used by TacticalSidebar to render each nav entry.
/// Active item gets a 2px cyan left accent bar + subtle cyan fill.
/// Collapsed state shows icon only, centered.
///
Item {
    id: root

    property string viewId:      ""
    property string iconSource:  ""
    property string label:       ""
    property bool   isActive:    false
    property bool   isCollapsed: false

    signal clicked()

    height:           44
    QGCPalette { id: qgcPal; colorGroupEnabled: true }

        // Active/hover background
        Rectangle {
            anchors.fill: parent
            color:        isActive
                              ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.1)
                              : (_hovered ? Qt.rgba(TacticalTheme.primary.r, TacticalTheme.primary.g, TacticalTheme.primary.b, 0.05) : "transparent")
            Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }

            property bool _hovered: false

            // Left accent bar — only visible when active
            Rectangle {
                id:             accentBar
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width:          4
                color:          TacticalTheme.primary
                opacity:        isActive ? 1 : 0
                layer.enabled:  isActive
                layer.effect:   MultiEffect {
                    shadowEnabled: true
                    shadowColor: TacticalTheme.glowCyan
                    shadowBlur: 1.0
                }
                Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
            }

        RowLayout {
            anchors.fill:            parent
            anchors.leftMargin:      isCollapsed ? 0 : TacticalTheme.spaceLG
            spacing:                 TacticalTheme.spaceSM
            layoutDirection:         Qt.LeftToRight

            QGCColoredImage {
                id:                     _icon
                Layout.alignment:       isCollapsed ? Qt.AlignHCenter | Qt.AlignVCenter : Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth:       isCollapsed
                source:                 root.iconSource
                width:                  18
                height:                 18
                color:                  isActive ? TacticalTheme.primary : TacticalTheme.textSecondary
                fillMode:               Image.PreserveAspectFit
                sourceSize.height:      height

                Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }
            }

            QGCLabel {
                Layout.fillWidth:   true
                visible:            !root.isCollapsed
                text:               root.label
                font.family:        ScreenTools.monoDataFontFamily
                font.pointSize:     ScreenTools.defaultFontPointSize * 0.85
                font.bold:          isActive
                font.letterSpacing: 0.6
                color:              isActive ? TacticalTheme.primary : TacticalTheme.textSecondary
                elide:              Text.ElideRight

                Behavior on color { ColorAnimation { duration: TacticalTheme.durationFast } }
                opacity:            root.isCollapsed ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: TacticalTheme.durationFast } }
            }
        }

        QGCMouseArea {
            fillItem:    parent
            hoverEnabled: true
            onEntered:   parent._hovered = true
            onExited:    parent._hovered = false
            onClicked:   root.clicked()
        }
    }
}
