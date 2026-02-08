import SwiftUI

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
