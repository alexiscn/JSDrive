import JavaScriptCore
import Foundation

extension JSContext {
    subscript(key: String) -> Any {
        get { return self.objectForKeyedSubscript(key) as Any }
        set{ self.setObject(newValue, forKeyedSubscript: key as NSCopying & NSObjectProtocol) }
    }
}

extension JSContext {
    
    private static var intervals: [Int: Timer] = [:]
    
    static var plus:JSContext? {
        let jsMachine = JSVirtualMachine()
        guard let jsContext = JSContext(virtualMachine: jsMachine) else {
            return nil
        }
        
        jsContext.evaluateScript("""
            Error.prototype.isError = () => {return true}
        """)
        jsContext["console"] = JSConsole.self
        jsContext["Promise"] = JSPromise.self
        jsContext["$http"] = JSHttp.self
        jsContext["$prefs"] = JSPrefs.self
        
        let setInterval: @convention(block) (Any) -> (Int) = { (any: Any) in
            return self.setInterval(context: JSContext.current(), repeats: true)
        }
        jsContext["setInterval"] = unsafeBitCast(setInterval, to: JSValue.self)

        let setTimeout: @convention(block) (Any) -> (Int) = { (any: Any) in
            return self.setInterval(context: JSContext.current(), repeats: false)
        }
        jsContext["setTimeout"] = unsafeBitCast(setTimeout, to: JSValue.self)
        
        let clearInterval: @convention(block) (JavaScriptCore.JSValue) -> () = { (value: JSValue) in
            self.clearInterval(context: JSContext.current(), tag: Int(value.toInt32()))
        }
        jsContext["clearInterval"] = unsafeBitCast(clearInterval, to: JSValue.self)
        jsContext["clearTimeout"] = unsafeBitCast(clearInterval, to: JSValue.self)
        return jsContext
    }
    
    private class func setInterval(context: JSContext, repeats: Bool) -> Int {
        guard var args = JSContext.currentArguments() as? [JSValue] else {
            return 0
        }
        let function = args.removeFirst()
        let interval = args.removeFirst().toDouble() / 1000
        let tag = UUID().hashValue
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { (timer) in
            function.call(withArguments: args)
        }
        self.intervals[tag] = timer
        return tag
    }
    
    private class func clearInterval(context: JSContext, tag: Int) {
        self.intervals[tag]?.invalidate()
        self.intervals[tag] = nil
    }
}
