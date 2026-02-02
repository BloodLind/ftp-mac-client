import Foundation

@MainActor
final class TrayViewModel: ObservableObject {
    struct ServerItem: Identifiable {
        let id: UUID
        let displayName: String
        let statusLabel: String
        let canConnect: Bool
        let canDisconnect: Bool
    }

    @Published private(set) var servers: [ServerItem] = []

    private let connectionManager: ConnectionManaging

    init(connectionManager: ConnectionManaging) {
        self.connectionManager = connectionManager
        refresh()
    }

    func refresh() {
        servers = connectionManager.listServers().map { server in
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
        connectionManager.presentAddServer()
        refresh()
    }

    func quitApp() {
        connectionManager.quitApp()
    }

    static func preview() -> TrayViewModel {
        TrayViewModel(connectionManager: PreviewConnectionManager())
    }
}
