import AppKit
import SwiftUI

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
