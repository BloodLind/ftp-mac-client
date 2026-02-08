import AppKit
import SwiftUI

struct SavedServersView: View {
    let servers: [ConnectionRowModel]
    let onConnect: (UUID) -> Void

    var body: some View {
        if servers.isEmpty {
            EmptyStateView(
                title: "No Saved Servers",
                subtitle: "Create a connection to see saved servers here."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(servers) { server in
                        SavedServerRowView(server: server, onConnect: onConnect)
                    }
                }
                .padding(16)
            }
        }
    }
}

struct SavedServersView_Previews: PreviewProvider {
    static var previews: some View {
        SavedServersView(servers: MainViewModel(settingsViewModel: SettingsViewModel(), navigation: NoopNavigationPresenter()).savedServers, onConnect: { _ in })
            .frame(width: 700, height: 400)
    }
}
