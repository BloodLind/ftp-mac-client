import AppKit

@MainActor
final class TrayMenuController: NSObject, NSMenuDelegate {
    let menu: NSMenu
    private let viewModel: TrayViewModel
    private enum Layout {
        static let serverListWidth: CGFloat = 260
        static let maxVisibleServerRows: Int = 6
    }

    init(viewModel: TrayViewModel) {
        self.viewModel = viewModel
        self.menu = NSMenu()
        super.init()
        menu.autoenablesItems = false
        menu.delegate = self
        rebuildMenu()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        viewModel.refresh()
        rebuildMenu()
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        let servers = viewModel.servers
        if servers.isEmpty {
            let emptyItem = NSMenuItem(title: "No mounted connections", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else {
            let item = makeScrollableServerListItem(for: servers)
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let addServer = NSMenuItem(
            title: "Add New Connection...",
            action: #selector(addServerAction),
            keyEquivalent: "n"
        )
        addServer.keyEquivalentModifierMask = [.command]
        addServer.target = self
        menu.addItem(addServer)

        let openManageWindow = NSMenuItem(
            title: "Open Manage Window",
            action: #selector(openManageWindowAction),
            keyEquivalent: "m"
        )
        openManageWindow.keyEquivalentModifierMask = [.command]
        openManageWindow.target = self
        menu.addItem(openManageWindow)

        menu.addItem(.separator())

        let quit = NSMenuItem(
            title: "Quit FTP Client",
            action: #selector(quitAction),
            keyEquivalent: "q"
        )
        quit.keyEquivalentModifierMask = [.command]
        quit.target = self
        menu.addItem(quit)
    }

    private func makeScrollableServerListItem(for servers: [TrayViewModel.ServerItem]) -> NSMenuItem {
        let item = NSMenuItem()
        item.view = TrayServerListMenuItemView(
            servers: servers,
            maxVisibleRows: Layout.maxVisibleServerRows,
            listWidth: Layout.serverListWidth
        ) { [weak self] server in
            self?.performServerAction(for: server)
        }
        // Disable default menu-item selection so button clicks do not dismiss the menu.
        item.isEnabled = false
        return item
    }

    private func performServerAction(for server: TrayViewModel.ServerItem) {
        if server.canDisconnect {
            viewModel.disconnect(serverId: server.id)
        } else if server.canConnect {
            viewModel.connect(serverId: server.id)
        }
        rebuildMenu()
    }

    @objc private func addServerAction() {
        viewModel.presentAddServer()
    }

    @objc private func openManageWindowAction() {
        viewModel.openManageWindow()
    }

    @objc private func quitAction() {
        viewModel.quitApp()
    }
}

@MainActor
private final class TrayServerListMenuItemView: NSView {
    private let listWidth: CGFloat
    private let listHeight: CGFloat

    init(
        servers: [TrayViewModel.ServerItem],
        maxVisibleRows: Int,
        listWidth: CGFloat,
        actionHandler: @escaping (TrayViewModel.ServerItem) -> Void
    ) {
        self.listWidth = listWidth
        let visibleRows = max(1, min(servers.count, maxVisibleRows))
        self.listHeight = CGFloat(visibleRows) * TrayServerMenuItemView.preferredHeight
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = servers.count > maxVisibleRows
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.verticalScrollElasticity = .none
        addSubview(scrollView)

        let rowWidth = listWidth - (scrollView.hasVerticalScroller ? 12 : 0)
        let totalHeight = CGFloat(servers.count) * TrayServerMenuItemView.preferredHeight
        let documentView = TrayMenuFlippedView(frame: NSRect(x: 0, y: 0, width: rowWidth, height: totalHeight))
        scrollView.documentView = documentView

        for (index, server) in servers.enumerated() {
            let actionSymbolName = server.canDisconnect ? "eject" : "arrow.up.right"
            let actionAccessibilityLabel = server.canDisconnect ? "Unmount" : "Connect"
            let actionEnabled = server.canConnect || server.canDisconnect
            let rowView = TrayServerMenuItemView(
                title: server.displayName,
                isConnected: server.canDisconnect,
                actionSymbolName: actionSymbolName,
                actionAccessibilityLabel: actionAccessibilityLabel,
                isActionEnabled: actionEnabled,
                rowWidth: rowWidth
            ) {
                actionHandler(server)
            }
            rowView.frame = NSRect(
                x: 0,
                y: CGFloat(index) * TrayServerMenuItemView.preferredHeight,
                width: rowWidth,
                height: TrayServerMenuItemView.preferredHeight
            )
            documentView.addSubview(rowView)
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(equalToConstant: listWidth),
            heightAnchor.constraint(equalToConstant: listHeight)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: listWidth, height: listHeight)
    }
}

@MainActor
private final class TrayMenuFlippedView: NSView {
    override var isFlipped: Bool { true }
}

@MainActor
private final class TrayServerMenuItemView: NSView {
    static let preferredHeight: CGFloat = 28

    private let actionHandler: () -> Void
    private let rowWidth: CGFloat

    init(
        title: String,
        isConnected: Bool,
        actionSymbolName: String,
        actionAccessibilityLabel: String,
        isActionEnabled: Bool,
        rowWidth: CGFloat = 260,
        actionHandler: @escaping () -> Void
    ) {
        self.actionHandler = actionHandler
        self.rowWidth = rowWidth
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.lineBreakMode = .byTruncatingTail

        let dotSymbolConfig = NSImage.SymbolConfiguration(pointSize: 7, weight: .regular)
        let dotImage = NSImage(
            systemSymbolName: "circle.fill",
            accessibilityDescription: isConnected ? "Connected" : "Disconnected"
        )?.withSymbolConfiguration(dotSymbolConfig)
        let statusDot = NSImageView(image: dotImage ?? NSImage())
        statusDot.contentTintColor = isConnected ? .systemGreen : .tertiaryLabelColor
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8)
        ])

        let labelsStack = NSStackView(views: [statusDot, titleLabel])
        labelsStack.orientation = .horizontal
        labelsStack.spacing = 6
        labelsStack.alignment = .centerY

        let actionIcon = NSImageView(
            image: NSImage(systemSymbolName: actionSymbolName, accessibilityDescription: actionAccessibilityLabel) ?? NSImage()
        )
        actionIcon.contentTintColor = .secondaryLabelColor
        actionIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionIcon.widthAnchor.constraint(equalToConstant: 14),
            actionIcon.heightAnchor.constraint(equalToConstant: 14)
        ])

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = NSStackView(views: [labelsStack, spacer, actionIcon])
        row.orientation = NSUserInterfaceLayoutOrientation.horizontal
        row.alignment = NSLayoutConstraint.Attribute.centerY
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            widthAnchor.constraint(equalToConstant: rowWidth)
        ])

        let rowButton = NSButton(title: "", target: self, action: #selector(didTapAction))
        rowButton.isBordered = false
        rowButton.isTransparent = true
        rowButton.imagePosition = .noImage
        rowButton.focusRingType = .none
        rowButton.isEnabled = isActionEnabled
        rowButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rowButton)

        NSLayoutConstraint.activate([
            rowButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowButton.topAnchor.constraint(equalTo: topAnchor),
            rowButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if !isActionEnabled {
            titleLabel.textColor = .disabledControlTextColor
            actionIcon.contentTintColor = .disabledControlTextColor
            statusDot.contentTintColor = .disabledControlTextColor
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: rowWidth, height: Self.preferredHeight)
    }

    @objc private func didTapAction() {
        actionHandler()
    }
}
