import AppKit
import SwiftUI

@MainActor
final class TrayPopoverController {
    private(set) var popover: NSPopover

    init(rootView: some View, size: NSSize) {
        self.popover = TrayPopoverController.createPopoverControl(rootView: rootView, size: size)
    }

    private static func createPopoverControl(rootView: some View, size: NSSize) -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .transient
        // Hide the little arrow pointing to the status bar item
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        popover.contentSize = size
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: rootView)
        return popover
    }

    func toggle(relativeTo button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

