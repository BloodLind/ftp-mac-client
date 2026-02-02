import Foundation

protocol FTPAdapter {
    func connect(config: FTPConfig) throws
    func disconnect() throws
}

struct FTPConfig {
    let host: String
    let port: Int
    let username: String
    let password: String
    let protocolType: FTPProtocolType
}

enum FTPProtocolType: String {
    case ftp
    case ftps
    case sftp
}
