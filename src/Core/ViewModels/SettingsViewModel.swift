import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var launchAtLogin: Bool
    @Published var showInMenuBar: Bool
    @Published var defaultProtocol: ConnectionProtocolType
    @Published var autoReconnect: Bool

    init(
        launchAtLogin: Bool = true,
        showInMenuBar: Bool = true,
        defaultProtocol: ConnectionProtocolType = .sftp,
        autoReconnect: Bool = true
    ) {
        self.launchAtLogin = launchAtLogin
        self.showInMenuBar = showInMenuBar
        self.defaultProtocol = defaultProtocol
        self.autoReconnect = autoReconnect
    }
}
