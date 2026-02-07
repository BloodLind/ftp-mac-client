import Foundation

enum MainSection: String, CaseIterable, Identifiable {
    case activeConnections = "Active Connections"
    case savedServers = "Saved Servers"
    case history = "History"
    case settings = "Settings"

    var id: String { rawValue }

    var title: String { rawValue }

    var systemImageName: String {
        switch self {
        case .activeConnections:
            return "antenna.radiowaves.left.and.right"
        case .savedServers:
            return "bookmark"
        case .history:
            return "clock"
        case .settings:
            return "gearshape"
        }
    }
}
