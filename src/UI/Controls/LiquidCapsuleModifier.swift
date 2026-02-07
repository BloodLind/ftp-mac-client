import SwiftUI

struct LiquidCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.buttonBorderShape(.capsule)
        } else {
            content
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
    }
}

extension View {
    func liquidCapsule() -> some View {
        modifier(LiquidCapsuleModifier())
    }
}
