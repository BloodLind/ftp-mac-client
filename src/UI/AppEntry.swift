import AppKit
import SwiftUI

// MARK: - App entry and menu bar setup

@main
struct FTPClientApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let connectionManager = QuitAwareConnectionManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "FTP Client")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.setValue(true, forKeyPath: "shouldHideAnchor")

        popover.behavior = .transient
        popover.animates = false
        popover.appearance = NSApp.effectiveAppearance
        popover.contentViewController = NSHostingController(
            rootView: TrayView(viewModel: TrayViewModel(connectionManager: connectionManager))
        )
        self.popover = popover
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

// MARK: - Connection manager that terminates app on quit

/// Provides ConnectionManaging for the tray UI and terminates the app when Quit is chosen.
private final class QuitAwareConnectionManager: ConnectionManaging {
    private let fallback = PreviewConnectionManager()

    func listServers() -> [ServerSummary] {
        fallback.listServers()
    }

    func connect(serverId: UUID) {
        fallback.connect(serverId: serverId)
    }

    func disconnect(serverId: UUID) {
        fallback.disconnect(serverId: serverId)
    }

    func presentAddServer() {
        fallback.presentAddServer()
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
