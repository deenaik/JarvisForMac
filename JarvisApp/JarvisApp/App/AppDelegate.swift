import Carbon
import Cocoa
import Combine
import SwiftUI
import os

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NSPanel?
    private var dashboardWindow: NSWindow?
    private var hotkeyManager: HotkeyManager?
    private var dashboardHotkeyManager: HotkeyManager?
    private var dashboardObserver: Any?
    private let logger = Logger(subsystem: "com.deenaik.JarvisApp", category: "AppDelegate")

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupDashboardWindow()
        setupHotkey()
        observeDashboardRequest()
        AppState.shared.startBackend()
    }

    private func observeDashboardRequest() {
        dashboardObserver = AppState.shared.$requestShowDashboard.sink { [weak self] show in
            if show {
                AppState.shared.requestShowDashboard = false
                self?.showDashboard()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppState.shared.stopBackend()
    }

    // MARK: - Panel

    private func setupPanel() {
        let panelContent = FloatingPanelView()
            .environmentObject(AppState.shared)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 520),
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentView = NSHostingView(rootView: panelContent)
        panel.isReleasedWhenClosed = false

        // Position at top center of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - 190
            let y = screenFrame.maxY - 540
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Observe panel visibility
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelWillClose),
            name: NSWindow.willCloseNotification,
            object: panel
        )

        self.panel = panel

        // Dismiss on click outside
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self, let panel = self.panel, panel.isVisible else { return }
            // Check if click is outside the panel
            let clickLocation = event.locationInWindow
            if !panel.frame.contains(NSPoint(x: clickLocation.x, y: clickLocation.y)) {
                self.hidePanel()
            }
        }

        // Dismiss on Escape
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape key
                self?.hidePanel()
                return nil
            }
            return event
        }
    }

    private func setupHotkey() {
        hotkeyManager = HotkeyManager(keyCode: UInt32(kVK_ANSI_J), hotkeyId: 1, signature: "JRVS") { [weak self] in
            self?.togglePanel()
        }
        hotkeyManager?.register()

        dashboardHotkeyManager = HotkeyManager(keyCode: UInt32(kVK_ANSI_D), hotkeyId: 2, signature: "JRVD") { [weak self] in
            self?.toggleDashboard()
        }
        dashboardHotkeyManager?.register()
    }

    func togglePanel() {
        if let panel, panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        guard let panel else { return }
        logger.info("Showing panel")
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
        AppState.shared.isPanelVisible = true
    }

    func hidePanel() {
        guard let panel, panel.isVisible else { return }
        logger.info("Hiding panel")
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            panel.orderOut(nil)
            AppState.shared.isPanelVisible = false
            _ = self // prevent premature release
        })
    }

    @objc private func panelWillClose(_ notification: Notification) {
        AppState.shared.isPanelVisible = false
    }

    // MARK: - Dashboard Window

    private func setupDashboardWindow() {
        let dashboardContent = DashboardView()
            .environmentObject(AppState.shared)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor(Color(hex: "0A0F1C"))
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 960, height: 600)
        window.title = "Jarvis Dashboard"
        window.contentView = NSHostingView(rootView: dashboardContent)

        // Center on screen
        window.center()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dashboardWillClose),
            name: NSWindow.willCloseNotification,
            object: window
        )

        self.dashboardWindow = window
    }

    func showDashboard() {
        guard let window = dashboardWindow else { return }
        logger.info("Showing dashboard")
        window.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        AppState.shared.isDashboardVisible = true
    }

    func hideDashboard() {
        guard let window = dashboardWindow, window.isVisible else { return }
        logger.info("Hiding dashboard")
        window.orderOut(nil)
        AppState.shared.isDashboardVisible = false
    }

    func toggleDashboard() {
        if let window = dashboardWindow, window.isVisible {
            hideDashboard()
        } else {
            showDashboard()
        }
    }

    @objc private func dashboardWillClose(_ notification: Notification) {
        AppState.shared.isDashboardVisible = false
    }
}
