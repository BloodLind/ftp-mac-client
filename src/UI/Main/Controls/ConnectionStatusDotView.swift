import SwiftUI

struct ConnectionStatusDotView: View {
    let isConnected: Bool

    var body: some View {
        Circle()
            .fill(isConnected ? Color.green : Color.gray)
            .frame(width: 8, height: 8)
    }
}
