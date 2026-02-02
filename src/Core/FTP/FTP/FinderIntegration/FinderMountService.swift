import Foundation

protocol FinderMountService {
    func mountVolume(name: String, adapter: FTPAdapter) throws
    func unmountVolume(name: String) throws
}
