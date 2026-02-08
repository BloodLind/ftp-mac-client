import SwiftUI

enum RootContainerSide {
    case leftPanel
    case mainView
}

enum NavigationPresentationMode {
    case dedicated
    case container(side: RootContainerSide)
}

struct NavigationViewRelation {
    let view: AnyView
    let mode: NavigationPresentationMode
    let title: String
}

struct NavigationViewRegistry {
    private struct Entry {
        let mode: NavigationPresentationMode
        let title: String
        let makeView: @MainActor (AnyObject, NavigationPresenter) -> AnyView?
    }

    private var entries: [ObjectIdentifier: Entry] = [:]
    private var orderedKeys: [ObjectIdentifier] = []

    mutating func register<VM: ViewModel>(
        _ viewModelType: VM.Type,
        mode: NavigationPresentationMode,
        title: String,
        factory: @escaping @MainActor (VM, NavigationPresenter) -> AnyView
    ) {
        let key = ObjectIdentifier(viewModelType)
        entries[key] = Entry(
            mode: mode,
            title: title,
            makeView: { object, navigation in
                guard let typedViewModel = object as? VM else {
                    return nil
                }
                return factory(typedViewModel, navigation)
            }
        )
        if !orderedKeys.contains(key) {
            orderedKeys.append(key)
        }
    }

    @MainActor
    func resolve(for viewModel: any ViewModel, navigation: NavigationPresenter) -> NavigationViewRelation? {
        let anyViewModel = viewModel as AnyObject
        let exactKey = ObjectIdentifier(type(of: viewModel))

        if let entry = entries[exactKey], let view = entry.makeView(anyViewModel, navigation) {
            return NavigationViewRelation(view: view, mode: entry.mode, title: entry.title)
        }

        for key in orderedKeys where key != exactKey {
            guard let entry = entries[key], let view = entry.makeView(anyViewModel, navigation) else {
                continue
            }
            return NavigationViewRelation(view: view, mode: entry.mode, title: entry.title)
        }
        return nil
    }
}
