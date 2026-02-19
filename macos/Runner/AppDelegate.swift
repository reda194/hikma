import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Register popup window plugin
    PopupWindowPlugin.register(with: registrar as! FlutterPluginRegistrar)

    // Cleanup popup window when app quits
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillTerminate),
      name: NSApplication.willTerminateNotification,
      object: nil
    )
  }

  @objc private func applicationWillTerminate() {
    PopupWindowController.getInstance().dispose()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
