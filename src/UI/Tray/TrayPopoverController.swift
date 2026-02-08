import AppKit
import SwiftUI

@MainActor
final class TrayPopoverController: NSObject, NSPopoverDelegate {
    private let popover: NSPopover
    private let hostingController: NSHostingController<TrayView>
    private var popoverWindowObservers: [NSObjectProtocol] = []
    private let width: CGFloat
    private let heightPadding: CGFloat

    init(
        viewModel: TrayViewModel,
        navigation: NavigationPresenter,
        width: CGFloat = 270,
        heightPadding: CGFloat = 8
    ) {
        self.width = width
        self.heightPadding = heightPadding
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.appearance = NSApp.effectiveAppearance
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        self.popover = popover
        let hostingController = NSHostingController(rootView: TrayView(viewModel: viewModel, navigation: navigation))
        self.hostingController = hostingController
        super.init()
        popover.contentViewController = hostingController
        popover.delegate = self
    }

    var isShown: Bool {
        popover.isShown
    }

    func toggle(relativeTo button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            updatePopoverSize()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            attachPopoverWindowObservers()
            DispatchQueue.main.async { [weak self] in
                self?.updatePopoverSize()
                self?.attachPopoverWindowObservers()
            }
        }
    }

    private func updatePopoverSize() {
        hostingController.view.layoutSubtreeIfNeeded()
        let fittingSize = hostingController.view.fittingSize
        let height = max(1, fittingSize.height + heightPadding)
        popover.contentSize = NSSize(width: width, height: height)
    }

    func popoverDidShow(_ notification: Notification) {
        attachPopoverWindowObservers()
    }

    func popoverWillClose(_ notification: Notification) {
        clearPopoverWindowObservers()
    }

    private func attachPopoverWindowObservers() {
        clearPopoverWindowObservers()
        guard let window = popover.contentViewController?.view.window else { return }
        let resignKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.popover.performClose(nil)
        }
        let resignMainObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignMainNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.popover.performClose(nil)
        }
        popoverWindowObservers = [resignKeyObserver, resignMainObserver]
    }

    private func clearPopoverWindowObservers() {
        for observer in popoverWindowObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        popoverWindowObservers = []
    }

}
