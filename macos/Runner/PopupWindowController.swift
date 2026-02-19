import Cocoa
import FlutterMacOS

/// Controller for managing native NSPanel popup window for Hadith display
class PopupWindowController {
    static var shared: PopupWindowController?

    var panel: NSPanel?
    private var flutterViewController: FlutterViewController?
    private var hostingWindow: NSWindow?
    private var autoDismissTimer: Timer?
    private var remainingTime: TimeInterval = 0
    private var isHovered: Bool = false

    // Position tracking
    private var currentHadithData: [String: Any]?
    private var currentPositionType: PopupPositionType = .bottomRight
    private var displayDuration: TimeInterval = 8.0

    private init() {}

    /// Get or create the shared singleton instance
    static func getInstance() -> PopupWindowController {
        if shared == nil {
            shared = PopupWindowController()
        }
        return shared!
    }

    /// Show popup with Hadith content
    func showPopup(
        hadithData: [String: Any],
        positionType: PopupPositionType,
        duration: TimeInterval
    ) {
        self.currentHadithData = hadithData
        self.currentPositionType = positionType
        self.displayDuration = duration
        self.remainingTime = duration

        // Ensure we're on main thread
        DispatchQueue.main.async { [weak self] in
            self?.createOrUpdatePanel()
        }
    }

    /// Hide popup window
    func hidePopup() {
        DispatchQueue.main.async { [weak self] in
            self?.autoDismissTimer?.invalidate()
            self?.autoDismissTimer = nil
            self?.panel?.orderOut(nil)
        }
    }

    /// Update current Hadith content without recreating panel
    func updateHadith(hadithData: [String: Any]) {
        self.currentHadithData = hadithData
        // Send update to Flutter view via method channel
        sendHadithUpdateToFlutter()
    }

    /// Set hover state (pauses auto-dismiss timer)
    func setHovered(_ hovered: Bool) {
        self.isHovered = hovered
        if hovered {
            pauseAutoDismiss()
        } else {
            resumeAutoDismiss()
        }
    }

    // MARK: - Private Methods

    private func createOrUpdatePanel() {
        if panel == nil {
            createPanel()
        }

        guard let panel = panel else { return }

        // Position panel on screen
        positionPanel(panel)

        // Send Hadith data to Flutter
        sendHadithDataToFlutter()

        // Show panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Start auto-dismiss timer
        startAutoDismiss()
    }

    private func createPanel() {
        // Create Flutter view controller for the popup content
        let flutterViewController = FlutterViewController()
        self.flutterViewController = flutterViewController

        // Create NSPanel (floating window)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.nonactivatingPanel, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Configure panel for floating popup behavior
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.hasShadow = true

        // Make panel not activate app when shown
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Set content view controller
        panel.contentViewController = flutterViewController

        // Setup frosted glass background
        setupFrostedGlassEffect(for: panel)

        // Setup hover tracking
        setupHoverTracking(for: panel)

        self.panel = panel

        // Register method channel for Flutter communication
        setupMethodChannel(for: flutterViewController)
    }

    private func setupFrostedGlassEffect(for panel: NSPanel) {
        guard let contentView = panel.contentView else { return }

        // Create visual effect view for frosted glass
        let visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .popover // Frosted glass effect
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active

        // Insert visual effect view at the bottom of the view hierarchy
        contentView.addSubview(visualEffectView, positioned: .below, relativeTo: contentView.subviews.first)

        // Constrain visual effect view to fill the panel
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupHoverTracking(for panel: NSPanel) {
        // Add tracking area for hover detection
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect
        ]

        let trackingArea = NSTrackingArea(
            rect: panel.frame,
            options: options,
            owner: self,
            userInfo: nil
        )

        panel.contentView?.addTrackingArea(trackingArea)
    }

