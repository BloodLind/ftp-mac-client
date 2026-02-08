import AppKit
import SwiftUI

struct MainRootView: NavigableView {
    @MainActor
    final class RootContainer: ObservableObject, RootNavigationContainer {
        private struct StackItem {
            let id: ObjectIdentifier
            let view: AnyView
        }

        private var leftPanelItems: [StackItem] = []
        private var mainViewItems: [StackItem] = []

        @Published private(set) var leftPanelView: AnyView?
        @Published private(set) var mainView: AnyView?

        func push(_ view: AnyView, for id: ObjectIdentifier, on side: RootContainerSide) {
            update(side: side) { items in
                if let existingIndex = items.firstIndex(where: { $0.id == id }) {
                    items.removeSubrange(existingIndex...)
                }
                items.append(StackItem(id: id, view: view))
            }
        }

        func close(from id: ObjectIdentifier, on side: RootContainerSide) {
            update(side: side) { items in
                guard let index = items.firstIndex(where: { $0.id == id }) else {
                    return
                }
                items.removeSubrange(index...)
            }
        }

        private func update(side: RootContainerSide, mutate: (inout [StackItem]) -> Void) {
            switch side {
            case .leftPanel:
                mutate(&leftPanelItems)
                leftPanelView = leftPanelItems.last?.view
            case .mainView:
                mutate(&mainViewItems)
                mainView = mainViewItems.last?.view
            }
        }
    }

    @MainActor static let rootContainer = RootContainer()

    @StateObject var viewModel: MainViewModel
    @ObservedObject private var rootNavigationContainer = MainRootView.rootContainer
    let navigation: NavigationPresenter

    init(viewModel: MainViewModel, navigation: NavigationPresenter) {
        self.navigation = navigation
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    nonisolated static func register(in registry: inout NavigationViewRegistry) {
        registry.register(
            MainViewModel.self,
            mode: .dedicated,
            title: "Manage Connections"
        ) { viewModel, navigation in
            AnyView(MainRootView(viewModel: viewModel, navigation: navigation))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            if let leftPanelView = rootNavigationContainer.leftPanelView {
                leftPanelView
                    .frame(width: 240)
            } else {
                MainSidebarView(selection: $viewModel.selection)
            }

            if let mainView = rootNavigationContainer.mainView {
                mainView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    MainHeaderView(title: viewModel.selection.title)
                    Divider()
                    MainContentView(
                        selection: viewModel.selection,
                        connections: viewModel.connections,
                        savedServers: viewModel.savedServers,
                        historyItems: viewModel.historyItems,
                        settingsViewModel: viewModel.settingsViewModel,
                        navigation: navigation,
                        onReconnect: viewModel.reconnect,
                        onDisconnect: viewModel.disconnect
                    )
                    Divider()
                    MainFooterView(
                        activeCount: viewModel.activeCount,
                        savedCount: viewModel.savedCount,
                        onAddConnection: presentAddConnection,
                        onQuit: { NSApplication.shared.terminate(nil) }
                    )
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    private func presentAddConnection() {
        Task { @MainActor in
            let addConnectionViewModel = AddConnectionViewModel(navigationPresenter: navigation)
            let result = await navigation.navigate(addConnectionViewModel)
            if case .connect(let request) = result {
                viewModel.addConnection(request)
            }
        }
    }
}

struct MainRootView_Previews: PreviewProvider {
    static var previews: some View {
        MainRootView(
            viewModel: MainViewModel(settingsViewModel: SettingsViewModel(), navigation: NoopNavigationPresenter()),
            navigation: NoopNavigationPresenter()
        )
            .frame(width: 900, height: 600)
    }
}

struct MainSidebarView: View {
    @Binding var selection: MainSection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MainSidebarSectionHeaderView(title: "Library")
            VStack(spacing: 6) {
                ForEach([MainSection.activeConnections, .savedServers, .history]) { section in
                    MainSidebarItemView(
                        section: section,
                        isSelected: selection == section,
                        onSelect: { selection = section }
                    )
                }
            }
            Spacer()
            MainSidebarItemView(
                section: .settings,
                isSelected: selection == .settings,
                onSelect: { selection = .settings }
            )
        }
        .padding(16)
        .frame(width: 240)
        .background(.ultraThinMaterial)
    }
}

struct MainSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        MainSidebarView(selection: .constant(.activeConnections))
            .frame(height: 600)
    }
}

struct MainSidebarItemView: View {
    let section: MainSection
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: section.systemImageName)
                    .font(.system(size: 14, weight: .semibold))
                Text(section.title)
                    .font(.callout.weight(.medium))
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct MainSidebarItemView_Previews: PreviewProvider {
    static var previews: some View {
        MainSidebarItemView(section: .activeConnections, isSelected: true, onSelect: {})
            .padding()
    }
}

struct MainSidebarSectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 6)
    }
}

struct MainSidebarSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MainSidebarSectionHeaderView(title: "Library")
            .padding()
    }
}

struct MainHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

struct MainHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MainHeaderView(title: "Active Connections")
            .padding()
    }
}

struct MainContentView: View {
    let selection: MainSection
    let connections: [ConnectionRowModel]
    let savedServers: [ConnectionRowModel]
    let historyItems: [HistoryItemModel]
    @ObservedObject var settingsViewModel: SettingsViewModel
    let navigation: NavigationPresenter
    let onReconnect: (UUID) -> Void
    let onDisconnect: (UUID) -> Void

    var body: some View {
        Group {
            switch selection {
            case .activeConnections:
                ActiveConnectionsView(
                    connections: connections,
                    onReconnect: onReconnect,
                    onDisconnect: onDisconnect
                )
            case .savedServers:
                SavedServersView(servers: savedServers, onConnect: onReconnect)
            case .history:
                HistoryView(items: historyItems)
            case .settings:
                SettingsView(viewModel: settingsViewModel, navigation: navigation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(
            selection: .activeConnections,
            connections: MainViewModel(settingsViewModel: SettingsViewModel(), navigation: NoopNavigationPresenter()).connections,
            savedServers: MainViewModel(settingsViewModel: SettingsViewModel(),navigation: NoopNavigationPresenter()).savedServers,
            historyItems: MainViewModel(settingsViewModel: SettingsViewModel(),navigation: NoopNavigationPresenter()).historyItems,
            settingsViewModel: SettingsViewModel(),
            navigation: NoopNavigationPresenter(),
            onReconnect: { _ in },
            onDisconnect: { _ in }
        )
        .frame(width: 700, height: 400)
    }
}

struct MainFooterView: View {
    let activeCount: Int
    let savedCount: Int
    let onAddConnection: () -> Void
    let onQuit: () -> Void

    var body: some View {
        HStack {
            Button("Quit", role: .destructive) {
                onQuit()
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("\(activeCount) Active | \(savedCount) Saved")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Add Connection") {
                onAddConnection()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

struct MainFooterView_Previews: PreviewProvider {
    static var previews: some View {
        MainFooterView(activeCount: 2, savedCount: 4, onAddConnection: {}, onQuit: {})
            .padding()
    }
}
