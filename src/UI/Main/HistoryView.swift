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
