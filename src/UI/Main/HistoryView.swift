import AppKit
import SwiftUI

struct HistoryView: View {
    let items: [HistoryItemModel]

    var body: some View {
        if items.isEmpty {
            EmptyStateView(
                title: "No Recent Activity",
                subtitle: "Connections and disconnects will appear here."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        HistoryRowView(item: item)
                    }
                }
                .padding(16)
            }
        }
    }
}

struct HistoryRowView: View {
    let item: HistoryItemModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.callout.weight(.medium))
                Text(item.detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(item.timestamp)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
