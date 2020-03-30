//
//  SLNetwork.swift
//
//  Created by wyhazq on 2018/1/9.
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
import Alamofire

private let SLNetworkResponseQueue: String          = "com.SLNetwork.ResponseQueue"

private let SLNetworkFolderPath: String             = "SLNetwork"
private let SLNetworkDestinationFolderPath: String  = "Destination"
private let SLNetworkResumeFolderPath: String       = "Resume"

public class SLNetwork {
    
    public typealias ProgressClosure = (SLProgress) -> Void
    public typealias CompletionClosure = (SLResponse) -> Void
    
    // MARK: - Properties
    
    /// The target's SessionManager
    public let session: Session
    
    /// The target of a host
    public var target: SLTarget
    
    /// The target's reachabilityManager
    public lazy var reachabilityManager: NetworkReachabilityManager? = {
        let reachabilityManager = NetworkReachabilityManager(host: self.target.host)
        return reachabilityManager
    }()

    private var serverTrustManager: ServerTrustManager?
    private lazy var responseQueue = { return DispatchQueue(label: SLNetworkResponseQueue) }()
    
    private lazy var SLNetworkFolderURL: URL = { return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(SLNetworkFolderPath) }()
    private lazy var SLNetworkDestinationFolderURL: URL = { return SLNetworkFolderURL.appendingPathComponent(SLNetworkDestinationFolderPath) }()
    private lazy var SLNetworkResumeFolderURL: URL = { return SLNetworkFolderURL.appendingPathComponent(SLNetworkResumeFolderPath) }()
    
    
    // MARK: - Lifecycle
    public init(_ target: SLTarget) {
        self.target = target
        
        let configuration = target.configuration
        if configuration.httpAdditionalHeaders == nil {
            configuration.headers = HTTPHeaders.default
        }
        
        var trustManager: ServerTrustManager?
        if let serverEvaluators = target.serverEvaluators {
            trustManager = ServerTrustManager(allHostsMustBeEvaluated: target.allHostsMustBeEvaluated, evaluators: serverEvaluators)
            self.serverTrustManager = trustManager
        }
        
        self.session = Session(configuration: configuration, delegate: SLSessionDelegate(), serverTrustManager: serverTrustManager)
        
        self.handleChallenge()
        
        if let reachabilityListener = target.reachabilityListener {
            self.reachabilityManager?.startListening(onUpdatePerforming: reachabilityListener)
        }
        
    }
}

extension SLNetwork {
    
    private func handleChallenge () {
        if let delegate = session.delegate as? SLSessionDelegate {
            delegate.taskDidReceiveChallenge = { [weak self] (session, task, challenge) in
                guard let strongSelf = self else { return (.performDefaultHandling, nil) }
                
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    return strongSelf.serverTrust(session: session, challenge: challenge)
                }
                else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                    return strongSelf.clientTrust(session: session, challenge: challenge)
                }
                
                return (.performDefaultHandling, nil)
            }
        }
    }
    
    private func serverTrust(session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        if let trustManager = self.serverTrustManager {
            let host = challenge.protectionSpace.host.sl.isIP ? self.target.host : challenge.protectionSpace.host

            do {
                if let serverTrustEvaluator = try trustManager.serverTrustEvaluator(forHost: host), let serverTrust = challenge.protectionSpace.serverTrust {
                    do {
                        try serverTrustEvaluator.evaluate(serverTrust, forHost: host)
                        disposition = .useCredential
                        credential = URLCredential(trust: serverTrust)
                    }
                    catch {
                        disposition = .cancelAuthenticationChallenge
                        debugPrint("ServerTrustError:\(error)")
                    }
                }
            }
            catch {
                debugPrint("ServerTrustError:\(error)")
            }
            
        }
        
        return (disposition, credential)
    }
    
    private func clientTrust(session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
        var credential: URLCredential?
        
        if let (secPKCS12Path, password) = self.target.clientTrustPolicy {
            
            guard let PKCS12Data = NSData(contentsOfFile: secPKCS12Path) else {
                return (disposition, credential)
            }
            
            let key = kSecImportExportPassphrase as NSString
            let options : NSDictionary = [key : password]
            
            var items: CFArray?
            let error = SecPKCS12Import(PKCS12Data, options, &items)
            
            if error == errSecSuccess {
                if let itemArr = items as NSArray?, let item = itemArr.firstObject as? Dictionary<String, AnyObject> {
                    let identityPointer = item[kSecImportItemIdentity as String];
                    let secIdentityRef = identityPointer as! SecIdentity
                    
                    let chainPointer = item[kSecImportItemCertChain as String]
                    let chainRef = chainPointer as? [Any]
                    
                    disposition = .useCredential
                    credential = URLCredential(identity: secIdentityRef, certificates: chainRef, persistence: URLCredential.Persistence.forSession)
                }
            }
        }
        
        return (disposition, credential)
    }
}

