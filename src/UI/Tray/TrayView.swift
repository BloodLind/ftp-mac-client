import SwiftUI

struct TrayView: NavigableView {
    @StateObject var viewModel: TrayViewModel
    let navigation: NavigationPresenter

    init(viewModel: TrayViewModel, navigation: NavigationPresenter) {
        self.navigation = navigation
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    nonisolated static func register(in registry: inout NavigationViewRegistry) {
        registry.register(
            TrayViewModel.self,
            mode: .container(side: .leftPanel),
            title: "Tray"
        ) { viewModel, navigation in
            AnyView(TrayView(viewModel: viewModel, navigation: navigation))
        }
    }

    var body: some View {
        TrayMenuContainer {
            VStack(spacing: 6) {
                TrayServerSectionView(
                    servers: viewModel.servers,
                    onConnect: viewModel.connect,
                    onDisconnect: viewModel.disconnect
                )
                TrayMenuDivider()
                TrayMenuRow(
                    title: "Add New Connection...",
                    leadingSymbol: "plus",
                    shortcut: "⌘N",
                    action: viewModel.presentAddServer
                )
                TrayMenuRow(
                    title: "Open Manage Window",
                    leadingSymbol: "tablecells",
                    shortcut: "⌘M",
                    action: viewModel.openManageWindow
                )
                TrayMenuDivider()
                TrayMenuRow(
                    title: "Quit FTP Client",
                    leadingSymbol: nil,
                    shortcut: "⌘Q",
                    action: viewModel.quitApp
                )
            }
            .padding(6)
        }
        .frame(width: 270)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct TrayView_Previews: PreviewProvider {
    static var previews: some View {
        TrayView(viewModel: TrayViewModel.preview(), navigation: NoopNavigationPresenter())
    }
}

struct TrayMenuContainer<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15), radius: 18, x: 0, y: 8)
    }
}

struct TrayMenuDivider: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.08))
            .frame(height: 1)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
    }
}

struct TrayServerSectionView: View {
    let servers: [TrayViewModel.ServerItem]
    let onConnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        let rowHeight: CGFloat = 24
        let rowSpacing: CGFloat = 2
        let sectionPadding: CGFloat = 4
        let sizeOffset: CGFloat = 6
        let maxVisibleRows: CGFloat = 6
        let visibleRows = CGFloat(min(servers.count, Int(maxVisibleRows)))
        let visibleSpacing = max(visibleRows - 1, 0)
        let visibleHeight = (visibleRows * rowHeight) + (visibleSpacing * rowSpacing) + (sectionPadding * 2) + sizeOffset
        let maxSpacing = max(maxVisibleRows - 1, 0)
        let maxHeight = (maxVisibleRows * rowHeight) + (maxSpacing * rowSpacing) + (sectionPadding * 2) + sizeOffset
        if servers.isEmpty {
            VStack(spacing: rowSpacing) {
                TrayMenuRow(
                    title: "No mounted connections",
                    leadingSymbol: "circle",
                    shortcut: nil,
                    action: nil
                )
            }
            .padding(.vertical, sectionPadding)
            .opacity(0.6)
        } else {
            ScrollView {
                VStack(spacing: rowSpacing) {
                    ForEach(servers) { server in
                        TrayServerRowView(
                            server: server,
                            onConnect: onConnect,
                            onDisconnect: onDisconnect
                        )
                    }
                }
                .padding(.vertical, sectionPadding)
            }
            .frame(height: visibleHeight)
            .frame(maxHeight: maxHeight)
        }
    }
}

struct TrayServerRowView: View {
    let server: TrayViewModel.ServerItem
    let onConnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        TrayMenuRow(
            title: server.displayName,
            leadingSymbol: server.canDisconnect ? "checkmark" : nil,
            shortcut: nil,
            action: nil,
            trailingSymbol: server.canDisconnect ? "eject" : "arrow.up.right",
            trailingAction: server.canDisconnect ? { onDisconnect(server.id) } : { onConnect(server.id) },
            trailingEnabled: server.canDisconnect || server.canConnect
        )
    }
}

struct TrayMenuRow: View {
    let title: String
    let leadingSymbol: String?
    let shortcut: String?
    let action: (() -> Void)?
    let trailingSymbol: String?
    let trailingAction: (() -> Void)?
    let trailingEnabled: Bool

    @State private var isHovering = false

    init(
        title: String,
        leadingSymbol: String?,
        shortcut: String?,
        action: (() -> Void)?,
        trailingSymbol: String? = nil,
        trailingAction: (() -> Void)? = nil,
        trailingEnabled: Bool = true
    ) {
        self.title = title
        self.leadingSymbol = leadingSymbol
        self.shortcut = shortcut
        self.action = action
        self.trailingSymbol = trailingSymbol
        self.trailingAction = trailingAction
        self.trailingEnabled = trailingEnabled
    }

    var body: some View {
        let rowContent = TrayMenuRowContent(
            title: title,
            leadingSymbol: leadingSymbol,
            shortcut: shortcut,
            trailingSymbol: trailingSymbol,
            trailingAction: trailingAction,
            trailingEnabled: trailingEnabled,
            isHighlighted: isHovering
        )

        Group {
            if let action {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
        .onHover { isHovering = $0 }
        .background(isHovering ? Color.accentColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .padding(.horizontal, 4)
    }
}

struct TrayMenuRowContent: View {
    let title: String
    let leadingSymbol: String?
    let shortcut: String?
    let trailingSymbol: String?
    let trailingAction: (() -> Void)?
    let trailingEnabled: Bool
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 8) {
            TrayMenuIcon(symbol: leadingSymbol, isHighlighted: isHighlighted)
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isHighlighted ? .white : .primary)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let trailingSymbol {
                TrayMenuTrailingButton(
                    symbol: trailingSymbol,
                    isHighlighted: isHighlighted,
                    isEnabled: trailingEnabled,
                    action: trailingAction
                )
            }
            if let shortcut {
                Text(shortcut)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isHighlighted ? Color.white.opacity(0.85) : .secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct TrayMenuIcon: View {
    let symbol: String?
    let isHighlighted: Bool

    var body: some View {
        ZStack {
            Color.clear
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isHighlighted ? .white : .primary)
            }
        }
        .frame(width: 16, height: 16)
    }
}

struct TrayMenuTrailingButton: View {
    let symbol: String
    let isHighlighted: Bool
    let isEnabled: Bool
    let action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isHighlighted ? .white : .secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            } else {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isHighlighted ? .white : .secondary)
            }
        }
    }
}
