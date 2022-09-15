import Foundation
import JavaScriptCore

enum DriveEngineError: Error {
    case loginResponseInvalid
    case lisFolderResponseInvalid
}

class DriveEngine {
    
    let context: JSContext
    
    init(script: String) {
        self.context = JSContext.plus!
        self.context.exceptionHandler = { cxt, exception in
            print("JS Error: \(String(describing: exception))")
        }
        self.context.evaluateScript(script)
    }
    
    func login() async throws -> DriveItem {
        try await withUnsafeThrowingContinuation { continuation in
            let done:@convention(block) (Any?) -> Void = { param in
                if let obj = param as? [String: Any] {
                    let id = (obj["id"] as? String) ?? ""
                    let name = (obj["name"] as? String) ?? "root"
                    let path = (obj["path"] as? String) ?? "/"
                    let root = DriveItem(id: id, name: name, path: path, isDirectory: true)
                    continuation.resume(returning: root)
                } else {
                    continuation.resume(throwing: DriveEngineError.loginResponseInvalid)
                }
            }
            self.context["$done"] = unsafeBitCast(done, to: JSValue.self)
            self.context.evaluateScript("login()")
        }
    }
    
    func listFolder(at directory: DriveItem) async throws -> [DriveItem] {
        try await withUnsafeThrowingContinuation { continuation in
            let done:@convention(block) (Any?) -> Void = { param in
                if let string = param as? String, let data = string.data(using: .utf8) {
                    do {
                        let files = try JSONDecoder().decode([DriveItem].self, from: data)
                        continuation.resume(returning: files)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else if let array = param as? NSArray {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: array)
                        let files = try JSONDecoder().decode([DriveItem].self, from: data)
                        continuation.resume(returning: files)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: DriveEngineError.lisFolderResponseInvalid)
                }
            }
            self.context["$done"] = unsafeBitCast(done, to: JSValue.self)
            
            let script = String(format: "list('%@')", directory.json)
            self.context.evaluateScript(script)
        }
    }
    
    func getPlaybackInfo(of videoItem: DriveItem) async throws -> URLRequest {
        try await withUnsafeThrowingContinuation { continuation in
            let done:@convention(block) (Any?) -> Any? = { param in
                if let dict = param as? [String: Any] {
                    if let urlString = (dict["url"] as? String), let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        continuation.resume(returning: request)
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: -1))
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1))
                }
                return nil
            }
            self.context["$done"] = unsafeBitCast(done, to: JSValue.self)
            
            let script = String(format: "videoInfo('%@')", videoItem.json)
            self.context.evaluateScript(script)
        }
    }
}
