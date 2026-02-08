import AppKit

@MainActor
final class StatusBarItemController {
    private(set) var statusItem: NSStatusItem

    init(
        systemSymbolName: String,
        accessibilityDescription: String,
        action: Selector?,
        target: AnyObject?,
        menu: NSMenu? = nil
    ) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription, action: action, target: target)
        statusItem.menu = menu
    }

    private func configureButton(systemSymbolName: String, accessibilityDescription: String, action: Selector?, target: AnyObject?) {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
        button.image?.isTemplate = true
        button.action = action
        button.target = target
    }
}
