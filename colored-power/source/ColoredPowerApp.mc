import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ColoredPowerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new ColoredPowerView()];
    }
}

function getApp() as ColoredPowerApp {
    return Application.getApp() as ColoredPowerApp;
}