extension SLNetwork {
    
    // MARK: - Data Request
    
    /// Creates a `DataRequest` using the default `SessionManager` to retrieve the contents of a URL based on the specified SLRequest.
    ///
    /// - Parameters:
    ///   - request: SLRequest
    ///   - completionClosure: CompletionClosure
    public func request(_ request: SLRequest, completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        if request.enableLog { debugPrint(request) }
        
        willSend(request: request)
        
        let dataRequest: DataRequest
        
        if let urlRequest = request.urlRequest {
            dataRequest = session.request(urlRequest)
        }
        else {
            dataRequest = session.request(request.URLString, method: request.method, parameters: request.parameters, encoding: request.parameterEncoding, headers: request.headers)
        }
        
        if let credential = request.credential {
            dataRequest.authenticate(with: credential)
        }
            
        dataRequest.responseData(queue: target.responseQueue ?? responseQueue) { [weak self] (originalResponse) in
            guard let strongSelf = self else { return }

            strongSelf.dealResponseOfDataRequest(request: request, originalResponse: originalResponse, completionClosure: completionClosure)
            
        }
        request.originalRequest = dataRequest
    }
    
}

extension SLNetwork {
    
    // MARK: - Download
    
    /// Creates a `DownloadRequest` using the `SessionManager` to retrieve the contents of a URL based on the specified `urlRequest` and save them to the `destination`.
    ///
    /// - Parameters:
    ///   - request: SLDownloadRequest
    ///   - progressClosure: ProgressClosure
    ///   - completionClosure: CompletionClosure
    public func download(_ request: SLDownloadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        if request.enableLog { debugPrint(request) }
        
        willSend(request: request)
        
        let downloadRequest: DownloadRequest
        
        if let urlRequest = request.urlRequest {
            downloadRequest = session.download(urlRequest)
            downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
            
            return;
        }
        
        let destinationURL = request.destinationURL ?? SLNetworkDestinationFolderURL.appendingPathComponent(request.requestID)
        let destination: Destination = { _, _ in
            return (destinationURL, request.options)
        }
        
        if request.isResume {
            let resumeDataURL = SLNetworkResumeFolderURL.appendingPathComponent(request.requestID)
            if let resumeData = SLResumeData.data(of: resumeDataURL) {
                downloadRequest = session.download(resumingWith: resumeData, to: destination)
                downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
                guard #available(iOS 10.2, *) else { return }
                // fix 10.0 - 10.1 resumeData bug:
                session.requestQueue.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.session.rootQueue.async {
                        if let task = downloadRequest.task {
                            task.sl.fixiOS10Task(with: resumeData)
                        }
                    }
                }
                return
            }
        }
        
