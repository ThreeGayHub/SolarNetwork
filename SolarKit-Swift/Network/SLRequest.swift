//
//  SLRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/6.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit
import Alamofire

open class SLRequest: SLReflection {
    
    public init(method: HTTPMethod? = .get, URLString: String? = nil, path: String? = "", parameters: Parameters? = nil, headers: [String: String]? = nil) {
        self.storeMethod = method
        self.storeURLString = URLString
        self.path = path!
        self.storeParameters = parameters
        self.headers = headers
    }
    
    public var requestID: String {
        return URLString.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    public var method: HTTPMethod {
        get {
            return storeMethod ?? .get
        }
        set {
            storeMethod = newValue
        }
    }
    
    public var path: String = ""
    
    public var URLString: String {
        get {
            return storeURLString ?? ""
        }
        set {
            storeURLString = newValue
        }
    }
    
    public var parameters: Parameters? {
        get {
            if let parameters = storeParameters {
                return parameters
            }
            else if let parameters = toJSONObject() as? Parameters {
                return parameters
            }
            return nil
        }
        set {
            storeParameters = newValue
        }
    }
        
    public var target: SLTarget? {
        get {
            return storeTarget
        }
        set {
            if storeMethod == nil {
                storeMethod = newValue?.method
            }
            if storeURLString == nil {
                storeURLString = (newValue?.baseURLString)! + path
            }
            if let targetHeaders = newValue?.headers, targetHeaders.count > 0 {
                if headers == nil {
                    headers = targetHeaders
                }
                else {
                    for (key, obj) in targetHeaders {
                        if !(headers?.keys.contains(key))! {
                            headers![key] = obj
                        }
                    }
                }
            }
            if dataKeyPath == nil {
                dataKeyPath = newValue?.status?.dataKeyPath
            }
            storeTarget = newValue
        }
    }
    
    public var headers: [String: String]?
        
    public var dataKeyPath: String?

    //MARK: - Private
    private var storeMethod: HTTPMethod?
    
    private var storeURLString: String?
    
    private var storeParameters: Parameters?

    private var storeTarget: SLTarget?
}

extension SLRequest: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        ------------------------ SLRequest -----------------------
        URL:\(URLString)
        headers:\(String(describing: headers))
        parameters:\(String(describing: parameters))
        ------------------------ SLRequest -----------------------
        """
    }
    
}

class SLUploadRequest: SLRequest {
    
    override init(method: HTTPMethod? = .post, URLString: String? = nil, path: String? = "", parameters: Parameters? = nil, headers: [String: String]? = nil) {
        super.init(method: method, URLString: URLString, path: path, parameters: parameters, headers: headers)
    }
    
    public var filePath: String?
    
    public var data: Data?
    
    public var inputStream: InputStream?
    
}
