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
    
    public init(method: HTTPMethod = .get,
                URLString: String? = nil,
                path: String = "",
                parameters: Parameters? = nil,
                parameterEncoding: ParameterEncoding = URLEncoding.default,
                headers: [String: String]? = nil) {
        self.storeMethod = method
        self.storeURLString = URLString
        self.path = path
        self.storeParameters = parameters
        self.headers = headers
        
        loadRequest()
    }
    
    public func loadRequest() {}
    
    public var originalRequest: Request?
    
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
                storeParameters = parameters
                return parameters
            }
            return nil
        }
        set {
            storeParameters = newValue
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        get {
//            if let parameterEncoding = storeParameterEncoding {
//                switch method {
//                case .get, .head:
//                    return URLEncoding.default
//
//                case .delete:
//
//                    if let parameters = parameters, parameters.count > 0 {
//                        return parameterEncoding
//                    }
//                    else {
//                        return URLEncoding.default
//                    }
//
//                default:
//                    return parameterEncoding
//                }
//            }
//            else {
//                return URLEncoding.default
//            }
            return storeParameterEncoding ?? URLEncoding.default
        }
        set {
            storeParameterEncoding = newValue
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
            if storeParameterEncoding == nil {
                storeParameterEncoding = newValue?.parameterEncoding
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
    
    public var credential: URLCredential?
    
    public var basicAuthentication: (user: String, password: String)? {
        get {
            return nil
        }
        set {
            if let user = newValue?.user, let password = newValue?.password {
                if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
                    if headers == nil {
                        headers = [authorizationHeader.key : authorizationHeader.value]
                    }
                    else {
                        headers![authorizationHeader.key] = authorizationHeader.value
                    }
                }
            }
        }
    }
        
    public var dataKeyPath: String?

    //MARK: - Private
    private var storeMethod: HTTPMethod?
    
    private var storeURLString: String?
    
    private var storeParameters: Parameters?
    
    private var storeParameterEncoding: ParameterEncoding?

    private var storeTarget: SLTarget?
}

extension SLRequest {
    
    public func blackList() -> [String]? {
        return ["isResume", "hasResume", "hasSaveResumeData"]
    }
    
}

extension SLRequest {
    
    public func pause() {
        originalRequest?.suspend()
    }
    
    public func cancel() {
        originalRequest?.cancel()
    }
    
    public func resume() {
        originalRequest?.resume()
    }
    
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

open class SLDownloadRequest: SLRequest {
    
    public var isResume: Bool = false
    
    var hasResume: Bool = false
    
    public var destinationURL: URL?
    
    public var downloadOptions: DownloadRequest.DownloadOptions = [.removePreviousFile, .createIntermediateDirectories]
    
}

open class SLUploadRequest: SLRequest {
    
    public typealias MultipartFormDataClosure = (MultipartFormData) -> Void
    
    public override func loadRequest() {
        super.loadRequest()
        self.method = .post
    }
    
    public var data: Data?
    
    public var filePath: String?
    
    public var inputStream: (intputStream: InputStream, length: Int)?
    
    public var multipartFormDataClosure: MultipartFormDataClosure?
    
    public var encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold
    
}
