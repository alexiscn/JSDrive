import Foundation

struct DriveScript: Hashable {
    
    let url: URL
    
    var name: String { return url.lastPathComponent }
}
