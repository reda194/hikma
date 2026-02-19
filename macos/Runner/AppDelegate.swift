import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // Keep app alive in background after closing window.
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let registrar = controller.registrar(forPlugin: "PopupWindowPlugin")
      PopupWindowPlugin.register(with: registrar)
    }
  }

  override func applicationWillTerminate(_ notification: Notification) {
    super.applicationWillTerminate(notification)
    PopupWindowController.getInstance().dispose()
  }
}
