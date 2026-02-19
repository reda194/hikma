import Cocoa
import FlutterMacOS

/// Plugin for handling popup window method calls from Flutter
public class PopupWindowPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_window",
            binaryMessenger: registrar.messenger
        )
        let instance = PopupWindowPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Register popup events channel for callbacks to Flutter
        let eventsChannel = FlutterMethodChannel(
            name: "com.hikma.app/popup_events",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(instance, channel: eventsChannel)

        // Register popup actions channel
        let actionsChannel = FlutterMethodChannel(
            name: "com.hikma.app/popup_actions",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(instance, channel: actionsChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let controller = PopupWindowController.getInstance()

        switch call.method {
        case "showPopup":
            handleShowPopup(call, result: result, controller: controller)

        case "hidePopup":
            controller.hidePopup()
            result(nil)

        case "updateHadith":
            handleUpdateHadith(call, result: result, controller: controller)

        case "getPopupPosition":
            // Returns current popup position if panel is visible
            if let panel = controller.getCurrentPanel() {
                let positionData: [String: Any] = [
                    "dx": panel.frame.origin.x,
                    "dy": panel.frame.origin.y
                ]
                result(positionData)
            } else {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Method Handlers

    private func handleShowPopup(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult,
        controller: PopupWindowController
    ) {
        guard let args = call.arguments as? [String: Any],
              let hadithData = args["hadith"] as? [String: Any],
              let positionTypeIndex = args["positionType"] as? Int,
              let durationMillis = args["duration"] as? Int else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Expected hadith, positionType, and duration",
                details: nil
            ))
            return
        }

        let positionType = PopupPositionType(rawValue: positionTypeIndex) ?? .bottomRight
        let duration = TimeInterval(durationMillis) / 1000.0

        controller.showPopup(
            hadithData: hadithData,
            positionType: positionType,
            duration: duration
        )

        result(nil)
    }

    private func handleUpdateHadith(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult,
        controller: PopupWindowController
    ) {
        guard let args = call.arguments as? [String: Any],
              let hadithData = args["hadith"] as? [String: Any] else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Expected hadith data",
                details: nil
            ))
            return
        }

        controller.updateHadith(hadithData: hadithData)
        result(nil)
    }
}

// MARK: - PopupWindowController Extension for Plugin Access

extension PopupWindowController {
    /// Get current panel (for plugin access)
    func getCurrentPanel() -> NSPanel? {
        return panel
    }
}
