import Foundation

protocol ConnectionManaging {
    func listServers() -> [ServerSummary]
    func connect(serverId: UUID)
    func disconnect(serverId: UUID)
    func presentAddServer()
    func addServer(_ request: NewConnectionRequest)
    func quitApp()
}

struct ServerSummary {
    let id: UUID
    let displayName: String
    let statusLabel: String
    let canConnect: Bool
    let canDisconnect: Bool
}

final class PreviewConnectionManager: ConnectionManaging {
    private let store: MockConnectionStore

    init(store: MockConnectionStore = .shared) {
        self.store = store
    }

    func listServers() -> [ServerSummary] {
        store.listSummaries()
    }

    func connect(serverId: UUID) {
        store.connect(id: serverId)
    }

    func disconnect(serverId: UUID) {
        store.disconnect(id: serverId)
    }

    func presentAddServer() {}

    func addServer(_ request: NewConnectionRequest) {
        store.addConnection(request: request)
    }

    func quitApp() {}
}
