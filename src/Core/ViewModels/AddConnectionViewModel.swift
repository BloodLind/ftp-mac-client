import Foundation

enum AddConnectionResult {
    case cancelled
    case connect(NewConnectionRequest)
}

@MainActor
final class AddConnectionViewModel: NavigableResultViewModel<AddConnectionResult> {
    @Published var selectedProtocol: ConnectionProtocolType
    @Published var host: String
    @Published var port: String
    @Published var username: String
    @Published var password: String
    @Published var connectionName: String
    @Published var saveConnection: Bool
    @Published var validationMessage: String?

    typealias Input = Void
    
    init(
        selectedProtocol: ConnectionProtocolType = .sftp,
        host: String = "",
        port: String = "",
        username: String = "",
        password: String = "",
        connectionName: String = "",
        saveConnection: Bool = true,
        navigationPresenter: any NavigationPresenter
    ) {
        self.selectedProtocol = selectedProtocol
        self.host = host
        self.port = port.isEmpty ? String(selectedProtocol.defaultPort) : port
        self.username = username
        self.password = password
        self.connectionName = connectionName
        self.saveConnection = saveConnection
        super.init(cancelResult: .cancelled, navigation: navigationPresenter)
    }

    var canConnect: Bool {
        !host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Int(port) != nil
    }

    func selectProtocol(_ protocolType: ConnectionProtocolType) {
        selectedProtocol = protocolType
        port = String(protocolType.defaultPort)
    }

    func cancel() {
        close(.cancelled)
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
        close(.connect(request))
    }
}
