import Foundation
import UIKit

struct DriveItem: Codable, Hashable {
    var id: String
    var name: String
    var path: String
    var isDirectory: Bool
    var size: Int? = nil
    var extras: [String: String]? = nil
}

extension DriveItem {
    
    var icon: UIImage? {
        if isDirectory {
            return UIImage(systemName: "folder")
        } else if isVideo {
            return UIImage(systemName: "film")
        } else {
            return UIImage(systemName: "doc")
        }
    }
    
    var isVideo: Bool {
        //let supportedVideoExtension = ["mp4", "mkv", "mov", "avi", "flv", "ts"]
        let supportedVideoExtension = ["mp4", "mov"]
        for ext in supportedVideoExtension {
            if name.lowercased().hasSuffix(ext) {
                return true
            }
        }
        return false
    }
}

extension Encodable {
    var json: String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

