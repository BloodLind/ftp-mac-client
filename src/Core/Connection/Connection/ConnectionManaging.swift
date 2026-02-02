import Foundation

protocol ConnectionManaging {
    func listServers() -> [ServerSummary]
    func connect(serverId: UUID)
    func disconnect(serverId: UUID)
    func presentAddServer()
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
    func listServers() -> [ServerSummary] {
        [
            ServerSummary(
                id: UUID(),
                displayName: "Example FTP",
                statusLabel: "Disconnected",
                canConnect: true,
                canDisconnect: false
            )
        ]
    }

    func connect(serverId: UUID) {}
    func disconnect(serverId: UUID) {}
    func presentAddServer() {}
    func quitApp() {}
}
