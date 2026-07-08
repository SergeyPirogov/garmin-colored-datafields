import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.UserProfile;

class ColoredHRView extends WatchUi.DataField {

    // HR zone colors matching Wahoo ELEMNT style
    hidden const ZONE_COLORS = [
        0x808080, // Zone 1 - Gray
        0x0080FF, // Zone 2 - Blue
        0x00C000, // Zone 3 - Green
        0xFF8000, // Zone 4 - Orange
        0xFF0000, // Zone 5 - Red
    ] as Array<Number>;

    hidden var mHR as Number = 0;
    hidden var mZone as Number = 0;

    // Upper BPM threshold for each zone [z1_max, z2_max, z3_max, z4_max, z5_max]
    hidden var mZoneThresholds as Array<Number> = [115, 135, 155, 175, 220];

    function initialize() {
        DataField.initialize();
        loadZones();
    }

    hidden function loadZones() as Void {
        var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        if (zones != null && zones.size() >= 6) {
            // SDK returns [z0_low, z1_low, z2_low, z3_low, z4_low, z5_low]
            // Upper bound of zone N = lower bound of zone N+1 - 1
            for (var i = 0; i < 5; i++) {
                mZoneThresholds[i] = zones[i + 1] - 1;
            }
        }
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
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        var bgColor;
        if (mZone == 0 || mHR == 0) {
            bgColor = Graphics.COLOR_DK_GRAY;
        } else {
            bgColor = ZONE_COLORS[mZone - 1] as Number;
        }

        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, 0, width, height);

        var textColor = Graphics.COLOR_WHITE;
        if (mZone == 3) {
            textColor = Graphics.COLOR_BLACK;
        }

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

        var hrText = (mHR > 0) ? mHR.toString() : "--";

        dc.drawText(
            width / 2,
            height / 2 - 10,
            Graphics.FONT_NUMBER_HOT,
            hrText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var topLabel = "BPM";
        if (mZone > 0) {
            var zLow = (mZone == 1) ? 0 : mZoneThresholds[mZone - 2] + 1;
            var zHigh = mZoneThresholds[mZone - 1];
            topLabel = "Z" + mZone + " (" + zLow + "-" + zHigh + ") BPM";
        }
        dc.drawText(4, 4, Graphics.FONT_XTINY, topLabel, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(0, 0, width, height);

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

            if (mZone > 0 && i == mZone - 1) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawRectangle(segX, barY, segWidth, barHeight);
            }
        }
    }
}
