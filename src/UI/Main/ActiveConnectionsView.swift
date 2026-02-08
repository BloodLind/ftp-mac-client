import SwiftUI

struct ActiveConnectionsView: View {
    let connections: [ConnectionRowModel]
    let onReconnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ConnectionsTableHeaderView()
            Divider()
            if connections.isEmpty {
                EmptyStateView(
                    title: "No Active Connections",
                    subtitle: "Add a connection from the footer to get started."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(connections) { connection in
                            ConnectionRowView(
                                connection: connection,
                                onReconnect: onReconnect,
                                onDisconnect: onDisconnect
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

struct ActiveConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveConnectionsView(
            connections: MainViewModel(settingsViewModel: SettingsViewModel(), navigation: NoopNavigationPresenter()).connections,
            onReconnect: { _ in },
            onDisconnect: { _ in }
        )
        .frame(width: 700, height: 400)
    }
}
