import Foundation
import SwiftUI

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