    private func setupMethodChannel(for flutterViewController: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_events",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Controller unavailable", details: nil))
                return
            }

            switch call.method {
            case "onHoverChanged":
                if let hovered = call.arguments as? Bool {
                    self.setHovered(hovered)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected boolean", details: nil))
                }

            case "onAction":
                if let action = call.arguments as? String {
                    self.handleAction(action)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected string", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func positionPanel(_ panel: NSPanel) {
        let calculator = PopupPositionCalculator()
        let targetScreen = calculator.detectScreenWithCursor()
        let position = calculator.calculatePosition(
            for: currentPositionType,
            panelSize: panel.frame.size,
            on: targetScreen
        )

        panel.setFrameOrigin(position)
    }

    private func sendHadithDataToFlutter() {
        guard let hadithData = currentHadithData,
              let flutterViewController = flutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_content",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.invokeMethod("setHadith", arguments: hadithData)
    }

    private func sendHadithUpdateToFlutter() {
        guard let hadithData = currentHadithData,
              let flutterViewController = flutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_content",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.invokeMethod("updateHadith", arguments: hadithData)
    }

    private func handleAction(_ action: String) {
        // Send action back to main app's method channel
        guard let flutterViewController = flutterViewController else { return }

        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_actions",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.invokeMethod("onAction", arguments: action)
    }

    // MARK: - Auto Dismiss Timer

    private func startAutoDismiss() {
        autoDismissTimer?.invalidate()

        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isHovered else { return }

            self.remainingTime -= 0.1

            // Update Flutter with remaining time
            self.sendTimerUpdate()

            if self.remainingTime <= 0 {
                self.hidePopup()
            }
        }
    }

    private func pauseAutoDismiss() {
        // Timer continues but doesn't decrease remainingTime
    }

    private func resumeAutoDismiss() {
        // Timer resumes decreasing remainingTime
    }

    private func sendTimerUpdate() {
        guard let flutterViewController = flutterViewController else { return }

        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_content",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        let data: [String: Any] = [
            "remainingMillis": Int(remainingTime * 1000),
            "displayDuration": Int(displayDuration * 1000)
        ]

        channel.invokeMethod("updateTimer", arguments: data)
    }

    /// Clean up resources
    func dispose() {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        panel?.close()
        panel = nil
        flutterViewController = nil
    }
}

// MARK: - PopupPositionType Enum

enum PopupPositionType: Int {
    case topLeft = 0
    case topRight = 1
    case bottomLeft = 2
    case bottomRight = 3
    case center = 4
}

// MARK: - PopupPositionCalculator Struct

struct PopupPositionCalculator {

    /// Detect which screen contains the cursor
    func detectScreenWithCursor() -> NSScreen {
        let mouseLocation = NSEvent.mouseLocation

        // Find screen containing cursor
        if let screenWithCursor = NSScreen.screens.first(where: { screen in
            screen.frame.contains(mouseLocation)
        }) {
            return screenWithCursor
        }

        // Fallback to main screen
        return NSScreen.main ?? NSScreen.screens.first!
    }

    /// Calculate popup position based on position type and screen
    func calculatePosition(
        for positionType: PopupPositionType,
        panelSize: NSSize,
        on screen: NSScreen
    ) -> CGPoint {
        let screenFrame = screen.visibleFrame
        let padding: CGFloat = 20.0 // Padding from screen edges

        switch positionType {
        case .topLeft:
            return CGPoint(
                x: screenFrame.minX + padding,
                y: screenFrame.maxY - panelSize.height - padding
            )

        case .topRight:
            return CGPoint(
                x: screenFrame.maxX - panelSize.width - padding,
                y: screenFrame.maxY - panelSize.height - padding
            )

        case .bottomLeft:
            return CGPoint(
                x: screenFrame.minX + padding,
                y: screenFrame.minY + padding
            )

        case .bottomRight:
            return CGPoint(
                x: screenFrame.maxX - panelSize.width - padding,
                y: screenFrame.minY + padding
            )

        case .center:
            return CGPoint(
                x: screenFrame.midX - (panelSize.width / 2),
                y: screenFrame.midY - (panelSize.height / 2)
            )
        }
    }

    /// Clamp position to ensure panel stays within screen bounds
    func clampPosition(
        _ position: CGPoint,
        panelSize: NSSize,
        to screen: NSScreen
    ) -> CGPoint {
        let screenFrame = screen.visibleFrame

        let clampedX = max(
            screenFrame.minX,
            min(position.x, screenFrame.maxX - panelSize.width)
        )

        let clampedY = max(
            screenFrame.minY,
            min(position.y, screenFrame.maxY - panelSize.height)
        )

        return CGPoint(x: clampedX, y: clampedY)
    }
}
