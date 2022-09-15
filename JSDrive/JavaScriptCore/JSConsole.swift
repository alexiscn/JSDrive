import Foundation
import JavaScriptCore

@objc protocol JSConsoleExports: JSExport {
    static func log(_ msg: String)
}

class JSConsole: NSObject, JSConsoleExports {
    class func log(_ msg: String) {
        print(msg)
    }
}
