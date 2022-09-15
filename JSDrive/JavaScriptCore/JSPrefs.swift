import Foundation
import JavaScriptCore

@objc protocol JSPrefsExports: JSExport {
    static func getValueForKey(_ key: String) -> Any?
    static func setValueForKey(_ value: String, _ key: String)
    static func removeValueForKey(_ key: String)
}

class JSPrefs: NSObject, JSPrefsExports {
    
    class func getValueForKey(_ key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    class func setValueForKey(_ value: String, _ key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    static func removeValueForKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