        downloadRequest = session.download(request.URLString, method: request.method, parameters: request.parameters, encoding: request.parameterEncoding, headers: request.headers, to: destination)
        downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
    }
    
    private func downloadResponse(with request:SLDownloadRequest, downloadRequest: DownloadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        let resumeDataURL = SLNetworkResumeFolderURL.appendingPathComponent(request.requestID)
        
        if let credential = request.credential {
            downloadRequest.authenticate(with: credential)
        }
        
        var totalUnitCount: Int64 = 0
        var progress: SLProgress?
        if let _ = progressClosure {
            progress = SLProgress(request: request)
        }
        downloadRequest.downloadProgress { (originalProgress) in
            if request.isResume && !FileManager.sl.fileExists(at: resumeDataURL) && originalProgress.fractionCompleted < 0.99 {
                request.cancel()
            }
            
            if totalUnitCount != originalProgress.totalUnitCount {
                totalUnitCount = originalProgress.totalUnitCount
            }
            if let progressClosure = progressClosure, let progress = progress {
                progress.originalProgress = originalProgress
                if request.enableLog { debugPrint(progress) }
                progressClosure(progress)
            }
        }
        
        downloadRequest.responseData(queue: target.responseQueue ?? responseQueue) { [weak self] (originalResponse) in
            guard let strongSelf = self else { return }
            
            let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
            
            switch originalResponse.result {
            case .failure(let error):
                response.error = error as NSError
                
                if request.isResume {
                    
                    if let errorCode = response.error?.code, errorCode == NSURLErrorCancelled || error.isExplicitlyCancelledError {
                        FileManager.sl.createDirectory(at: strongSelf.SLNetworkResumeFolderURL, withIntermediateDirectories: true)
                        
                        do {
                            if !FileManager.sl.fileExists(at: resumeDataURL) {
                                try originalResponse.resumeData?.write(to: resumeDataURL)
                                DispatchQueue.main.async {
                                    strongSelf.download(request, progressClosure: progressClosure, completionClosure: completionClosure)
                                }
                                return
                            }
                            
                            FileManager.sl.removeItem(at: resumeDataURL)
                            try originalResponse.resumeData?.write(to: resumeDataURL)
                            if request.enableLog {
                                debugPrint("\n------------------------ SLResponse ----------------------\n URL:\(request.URLString) \nresumeData has been writed to: \n\(resumeDataURL.absoluteString)\n ----------------------------------------------------------\n")
                            }
                        }
                        catch {
                            debugPrint("ResumeDataWriteError:\(error)")
                        }
                    }
                    else {
                        FileManager.sl.removeItem(at: resumeDataURL)

                        if let resumeData = originalResponse.resumeData, let tempFileURL = SLResumeData.tmpFileURL(of: resumeData) {
                            FileManager.sl.removeItem(at: tempFileURL)
                        }
                        
                        if !request.hasResume {
                            DispatchQueue.main.async {
                                strongSelf.download(request, progressClosure: progressClosure, completionClosure: completionClosure)
                            }
                            request.hasResume = true
                            return
                        }
                    }
                }
                
            case .success(let data):
                if request.isResume {
                    FileManager.sl.removeItem(at: resumeDataURL)
                    if Int64(data.count) == totalUnitCount || totalUnitCount == 0 {
                        response.originData = data
                        response.fileURL = originalResponse.fileURL
                    }
                    else {
                        let error = NSError(domain: strongSelf.target.host, code: NSURLErrorCannotOpenFile, userInfo: [NSLocalizedDescriptionKey : "File is damaged."])
                        response.error = error
                        
                        if let fileURL = originalResponse.fileURL {
                            FileManager.sl.removeItem(at: fileURL)
                        }
                    }
                }
                else {
                    response.originData = data
                    response.fileURL = originalResponse.fileURL
                }
                
            }
            
            strongSelf.didReceive(response: response)

            if request.enableLog { debugPrint(response) }
            
            DispatchQueue.main.async {
                completionClosure(response)
                
                request.originalRequest = nil
            }
        }
        
        request.originalRequest = downloadRequest
    }
}

extension SLNetwork {
    
    // MARK: - Upload
    
    /// Creates an `UploadRequest` using the `SessionManager` from the specified SLUploadRequest.
    ///
    /// - Parameters:
    ///   - request: SLUploadRequest
    ///   - progressClosure: ProgressClosure
    ///   - completionClosure: CompletionClosure
    public func upload(_ request: SLUploadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        if request.enableLog { debugPrint(request) }
        
        willSend(request: request)
        
        let uploadRequest: UploadRequest
        
        if let filePath = request.filePath, let fileURL = URL(string: filePath) {
            
            if let urlRequest = request.urlRequest {
                uploadRequest = session.upload(fileURL, with: urlRequest)
            }
            else {
                uploadRequest = session.upload(fileURL, to: request.URLString, method: request.method, headers: request.headers)
            }
            
        }
        else if let data = request.data {
            
            if let urlRequest = request.urlRequest {
                uploadRequest = session.upload(data, with: urlRequest)
            }
            else {
                uploadRequest = session.upload(data, to: request.URLString, method: request.method, headers: request.headers)
            }
            
        }
        else if let inputStream = request.inputStream {
            
            if request.headers == nil {
                request.headers = HTTPHeaders(["Content-Length" : "\(inputStream.length)"])
            }
            else {
                request.headers?.update(name: "Content-Length", value: "\(inputStream.length)")
            }
            
            if let urlRequest = request.urlRequest {
                uploadRequest = session.upload(inputStream.intputStream, with: urlRequest)
            }
            else {
                uploadRequest = session.upload(inputStream.intputStream, to: request.URLString, method: request.method, headers: request.headers)
            }
            
        }
        else if let multipartFormData = request.multipartFormData {
            
            if let urlRequest = request.urlRequest {
                uploadRequest = session.upload(multipartFormData: multipartFormData, with: urlRequest)
                
            }
            else {
                uploadRequest = session.upload(multipartFormData: multipartFormData, to: request.URLString, usingThreshold: request.encodingMemoryThreshold, method: request.method, headers: request.headers)
            }
            
        }
        else { return }
        uploadResponse(with: request, uploadRequest: uploadRequest, progressClosure:progressClosure, completionClosure: completionClosure)
    }
    
