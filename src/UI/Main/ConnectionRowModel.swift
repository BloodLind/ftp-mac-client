import Foundation

struct ConnectionRowModel: Identifiable {
    let id: UUID
    let displayName: String
    let host: String
    let protocolName: String
    let speedLabel: String?
    let isConnected: Bool
    let canReconnect: Bool
    let canDisconnect: Bool

    init(connection: MockConnection) {
        id = connection.id
        displayName = connection.displayName
        host = connection.host
        protocolName = connection.protocolName
        speedLabel = connection.speedLabel
        isConnected = connection.state.isConnected
        canReconnect = connection.canConnect
        canDisconnect = connection.canDisconnect
    }
}
