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
    private var trayMenuController: TrayMenuController?
    private let connectionManager = QuitAwareConnectionManager()
    private let navigator: any NavigationPresenter

    override init() {
        var registry = NavigationViewRegistry()
        Self.setupViewRegistry(&registry)
        let presenter = RegistryNavigationPresenter(
            registry: registry,
            rootContainer: MainRootView.rootContainer
        )
        navigator = presenter
        super.init()
    }

    nonisolated private static func setupViewRegistry(_ registry: inout NavigationViewRegistry) {
        AddConnectionModalView.register(in: &registry)
        MainRootView.register(in: &registry)
        SettingsView.register(in: &registry)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }

    private func setupMenuBar() {
        let viewModel = TrayViewModel(connectionManager: connectionManager, navigator: navigator)
        trayMenuController = TrayMenuController(viewModel: viewModel)

        statusItemController = StatusBarItemController(
            systemSymbolName: "network",
            accessibilityDescription: "FTP Client",
            action: nil,
            target: nil,
            menu: trayMenuController?.menu
        )
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

    func addServer(_ request: NewConnectionRequest) {
        fallback.addServer(request)
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
