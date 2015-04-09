#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3)

captureLocalizedScreenshot("0-Main")
window.collectionViews()[0].cells()[9].tap();
// tap clubs

target.delay(4)
captureLocalizedScreenshot("1-Detail-clubs")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT)


var backBackButton = target.frontMostApp().navigationBar().leftButton()
if (backBackButton.isValid()) {
        backBackButton.tap();
}

window.collectionViews()[0].cells()[13].tap();
// tap laundry

target.delay(4)
captureLocalizedScreenshot("2-Detail-laundry")
