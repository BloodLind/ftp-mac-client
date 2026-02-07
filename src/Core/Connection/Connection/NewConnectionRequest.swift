import Foundation

enum ConnectionProtocolType: String, CaseIterable, Identifiable {
    case sftp = "SFTP"
    case ftp = "FTP"
    case ftps = "FTPS"
    case s3 = "S3"
    case smb = "SMB"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sftp:
            return "SFTP (SSH)"
        case .ftp:
            return "FTP"
        case .ftps:
            return "FTPS"
        case .s3:
            return "S3 Bucket"
        case .smb:
            return "SMB"
        }
    }

    var defaultPort: Int {
        switch self {
        case .sftp:
            return 22
        case .ftp:
            return 21
        case .ftps:
            return 990
        case .s3:
            return 443
        case .smb:
            return 445
        }
    }
}

struct NewConnectionRequest {
    let displayName: String
    let host: String
    let port: Int
    let username: String?
    let password: String?
    let protocolType: ConnectionProtocolType
    let saveConnection: Bool
}
