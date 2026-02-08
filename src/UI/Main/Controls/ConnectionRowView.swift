import AppKit
import Foundation
import SwiftUI

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
