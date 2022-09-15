import Foundation
import JavaScriptCore

@objc protocol JSHttpExports: JSExport {
    static func fetch(_ request: JSValue) -> JSPromise
}

class JSHttp: NSObject, JSHttpExports {
    
    class func fetch(_ request: JSValue) -> JSPromise {
        return JSPromise { resolve, reject in
            guard let dict = request.toDictionary(), let url = dict["url"] as? String else {
                reject("request is not valided")
                return
            }
            let method = (dict["method"] as? String) ?? "GET"
            let headers: [String: String] = (dict["headers"] as? [String: String]) ?? [:]
            let body = dict["body"] as? String
            
            if let url = URL(string: url) {
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = headers
                request.httpBody = body?.data(using: .utf8)
                request.httpMethod = method
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        reject(error.localizedDescription)
                    } else if
                        let data = data,
                        let string = String(data: data, encoding: String.Encoding.utf8) {
                        
                        var object = [String: Any]()
                        object["body"] = string
                        if let res = response as? HTTPURLResponse {
                            object["headers"] = res.allHeaderFields
                            object["statusCode"] = res.statusCode
                        }
                        resolve(object)
                    } else {
                        reject("\(url) is empty")
                    }
                }.resume()
            } else {
                reject("\(url) is not url")
            }
        }
    }
}
