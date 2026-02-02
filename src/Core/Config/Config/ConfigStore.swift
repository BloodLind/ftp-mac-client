import Foundation

protocol ConfigStore {
    func loadServers() -> [ServerConfig]
    func saveServers(_ servers: [ServerConfig])
}

struct ServerConfig: Identifiable {
    let id: UUID
    let displayName: String
    let host: String
    let port: Int
    let protocolType: String
    let username: String
}
