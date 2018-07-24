//
//  SLRequest.swift
//
//  Created by wyh on 2018/1/6.
//  Copyright © 2018年 SolarKit. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A type that can inspect and optionally adapt a `URLRequest` in some manner if necessary.
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
    
    open func loadRequest() {}
    
    internal var originalRequest: Request?
    
    /// Base64 string of the request's URLString
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
                if let IPURLString = newValue?.IPURLString {
                    storeURLString = IPURLString + path
                    if let host = newValue?.host {
                        if headers == nil {
                            headers = [SLHostKey : host]
                        }
                        else {
                            headers![SLHostKey] = host
                        }
                    }
                }
                else if let baseURLString = newValue?.baseURLString {
                    storeURLString = baseURLString + path
                }
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
    
    
    /// The response's dataKey of the request
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
    
    /// Pause the request.
    public func pause() {
        originalRequest?.suspend()
    }
    
    /// Cancel the request.
    public func cancel() {
        originalRequest?.cancel()
    }
    
    /// Resumes the request.
    public func resume() {
        originalRequest?.resume()
    }
    
}

extension SLRequest: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        ------------------------ SLRequest -----------------------
        URL:\(URLString)
        Headers:\(String(describing: headers))
        Parameters:\(String(describing: parameters))
        ----------------------------------------------------------
        
        """
    }
    
}

open class SLDownloadRequest: SLRequest {
    
    /// Specifies whether the download request is resume or not.
    public var isResume: Bool = false
    
    internal var hasResume: Bool = false
    
    /// Specify the destination URL to receive the file. default: "/Library/Caches/SLNetwork/Destination/\(requestID)"
    public var destinationURL: URL?
    
    public var downloadOptions: DownloadOptions = [.removePreviousFile, .createIntermediateDirectories]
    
}

open class SLUploadRequest: SLRequest {
    
    public typealias MultipartFormDataClosure = (MultipartFormData) -> Void
    
    override open func loadRequest() {
        super.loadRequest()
        self.method = .post
    }
    
    
    /// uploading the `data`.
    public var data: Data?
    
    /// uploading the `file`.
    public var filePath: String?
    
    /// uploading the `inputStream`.
    public var inputStream: (intputStream: InputStream, length: Int)?
    
    /// uploading the `formData`.
    internal var multipartFormDataClosure: MultipartFormDataClosure?
    
    public var encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold
    
    public func multipartFormDataClosure(_ formDataClosure: @escaping MultipartFormDataClosure) {
        multipartFormDataClosure = formDataClosure
    }
    
}
