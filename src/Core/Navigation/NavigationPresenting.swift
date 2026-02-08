import Foundation

@MainActor
protocol NavigationPresenter: AnyObject {
    func navigate(_ viewModel: any ViewModel)
    func navigate<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM) async -> Result
    func close<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM, _ result: Result)
}

@MainActor
final class NoopNavigationPresenter: NavigationPresenter {
    func navigate(_ viewModel: any ViewModel) {}

    func navigate<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM) async -> Result {
        viewModel.cancelResult
    }

    func close<VM: NavigableResultViewModel<Result>, Result>(_ viewModel: VM, _ result: Result) {}
}

enum GlobalNavigation {
    @MainActor static var presenter: NavigationPresenter = NoopNavigationPresenter()
}
