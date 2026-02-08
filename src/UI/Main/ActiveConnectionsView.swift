import AppKit
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

struct ConnectionsTableHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("Status")
                .frame(width: 60, alignment: .leading)
            Text("Server Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Protocol")
                .frame(width: 120, alignment: .leading)
            Text("Speed / Action")
                .frame(width: 180, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct ConnectionStatusDotView: View {
    let isConnected: Bool

    var body: some View {
        Circle()
            .fill(isConnected ? Color.green : Color.gray)
            .frame(width: 8, height: 8)
    }
}

struct ConnectionSpeedBadgeView: View {
    let speedLabel: String?

    var body: some View {
        if let speedLabel {
            Text(speedLabel)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .foregroundColor(.green)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        } else {
            Text("-")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ConnectionActionButtonView: View {
    let systemName: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(.bordered)
        .disabled(!isEnabled)
    }
}

struct ConnectionRowActionsView: View {
    let connection: ConnectionRowModel
    let onReconnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ConnectionSpeedBadgeView(speedLabel: connection.speedLabel)
            ConnectionActionButtonView(
                systemName: "arrow.clockwise",
                isEnabled: connection.canReconnect,
                action: { onReconnect(connection.id) }
            )
            ConnectionActionButtonView(
                systemName: "eject",
                isEnabled: connection.canDisconnect,
                action: { onDisconnect(connection.id) }
            )
        }
    }
}

struct ConnectionRowView: View {
    let connection: ConnectionRowModel
    let onReconnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ConnectionStatusDotView(isConnected: connection.isConnected)
                .frame(width: 60, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(connection.displayName)
                    .font(.callout.weight(.medium))
                Text(connection.host)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(connection.protocolName)
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            ConnectionRowActionsView(
                connection: connection,
                onReconnect: onReconnect,
                onDisconnect: onDisconnect
            )
            .frame(width: 180, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
