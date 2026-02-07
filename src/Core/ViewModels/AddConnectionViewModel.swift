import Foundation

@MainActor
final class AddConnectionViewModel: ObservableObject {
    @Published var selectedProtocol: ConnectionProtocolType
    @Published var host: String
    @Published var port: String
    @Published var username: String
    @Published var password: String
    @Published var connectionName: String
    @Published var saveConnection: Bool
    @Published var validationMessage: String?

    private let onCancel: () -> Void
    private let onConnect: (NewConnectionRequest) -> Void

    init(
        selectedProtocol: ConnectionProtocolType = .sftp,
        host: String = "",
        port: String = "",
        username: String = "",
        password: String = "",
        connectionName: String = "",
        saveConnection: Bool = true,
        onCancel: @escaping () -> Void,
        onConnect: @escaping (NewConnectionRequest) -> Void
    ) {
        self.selectedProtocol = selectedProtocol
        self.host = host
        self.port = port.isEmpty ? String(selectedProtocol.defaultPort) : port
        self.username = username
        self.password = password
        self.connectionName = connectionName
        self.saveConnection = saveConnection
        self.onCancel = onCancel
        self.onConnect = onConnect
    }

    var canConnect: Bool {
        !host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Int(port) != nil
    }

    func selectProtocol(_ protocolType: ConnectionProtocolType) {
        selectedProtocol = protocolType
        port = String(protocolType.defaultPort)
    }

    func cancel() {
        onCancel()
    }

    func connect() {
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHost.isEmpty else {
            validationMessage = "Host is required."
            return
        }
        guard let portValue = Int(port) else {
            validationMessage = "Port must be a number."
            return
        }

        validationMessage = nil
        let request = NewConnectionRequest(
            displayName: connectionName.trimmingCharacters(in: .whitespacesAndNewlines),
            host: trimmedHost,
            port: portValue,
            username: username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : username,
            password: password.isEmpty ? nil : password,
            protocolType: selectedProtocol,
            saveConnection: saveConnection
        )
        onConnect(request)
    }
}