    private func uploadResponse(with request:SLRequest, uploadRequest: UploadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        if let credential = request.credential {
            uploadRequest.authenticate(with: credential)
        }
        
        var progress: SLProgress?
        if let _ = progressClosure {
            progress = SLProgress(request: request)
        }
        uploadRequest.uploadProgress(closure: { (originalProgress) in
            if let progressClosure = progressClosure, let progress = progress {
                progress.originalProgress = originalProgress
                if request.enableLog { debugPrint(progress) }
                progressClosure(progress)
            }
        })
        
        uploadRequest.responseData(queue: target.responseQueue ?? responseQueue) { [weak self] (originalResponse) in
            guard let strongSelf = self else { return }
            
            strongSelf.dealResponseOfDataRequest(request: request, originalResponse: originalResponse, completionClosure: completionClosure)
            
        }
        
        request.originalRequest = uploadRequest
    }
    
}

extension SLNetwork {
    // MARK: - Convenience Method
    
    public func stopReachabilityListening() {
        reachabilityManager?.stopListening()
    }
    
}

extension SLNetwork {
    
    // MARK: - Response
    private func dealResponseOfDataRequest(request: SLRequest, originalResponse: AFDataResponse<Data>, completionClosure: @escaping CompletionClosure) {
        
        let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
        
        switch originalResponse.result {
        case .failure(let error):
            response.error = error as NSError
            
        case .success(let data):
            response.originData = data
        }
        
        didReceive(response: response)
        
        toJsonObject(response: response)
        
        decode(request: request, response: response)
        
        if request.enableLog { debugPrint(response) }
        
        DispatchQueue.main.async {
            completionClosure(response)
            
            request.originalRequest = nil
        }
        
    }
    
    private func willSend(request: SLRequest) {
        if let plugins = target.plugins {
            plugins.forEach { $0.willSend(request: request) }
        }
    }
    
    private func didReceive(response: SLResponse) {
        if Thread.isMainThread {
            if let plugins = target.plugins {
                plugins.forEach { $0.didReceive(response: response) }
            }
        }
        else {
            DispatchQueue.main.sync {
                if let plugins = target.plugins {
                    plugins.forEach { $0.didReceive(response: response) }
                }
            }
        }
    }
    
    private func toJsonObject(response: SLResponse) {
        guard let data = response.originData else { return }
        
        do {
            response.data = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        catch {
            if let dataString = String(data: data, encoding: .utf8) {
                response.data = dataString
                return
            }
            response.error = error as NSError
        }
    }
    
    private func decode(request:SLRequest, response: SLResponse) {
        guard let status = target.status, let dictionary = response.data as? [String: Any] else { return }
        
        let statusValue = dictionary[status.codeKey] as! Int
        if let messageKey = status.messageKey {
            response.message = dictionary[messageKey] as? String
        }
        if statusValue == status.successCode {
            if let dataKeyPath = request.dataKeyPath {
                if let dataObject = (dictionary as AnyObject).value(forKeyPath: dataKeyPath) {
                    response.data = dataObject
                }
            }
        }
        else {
            let error = NSError(domain: target.host, code: statusValue, userInfo: [NSLocalizedDescriptionKey : response.message ?? ""])
            response.error = error
        }
    }

}
