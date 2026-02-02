import Foundation

protocol CredentialStore {
    func savePassword(_ password: String, for serverId: UUID) throws
    func loadPassword(for serverId: UUID) throws -> String
    func deletePassword(for serverId: UUID) throws
}
