import Cocoa
import SwiftUI
import os

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NSPanel?
    private var hotkeyManager: HotkeyManager?
    private let logger = Logger(subsystem: "com.deenaik.JarvisApp", category: "AppDelegate")

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupHotkey()
        AppState.shared.startBackend()
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
        hotkeyManager = HotkeyManager { [weak self] in
            self?.togglePanel()
        }
        hotkeyManager?.register()
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
}
