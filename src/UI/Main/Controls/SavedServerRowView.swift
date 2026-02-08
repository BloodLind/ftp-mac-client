import AppKit
import Foundation
import SwiftUI

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
