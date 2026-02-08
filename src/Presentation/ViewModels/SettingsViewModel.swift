import Foundation

final class SettingsViewModel: ViewModel {
    @Published var launchAtLogin: Bool
    @Published var showInMenuBar: Bool
    @Published var defaultProtocol: ConnectionProtocolType
    @Published var autoReconnect: Bool

    typealias Input = Void

    @MainActor
    static func prepare(with input: Void) -> SettingsViewModel {
        SettingsViewModel()
    }

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
