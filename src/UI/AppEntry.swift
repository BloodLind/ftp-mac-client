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
    private var statusItemController: StatusBarItemController?
    private var popoverController: TrayPopoverController?
    private let connectionManager = QuitAwareConnectionManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItemController = StatusBarItemController(
            systemSymbolName: "network",
            action: #selector(togglePopover),
            accessibilityDescription: "FTP Client",
    }
        )
            rootView: TrayView(viewModel: TrayViewModel(connectionManager: connectionManager)),
            size: NSSize(width: 320, height: 400)
        popoverController = TrayPopoverController(
        )
            target: self
    @objc private func togglePopover() {
        guard let button = statusItemController?.statusItem.button else { return }
        popoverController?.toggle(relativeTo: button)

    }

    private func updatePopoverSize() {
        guard let popover = popover, let hostingController = trayHostingController else { return }
        hostingController.view.layoutSubtreeIfNeeded()
        let fittingSize = hostingController.view.fittingSize
        let width: CGFloat = 270
        let height = max(1, fittingSize.height + 8)
        popover.contentSize = NSSize(width: width, height: height)
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

    func addServer(_ request: NewConnectionRequest) {
        fallback.addServer(request)
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
