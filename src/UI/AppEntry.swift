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
    override init() {
        var registry = NavigationViewRegistry()
        Self.setupViewRegistry(&registry)
        let presenter = RegistryNavigationPresenter(
            registry: registry,
            rootContainer: MainRootView.rootContainer
        )
        navigator = presenter
        Self.navigationPresenter = presenter
        GlobalNavigation.presenter = presenter
        super.init()
    }

    nonisolated private static func setupViewRegistry(_ registry: inout NavigationViewRegistry) {
        AddConnectionModalView.register(in: &registry)
        MainRootView.register(in: &registry)
        SettingsView.register(in: &registry)
        TrayView.register(in: &registry)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItemController = StatusBarItemController(
            systemSymbolName: "network",
            action: #selector(togglePopover),
            accessibilityDescription: "FTP Client"
        )
        let viewModel = TrayViewModel(connectionManager: connectionManager, navigator: navigator)
        trayPopoverController = TrayPopoverController(viewModel: viewModel, navigation: navigator)
    }
        )
            rootView: TrayView(viewModel: TrayViewModel(connectionManager: connectionManager)),
            size: NSSize(width: 320, height: 400)
        popoverController = TrayPopoverController(
        )
            target: self
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        trayPopoverController?.toggle(relativeTo: button)
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
