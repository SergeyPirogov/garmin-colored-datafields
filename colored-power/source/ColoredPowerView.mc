import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Properties;

class ColoredPowerView extends WatchUi.DataField {

    // Power zone colors matching Wahoo ELEMNT style
    // Zone 1: Gray   (Active Recovery,  < 55% FTP)
    // Zone 2: Blue   (Endurance,        55–75% FTP)
    // Zone 3: Green  (Tempo,            76–90% FTP)
    // Zone 4: Yellow (Threshold,        91–105% FTP)
    // Zone 5: Orange (VO2 Max,          106–120% FTP)
    // Zone 6: Red    (Anaerobic,        > 120% FTP)
    hidden const ZONE_COLORS = [
        0x808080, // Zone 1 - Gray
        0x0080FF, // Zone 2 - Blue
        0x00C000, // Zone 3 - Green
        0xFFFF00, // Zone 4 - Yellow
        0xFF0000, // Zone 5 - Red
        0x8000FF, // Zone 6 - Purple
    ] as Array<Number>;

    // compute() is called at 1 Hz, so buffer sizes map directly to seconds
    hidden const AVG_SIZES = [1, 3, 5, 10] as Array<Number>;
    hidden const AVG_LABELS = ["PWR", "3s PWR", "5s PWR", "10s PWR"] as Array<String>;

    hidden var mPower as Number = 0;
    hidden var mZone as Number = 0;
    hidden var mAvgMode as Number = 1; // default 3s

    // Circular buffer for rolling average
    hidden var mBuf as Array<Number> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] as Array<Number>;
    hidden var mBufIdx as Number = 0;
    hidden var mBufSize as Number = 3;
    hidden var mBufFilled as Number = 0;

    // Power zone thresholds as absolute watts [z1_max, z2_max, z3_max, z4_max, z5_max]
    // Values above z5_max are zone 6
    hidden var mZoneThresholds as Array<Number> = [0, 0, 0, 0, 0];

    function initialize() {
        DataField.initialize();
        loadSettings();
    }

    hidden function loadSettings() as Void {
        var z1 = Properties.getValue("Zone1Max") as Number?;
        var z2 = Properties.getValue("Zone2Max") as Number?;
        var z3 = Properties.getValue("Zone3Max") as Number?;
        var z4 = Properties.getValue("Zone4Max") as Number?;
        var z5 = Properties.getValue("Zone5Max") as Number?;

        mZoneThresholds[0] = (z1 != null) ? z1 : 144;
        mZoneThresholds[1] = (z2 != null) ? z2 : 195;
        mZoneThresholds[2] = (z3 != null) ? z3 : 234;
        mZoneThresholds[3] = (z4 != null) ? z4 : 273;
        mZoneThresholds[4] = (z5 != null) ? z5 : 312;

        var mode = Properties.getValue("PowerAvgMode") as Number?;
        var newMode = (mode != null) ? mode : 1;
        if (newMode < 0 || newMode > 3) { newMode = 1; }

        if (newMode != mAvgMode) {
            mAvgMode = newMode;
            mBufSize = AVG_SIZES[mAvgMode];
            // Reset buffer when mode changes
            for (var i = 0; i < mBuf.size(); i++) { mBuf[i] = 0; }
            mBufIdx = 0;
            mBufFilled = 0;
        }
    }

    hidden function pushSample(watts as Number) as Void {
        mBuf[mBufIdx] = watts;
        mBufIdx = (mBufIdx + 1) % mBufSize;
        if (mBufFilled < mBufSize) { mBufFilled++; }
    }

    hidden function rollingAverage() as Number {
        if (mBufFilled == 0) { return 0; }
        var sum = 0;
        for (var i = 0; i < mBufFilled; i++) { sum += mBuf[i]; }
        return (sum / mBufFilled) as Number;
    }

    hidden function getZone(power as Number) as Number {
        if (power <= 0) { return 0; }
        for (var i = 0; i < mZoneThresholds.size(); i++) {
            if (power <= mZoneThresholds[i]) {
                return i + 1;
            }
        }
        return 6;
    }

    function compute(info as Activity.Info) as Void {
        loadSettings();
        var instant = 0;
        if (info has :currentPower && info.currentPower != null) {
            instant = info.currentPower as Number;
        }
        pushSample(instant);
        mPower = rollingAverage();
        mZone = getZone(mPower);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        var bgColor;
        if (mZone == 0 || mPower == 0) {
            bgColor = Graphics.COLOR_DK_GRAY;
        } else {
            bgColor = ZONE_COLORS[mZone - 1] as Number;
        }

        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, 0, width, height);

        // Black text on green (Z3) and yellow (Z4) for contrast, white elsewhere
        var textColor = Graphics.COLOR_WHITE;
        if (mZone == 3 || mZone == 4) {
            textColor = Graphics.COLOR_BLACK;
        }

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

        var powerText = (mPower > 0) ? mPower.toString() : "--";

        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_NUMBER_HOT,
            powerText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var topLabel = AVG_LABELS[mAvgMode];
        if (mZone > 0) {
            var zLow = (mZone == 1) ? 0 : mZoneThresholds[mZone - 2] + 1;
            var zHigh = (mZone <= 5) ? mZoneThresholds[mZone - 1] : mZoneThresholds[4] + 1;
            topLabel = "Z" + mZone + " (" + zLow + "-" + zHigh + ") " + AVG_LABELS[mAvgMode];
        }
        dc.drawText(4, 4, Graphics.FONT_XTINY, topLabel, Graphics.TEXT_JUSTIFY_LEFT);

        // White border outline
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(0, 0, width, height);

        drawZoneBar(dc, width, height);
    }

    hidden function drawZoneBar(dc as Graphics.Dc, width as Number, height as Number) as Void {
        var barHeight = 8;
        var barY = height - barHeight;
        var segW = width / 6;

        for (var i = 0; i < 6; i++) {
            var segColor = ZONE_COLORS[i] as Number;
            var segX = i * segW;
            var segWidth = (i == 5) ? (width - segX) : segW;

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
