import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// TacticalNotificationDrawer
/// Docked right-edge MAVLink STATUSTEXT log with per-severity color-coded borders.
/// Severity prefixes:  <#E> = Error/Warning   <#I> = Info   <#N> = Normal
/// Colors:  Info  → #00E5FF (faint cyan)
///          Warn  → #FFB300 (neon amber)
///          Crit  → #FF1744 (pulsing crimson)
Item {
    id: _root

    // Public interface
    property var    activeVehicle:  null
    property bool   drawerOpen:     false

    // Internal sizing — all expressed as ScreenTools ratios, never raw ints
    readonly property real _drawerWidth:      ScreenTools.defaultFontPixelWidth  * 32
    readonly property real _rowMinHeight:     ScreenTools.defaultFontPixelHeight * 2.2
    readonly property real _borderWidth:      ScreenTools.defaultFontPixelHeight * 0.18
    readonly property real _innerPadding:     ScreenTools.defaultFontPixelWidth  * 0.75
    readonly property real _toggleBtnWidth:   ScreenTools.defaultFontPixelHeight * 2.0

    // Severity palette constants
    readonly property color _colorInfo:   qgcPal.colorBlue
    readonly property color _colorWarn:   "#FFB300"
    readonly property color _colorCrit:   "#FF1744"
    readonly property color _colorBg:     "#0B0F19"

    // Message model
    ListModel { id: _messageModel }

    // Parse severity from QGC message prefix tags
    function _severityFromMessage(msg) {
        if (msg.indexOf("<#E>") !== -1) return "warn"
        if (msg.indexOf("<#I>") !== -1) return "info"
        return "normal"
    }

    function _colorForSeverity(sev) {
        if (sev === "warn") return _colorWarn
        if (sev === "crit") return _colorCrit
        return _colorInfo
    }

    function _stripTags(msg) {
        return msg.replace(/<#[A-Z]>/g, "").trim()
    }

    function addMessage(msg) {
        var sev   = _severityFromMessage(msg)
        var clean = _stripTags(msg)
        _messageModel.insert(0, { "messageText": clean, "severity": sev })
        // Cap the log at 120 entries to prevent unbounded memory growth
        if (_messageModel.count > 120) {
            _messageModel.remove(120, _messageModel.count - 120)
        }
        // Auto-scroll to top only when not user-interacting
        if (!_msgList.moving) {
            _msgList.positionViewAtBeginning()
        }
    }

    // Wire vehicle message signals
    Connections {
        target: activeVehicle
        enabled: activeVehicle !== null

        function onNewFormattedMessage(formattedMessage) {
            _root.addMessage(formattedMessage)
        }
    }

    // ── Slide-in/out via transform translate (no width/height animation) ──────
    transform: Translate {
        x: _root.drawerOpen ? 0 : _root._drawerWidth
        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    width:  _drawerWidth
    height: parent.height

    // ── Drawer background ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        _colorBg
        opacity:      0.88

        // Left tactical border stripe
        Rectangle {
            anchors.left:   parent.left
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _borderWidth
            color:          _colorInfo
            opacity:        0.6
        }
    }

    // ── Header ───────────────────────────────────────────────────────────────
    Rectangle {
        id:             _header
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.top:    parent.top
        height:         ScreenTools.defaultFontPixelHeight * 2.5
        color:          Qt.rgba(0, 0.898, 1, 0.12)

        RowLayout {
            anchors.fill:       parent
            anchors.margins:    _innerPadding
            spacing:            _innerPadding

            QGCLabel {
                Layout.fillWidth:   true
                text:               qsTr("ALERT LOG")
                font.bold:          true
                font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.15
                color:              _colorInfo
                font.pointSize:     ScreenTools.defaultFontPointSize * 0.9
                font.family:        "Courier New"
            }

            // Clear all button
            Rectangle {
                width:  ScreenTools.defaultFontPixelHeight * 1.4
                height: width
                radius: width / 2
                color:  Qt.rgba(1, 1, 1, 0.08)

                QGCColoredImage {
                    anchors.fill:       parent
                    anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.2
                    source:             "/res/TrashDelete.svg"
                    color:              _colorInfo
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    mipmap:             true
                }

                QGCMouseArea {
                    fillItem: parent
                    onClicked: _messageModel.clear()
                }
            }
        }
    }

    // ── Message list ──────────────────────────────────────────────────────────
    ListView {
        id:                 _msgList
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        _header.bottom
        anchors.bottom:     parent.bottom
        anchors.margins:    _innerPadding
        clip:               true
        model:              _messageModel
        spacing:            ScreenTools.defaultFontPixelHeight * 0.2
        flickableDirection: Flickable.VerticalFlick

        delegate: Item {
            width:      _msgList.width
            height:     Math.max(_rowMinHeight, _msgLabel.implicitHeight + _innerPadding * 2)

            readonly property color _borderColor: {
                if (model.severity === "warn") return _colorWarn
                if (model.severity === "crit") return _colorCrit
                return Qt.rgba(0, 0.898, 1, 0.35)  // faint info cyan
            }

            // Row background
            Rectangle {
                anchors.fill:   parent
                color:          Qt.rgba(1, 1, 1, 0.04)
                radius:         ScreenTools.defaultFontPixelHeight * 0.12
            }

            // Left severity border
            Rectangle {
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width:          _borderWidth
                color:          _borderColor
                radius:         ScreenTools.defaultFontPixelHeight * 0.1

                // Critical pulse animation
                SequentialAnimation on opacity {
                    loops:      Animation.Infinite
                    running:    model.severity === "crit"
                    NumberAnimation { to: 0.3; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutSine }
                }
            }

            QGCLabel {
                id:                     _msgLabel
                anchors.left:           parent.left
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin:     _borderWidth + _innerPadding
                anchors.rightMargin:    _innerPadding
                text:                   model.messageText
                wrapMode:               Text.WordWrap
                color:                  model.severity === "warn" ? _colorWarn
                                        : model.severity === "crit" ? _colorCrit
                                        : qgcPal.text
                font.pointSize:         ScreenTools.defaultFontPointSize * 0.85
                font.family:            "Courier New"
            }

            // Fade in on entry
            opacity: 0
            NumberAnimation on opacity {
                from:       0
                to:         1
                duration:   200
                easing.type: Easing.OutCubic
                running:    true
            }
        }
    }

    QGCPalette { id: qgcPal }
}
