import AppKit
import SwiftUI

@MainActor
final class TrayPopoverController {
    private(set) var popover: NSPopover
    private let animationDuration: TimeInterval
    public var anchorYOffset: CGFloat = -9

    init(rootView: some View, size: NSSize, animationDuration: TimeInterval = 0.12, ) {
        self.popover = TrayPopoverController.createPopoverControl(rootView: rootView, size: size)
        self.animationDuration = animationDuration
    }

    private static func createPopoverControl(rootView: some View, size: NSSize) -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .transient
        // Hide the little arrow pointing to the status bar item
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        popover.contentSize = size
        popover.animates = false
        popover.appearance = NSApp.effectiveAppearance
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: rootView)
        return popover
    }

    func toggle(relativeTo button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            let anchorRect = button.bounds.offsetBy(dx: 0, dy: anchorYOffset)
            popover.show(relativeTo: anchorRect, of: button, preferredEdge: .minY)
            if let window = popover.contentViewController?.view.window {
                ControlAnimator.fadeIn(window: window, duration: animationDuration)
            }
        }
    }
}
