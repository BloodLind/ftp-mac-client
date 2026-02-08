import Foundation
import SwiftUI

protocol ViewModel : ObservableObject {

}

@MainActor
protocol NavigableViewModel: ViewModel {
    var navigation: NavigationPresenter { get }
}

@MainActor
class NavigableResultViewModel<Result> : NavigableViewModel{
    var navigation: any NavigationPresenter
    let cancelResult: Result

    init(cancelResult: Result, navigation: any NavigationPresenter) {
        self.cancelResult = cancelResult
        self.navigation = navigation
    }

    func close(_ result: Result) {
        navigation.close(self, result)
    }
}

protocol NavigableView: View {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get }
    var navigation: NavigationPresenter { get }
    init(viewModel: ViewModelType, navigation: NavigationPresenter)
    nonisolated static func register(in registry: inout NavigationViewRegistry)
}
