import Foundation


@MainActor
final class TrayViewModel: NavigableViewModel {
    var navigation: any NavigationPresenter

    struct ServerItem: Identifiable {
        let id: UUID
        let displayName: String
        let statusLabel: String
        let canConnect: Bool
        let canDisconnect: Bool
    }

    @Published private(set) var servers: [ServerItem] = []
    private let connectionManager: ConnectionManaging
 

    init(connectionManager: ConnectionManaging, navigator: any NavigationPresenter) {
        self.connectionManager = connectionManager
        self.navigation = navigator
        refresh()
    }

    func refresh() {
        servers = connectionManager.listServers()
            .filter { $0.canDisconnect }
            .map { server in
                ServerItem(
                    id: server.id,
                    displayName: server.displayName,
                    statusLabel: server.statusLabel,
                    canConnect: server.canConnect,
                    canDisconnect: server.canDisconnect
                )
            }
    }

    func connect(serverId: UUID) {
        connectionManager.connect(serverId: serverId)
        refresh()
    }

    func disconnect(serverId: UUID) {
        connectionManager.disconnect(serverId: serverId)
        refresh()
    }

    func presentAddServer() {
        Task { @MainActor in
            let viewModel = AddConnectionViewModel(navigationPresenter: navigation)
            let result = await navigation.navigate(viewModel)

            if case .connect(let request) = result {
                connectionManager.addServer(request)
            }
            refresh()
        }
    }

    func openManageWindow() {
        navigation.navigate(MainViewModel(settingsViewModel: SettingsViewModel(), navigation: navigation))
    }

    func quitApp() {
        connectionManager.quitApp()
    }

    static func preview() -> TrayViewModel {
        TrayViewModel(
            connectionManager: PreviewConnectionManager(), navigator: NoopNavigationPresenter())
    }
}
