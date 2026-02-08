import AppKit
import SwiftUI

@MainActor
protocol RootNavigationContainer: AnyObject {
    func push(_ view: AnyView, for id: ObjectIdentifier, on side: RootContainerSide)
    func close(from id: ObjectIdentifier, on side: RootContainerSide)
}

@MainActor
final class RegistryNavigationPresenter: NavigationPresenter {
    private final class ResultNavigationSession {
        let window: NSWindow
        let resolve: (Any) -> Void
        var closeObserver: NSObjectProtocol?
        var isCompleted = false

        init(window: NSWindow, resolve: @escaping (Any) -> Void) {
            self.window = window
            self.resolve = resolve
        }
    }

    private let registry: NavigationViewRegistry
    private let rootContainer: RootNavigationContainer
    private var resultSessions: [ObjectIdentifier: ResultNavigationSession] = [:]

    init(
        registry: NavigationViewRegistry,
        rootContainer: RootNavigationContainer
    ) {
        self.registry = registry
        self.rootContainer = rootContainer
    }

    func navigate(_ viewModel: any ViewModel) {
        guard let relation = registry.resolve(for: viewModel, navigation: self) else {
            return
        }

        switch relation.mode {
        case .dedicated:
            presentDedicatedWindow(for: relation)
        case .container(let side):
            rootContainer.push(
                relation.view,
                for: ObjectIdentifier(viewModel),
                on: side
            )
        }
    }

    func navigate<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM) async -> Result {
        guard let relation = registry.resolve(for: viewModel, navigation: self) else {
            return viewModel.cancelResult
        }

        switch relation.mode {
        case .dedicated:
            return await presentResultWindow(for: viewModel, relation: relation)
        case .container:
            assertionFailure("Only dedicated presentations can return navigation results.")
            return viewModel.cancelResult
        }
    }

    func close<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM, _ result: Result) {
        if completeSession(
            id: ObjectIdentifier(viewModel),
            result: result,
            closeWindow: true
        ) {
            return
        }

        guard let relation = registry.resolve(for: viewModel, navigation: self) else {
            return
        }

        if case .container(let side) = relation.mode {
            rootContainer.close(from: ObjectIdentifier(viewModel), on: side)
        }
    }

    private func presentDedicatedWindow(for relation: NavigationViewRelation) {
        let window = NSWindow(contentViewController: NSHostingController(rootView: relation.view))
        window.styleMask = [.titled, .closable]
        window.title = relation.title
        window.isReleasedWhenClosed = true
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func presentResultWindow<VM: NavigableResultViewModel<Result>, Result>(
        for viewModel: VM,
        relation: NavigationViewRelation
    ) async -> Result {
        let window = NSWindow(contentViewController: NSHostingController(rootView: relation.view))
        window.styleMask = [.titled, .closable]
        window.title = relation.title
        window.isReleasedWhenClosed = false
        window.center()

        let cancelResult = viewModel.cancelResult
        let viewModelID = ObjectIdentifier(viewModel)

        return await withCheckedContinuation(isolation: MainActor.shared) { continuation in
            let session = ResultNavigationSession(
                window: window,
                resolve: { result in
                    guard let typedResult = result as? Result else {
                        continuation.resume(returning: cancelResult)
                        return
                    }
                    continuation.resume(returning: typedResult)
                }
            )
            resultSessions[viewModelID] = session

            session.closeObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.completeSession(
                        id: viewModelID,
                        result: cancelResult,
                        closeWindow: false
                    )
                }
            }

            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }

    private func completeSession<Result>(
        id: ObjectIdentifier,
        result: Result,
        closeWindow: Bool
    ) -> Bool {
        guard let session = resultSessions[id], !session.isCompleted else {
            return false
        }

        session.isCompleted = true

        if let closeObserver = session.closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
        }

        resultSessions[id] = nil

        if closeWindow {
            session.window.close()
        }

        session.resolve(result)
        return true
    }
}
