import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Properties;

class ColoredHRView extends WatchUi.DataField {

    // HR zone colors matching Wahoo ELEMNT style
    // Zone 1: Gray  (recovery)
    // Zone 2: Blue  (endurance)
    // Zone 3: Green (aerobic)
    // Zone 4: Yellow/Orange (threshold)
    // Zone 5: Red   (VO2 max)
    hidden const ZONE_COLORS = [
        0x808080, // Zone 1 - Gray
        0x0080FF, // Zone 2 - Blue
        0x00C000, // Zone 3 - Green
        0xFF8000, // Zone 4 - Orange
        0xFF0000, // Zone 5 - Red
    ] as Array<Number>;

    hidden var mHR as Number = 0;
    hidden var mZone as Number = 0;

    // HR zone thresholds [zone1_max, zone2_max, zone3_max, zone4_max]
    // Values above zone4_max are zone 5
    hidden var mZoneThresholds as Array<Number> = [0, 0, 0, 0, 0];

    function initialize() {
        DataField.initialize();
        loadZoneSettings();
    }

    hidden function loadZoneSettings() as Void {
        var z1 = Properties.getValue("Zone1Max") as Number?;
        var z2 = Properties.getValue("Zone2Max") as Number?;
        var z3 = Properties.getValue("Zone3Max") as Number?;
        var z4 = Properties.getValue("Zone4Max") as Number?;
        var z5 = Properties.getValue("Zone5Max") as Number?;

        mZoneThresholds[0] = (z1 != null) ? z1 : 115;
        mZoneThresholds[1] = (z2 != null) ? z2 : 135;
        mZoneThresholds[2] = (z3 != null) ? z3 : 155;
        mZoneThresholds[3] = (z4 != null) ? z4 : 175;
        mZoneThresholds[4] = (z5 != null) ? z5 : 220;
    }

    hidden function getZone(hr as Number) as Number {
        if (hr <= 0) { return 0; }
        for (var i = 0; i < mZoneThresholds.size(); i++) {
            if (hr <= mZoneThresholds[i]) {
                return i + 1;
            }
        }
        return 5;
    }

    function compute(info as Activity.Info) as Void {
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            mHR = info.currentHeartRate as Number;
        } else {
            mHR = 0;
        }
        mZone = getZone(mHR);
        // Reload settings on each compute in case user changed them
        loadZoneSettings();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Determine zone color
        var bgColor;
        if (mZone == 0 || mHR == 0) {
            bgColor = Graphics.COLOR_DK_GRAY;
        } else {
            bgColor = ZONE_COLORS[mZone - 1] as Number;
        }

        // Fill background with zone color
        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, 0, width, height);

        // Choose text color for contrast
        // Zones 1 (gray) and 2 (blue) get white text, rest get white too
        var textColor = Graphics.COLOR_WHITE;
        if (mZone == 3) {
            // Green zone - use black for better contrast
            textColor = Graphics.COLOR_BLACK;
        }

        // Draw HR value - large centered
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

        var hrText = (mHR > 0) ? mHR.toString() : "--";

        // Large HR number in the center
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_NUMBER_HOT,
            hrText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(4, 4, Graphics.FONT_XTINY, "BPM", Graphics.TEXT_JUSTIFY_LEFT);

        // Zone color bar strip at top (like Wahoo's colored band)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(0, 0, width, height);

        // Draw 5-segment zone bar at bottom
        drawZoneBar(dc, width, height);
    }

    hidden function drawZoneBar(dc as Graphics.Dc, width as Number, height as Number) as Void {
        var barHeight = 8;
        var barY = height - barHeight;
        var segW = width / 5;

        for (var i = 0; i < 5; i++) {
            var segColor = ZONE_COLORS[i] as Number;
            var segX = i * segW;
            var segWidth = (i == 4) ? (width - segX) : segW;

            dc.setColor(segColor, segColor);
            dc.fillRectangle(segX, barY, segWidth, barHeight);

            // Highlight active zone segment with a white border
            if (mZone > 0 && i == mZone - 1) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawRectangle(segX, barY, segWidth, barHeight);
            }
        }
    }
}
