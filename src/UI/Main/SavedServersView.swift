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
        SavedServersView(servers: MainViewModel().savedServers, onConnect: { _ in })
            .frame(width: 700, height: 400)
    }
}

struct SavedServerRowView: View {
    let server: ConnectionRowModel
    let onConnect: (UUID) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "externaldrive")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(server.displayName)
                    .font(.callout.weight(.medium))
                Text(server.host)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(server.protocolName)
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Connect") {
                onConnect(server.id)
            }
            .buttonStyle(.bordered)
            .disabled(!server.canReconnect)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
