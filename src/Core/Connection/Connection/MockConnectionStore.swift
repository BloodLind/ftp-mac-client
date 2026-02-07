import Foundation

enum MockConnectionState: Equatable {
    case connected(speedLabel: String)
    case disconnected

    var statusLabel: String {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        }
    }

    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        case .disconnected:
            return false
        }
    }

    var speedLabel: String? {
        switch self {
        case .connected(let speedLabel):
            return speedLabel
        case .disconnected:
            return nil
        }
    }
}

struct MockConnection: Identifiable, Equatable {
    let id: UUID
    var displayName: String
    var host: String
    var protocolName: String
    var expectedSpeedLabel: String
    var state: MockConnectionState

    var statusLabel: String { state.statusLabel }
    var canConnect: Bool { !state.isConnected }
    var canDisconnect: Bool { state.isConnected }
    var speedLabel: String? { state.speedLabel }
}

final class MockConnectionStore {
    static let shared = MockConnectionStore()

    private var connections: [MockConnection]

    init(connections: [MockConnection] = MockConnection.samples()) {
        self.connections = connections
    }

    func listConnections() -> [MockConnection] {
        connections
    }

    func listSummaries() -> [ServerSummary] {
        connections.map { connection in
            ServerSummary(
                id: connection.id,
                displayName: connection.displayName,
                statusLabel: connection.statusLabel,
                canConnect: connection.canConnect,
                canDisconnect: connection.canDisconnect
            )
        }
    }

    func connect(id: UUID) {
        updateConnection(id: id) { connection in
            connection.state = .connected(speedLabel: connection.expectedSpeedLabel)
        }
    }

    func disconnect(id: UUID) {
        updateConnection(id: id) { connection in
            connection.state = .disconnected
        }
    }

    func addConnection(request: NewConnectionRequest) {
        let displayName = request.displayName.isEmpty ? request.host : request.displayName
        let connection = MockConnection(
            id: UUID(),
            displayName: displayName,
            host: request.host,
            protocolName: request.protocolType.displayName,
            expectedSpeedLabel: "12 MB/s",
            state: .disconnected
        )
        connections.append(connection)
    }

    private func updateConnection(id: UUID, update: (inout MockConnection) -> Void) {
        guard let index = connections.firstIndex(where: { $0.id == id }) else { return }
        update(&connections[index])
    }
}

extension MockConnection {
    static func samples() -> [MockConnection] {
        [
            MockConnection(
                id: UUID(),
                displayName: "Production Server",
                host: "192.168.1.42",
                protocolName: ConnectionProtocolType.sftp.displayName,
                expectedSpeedLabel: "24 MB/s",
                state: .connected(speedLabel: "24 MB/s")
            ),
            MockConnection(
                id: UUID(),
                displayName: "Staging Database",
                host: "10.0.0.51",
                protocolName: ConnectionProtocolType.ftp.displayName,
                expectedSpeedLabel: "8 MB/s",
                state: .connected(speedLabel: "8 MB/s")
            ),
            MockConnection(
                id: UUID(),
                displayName: "Backup Assets",
                host: "aws-east-1",
                protocolName: ConnectionProtocolType.s3.displayName,
                expectedSpeedLabel: "4 MB/s",
                state: .disconnected
            ),
            MockConnection(
                id: UUID(),
                displayName: "Legacy Share",
                host: "192.168.1.100",
                protocolName: ConnectionProtocolType.smb.displayName,
                expectedSpeedLabel: "6 MB/s",
                state: .disconnected
            )
        ]
    }
}
