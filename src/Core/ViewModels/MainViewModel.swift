import Foundation


@MainActor
final class MainViewModel: NavigableViewModel {
    var navigation: any NavigationPresenter

    @Published var selection: MainSection = .activeConnections
    @Published private(set) var connections: [ConnectionRowModel] = []
    @Published private(set) var savedServers: [ConnectionRowModel] = []
    @Published private(set) var historyItems: [HistoryItemModel] = []

    let settingsViewModel: SettingsViewModel

    private let store: MockConnectionStore

    init(
        store: MockConnectionStore = .shared,
        settingsViewModel: SettingsViewModel,
        navigation: any NavigationPresenter
    ) {
        self.store = store
        self.settingsViewModel = settingsViewModel
        self.navigation = navigation
        refresh()
        seedHistory()
        
    }

    var activeCount: Int {
        connections.filter { $0.isConnected }.count
    }

    var savedCount: Int {
        savedServers.count
    }

    func refresh() {
        let rows = store.listConnections().map(ConnectionRowModel.init)
        connections = rows
        savedServers = rows
    }

    func reconnect(id: UUID) {
        store.connect(id: id)
        refresh()
    }

    func disconnect(id: UUID) {
        store.disconnect(id: id)
        refresh()
    }

    func addConnection(_ request: NewConnectionRequest) {
        store.addConnection(request: request)
        refresh()
    }

    private func seedHistory() {
        historyItems = [
            HistoryItemModel(
                id: UUID(),
                title: "Connected",
                detail: "Production Server",
                timestamp: "2m ago"
            ),
            HistoryItemModel(
                id: UUID(),
                title: "Disconnected",
                detail: "Legacy Share",
                timestamp: "1h ago"
            )
        ]
    }
}
