import Foundation
import JavaScriptCore

@objc protocol JSPromiseExports: JSExport {
    func then(_ resolve: JSValue) -> JSPromise
    func `catch`(_ reject: JSValue) -> JSPromise
}

class JSPromise: NSObject {
    enum JSPromiseResult {
        case success(Any)
        case failure(Any)
    }
    private var result: JSPromiseResult? {
        didSet {result.map(report)}
    }
    private var callbacks: [(JSPromiseResult) -> Void] = []
    func observe(using callback: @escaping (JSPromiseResult) -> Void) {
        if let result = result {
            return callback(result)
        }
        
        callbacks.append(callback)
    }
    
    private func report(result: JSPromiseResult) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    convenience init(executor: @escaping (@escaping(Any)->Void, @escaping(Any)->Void) -> Void) {
        self.init()
        
        executor {[weak self] resolve in
            self?.result = .success(resolve)
        } _: {[weak self] reject in
            self?.result = .failure(reject)
        }
    }
    
    override init() {
    }
}

extension JSPromise: JSPromiseExports {
    func then(_ block: JSValue) -> JSPromise {
        let weakBlock = JSManagedValue(value: block, andOwner: self)
        
        let promise = JSPromise()
        observe { result in
            switch result {
            case .success(let value):
                let next = weakBlock?.value.call(withArguments: [value]) as Any
                promise.result = .success(next)
            case .failure(let error):
                promise.result = .failure(error)
            }
        }
        
        return promise
    }
    
    func `catch`(_ block: JSValue) -> JSPromise {
        let weakBlock = JSManagedValue(value: block, andOwner: self)
        
        let promise = JSPromise()
        observe { result in
            switch result {
            case .success(let value):
                promise.result = .success(value)
            case .failure(let error):
                let next = weakBlock?.value.call(withArguments: [error]) as Any
                promise.result = .failure(next)
            }
        }
        
        return promise
    }
}
