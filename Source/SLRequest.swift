//
//  SLRequest.swift
//
//  Created by wyhazq on 2018/1/6.
//  Copyright © 2018年 SolarNetwork. All rights reserved.
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
                headers: HTTPHeaders? = nil) {
        self.storeMethod = method
        self.storeURLString = URLString
        self.path = path
        self.storeParameters = parameters
        self.headers = headers
        
        loadRequest()
    }
    
    open func loadRequest() {}
    
    public var originalRequest: Request?
    
    /// Base64 string of the request's URLString + method
    public var requestID: String {
        let string = URLString + method.rawValue
        return string.data(using: .utf8)?.base64EncodedString() ?? ""
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
            else if let parameters = jsonObject as? Parameters {
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
            if let targetHeaders = newValue?.headers {
                if let reqHeaders = headers {
                    for (key, value) in targetHeaders.dictionary {
                        if reqHeaders.value(for: key) == nil {
                            headers?.update(name: key, value: value)
                        }
                    }
                }
                else {
                    headers = targetHeaders
                }
            }
            if dataKeyPath == nil {
                dataKeyPath = newValue?.status?.dataKeyPath
            }
            storeTarget = newValue
        }
    }
    
    public var headers: HTTPHeaders?
    
    public var credential: URLCredential?
    
    ///custom Request
    public var urlRequest: URLRequestConvertible?
    
    /// The response's dataKey of the request
    public var dataKeyPath: String?
    
    public var enableLog: Bool {
        get {
            return storeEnableLog ?? target?.enableLog ?? true
        }
        set {
            storeEnableLog = newValue
        }
    }
    
    public var userInfo: Parameters?

    //MARK: - Private
    private var storeMethod: HTTPMethod?
    
    private var storeURLString: String?
    
    private var storeParameters: Parameters?
    
    private var storeParameterEncoding: ParameterEncoding?

    private var storeTarget: SLTarget?
    
    private var storeEnableLog: Bool?

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

extension SLRequest {
    @objc open var blackList: [String] {
        return []
    }
}

extension SLRequest: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        var headersString: String? = "nil"
        var parametersString: String? = "nil"

        if let headers = headers?.dictionary {
            let headersData = try? JSONSerialization.data(withJSONObject: headers, options: [.prettyPrinted])
            if let data = headersData {
                headersString = String(data: data, encoding: .utf8)
            }
        }
        if let parameters = parameters {
            let parametersData = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
            parametersString = String(data: parametersData ?? Data(), encoding: .utf8)
        }
        
        return """
        
        ------------------------ SLRequest -----------------------
        URL:\(URLString)
        Headers:\(headersString!)
        Parameters:\(parametersString!)
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
    
    public var options: Options = [.removePreviousFile, .createIntermediateDirectories]
    
    open override var blackList: [String] {
        return ["isResume", "hasResume"]
    }
        
    public override func cancel() {
        if isResume {
            if let downloadRequest = originalRequest as? DownloadRequest {
                downloadRequest.cancel(producingResumeData: true)
                return
            }
        }
        
        super.cancel()
    }
    
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
    public var multipartFormData: MultipartFormDataClosure?
    
    public var encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold
    
}
