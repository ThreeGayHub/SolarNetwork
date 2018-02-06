//
//  SLNetwork.swift
//
//  Created by wyh on 2018/1/9.
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

private let SLNetworkResponseQueue: String          = "com.SLNetwork.ResponseQueue"

private let SLNetworkFolderPath: String             = "SLNetwork"
private let SLNetworkDestinationFolderPath: String  = "Destination"
private let SLNetworkResumeFolderPath: String       = "Resume"

private let SLNetworkTempFileNameKey: String        = "NSURLSessionResumeInfoTempFileName"
private let SLNetworkTempFileDataCountKey: String   = "NSURLSessionResumeBytesReceived"
private let SLNetworkTempFilePathKey: String        = "NSURLSessionResumeInfoLocalPath"//iOS8 emulator resumeTempFilePath

public class SLNetwork {
    
    public typealias ProgressClosure = (SLProgress) -> Void
    public typealias CompletionClosure = (SLResponse) -> Void
    
    // MARK: - Properties
    
    /// The target's SessionManager
    public let sessionManager: SessionManager
    
    /// The target of a host
    public var target: SLTarget
    
    private lazy var responseQueue = { return DispatchQueue(label: SLNetworkResponseQueue) }()
    private lazy var reachabilityManager: NetworkReachabilityManager? = {
        let reachabilityManager = NetworkReachabilityManager(host: target.host)
        return reachabilityManager
    }()
    
    private lazy var SLNetworkFolderURL: URL = { return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(SLNetworkFolderPath) }()
    private lazy var SLNetworkDestinationFolderURL: URL = { return SLNetworkFolderURL.appendingPathComponent(SLNetworkDestinationFolderPath) }()
    private lazy var SLNetworkResumeFolderURL: URL = { return SLNetworkFolderURL.appendingPathComponent(SLNetworkResumeFolderPath) }()
    private lazy var SLNetworkTempFolderPath: String = { return NSTemporaryDirectory() }()
    
    
    // MARK: - Lifecycle
    public init(_ target: SLTarget) {
        self.target = target
        
        let configuration = target.configuration
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        var serverTrustPolicyManager: ServerTrustPolicyManager?
        if let policies = target.policies {
            serverTrustPolicyManager = ServerTrustPolicyManager(policies: policies)
        }
        
        self.sessionManager = SessionManager(configuration: configuration, serverTrustPolicyManager:serverTrustPolicyManager)
        
        if let reachability = target.reachability {
            reachabilityManager?.listener = reachability
            reachabilityManager?.startListening()
        }
        
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
        
        debugPrint(request)
        
        willSend(request: request)
        
        let dataRequest = sessionManager.request(request.URLString,
                                                 method: request.method,
                                                 parameters: request.parameters,
                                                 encoding: request.parameterEncoding,
                                                 headers: request.headers)
        
        if let credential = request.credential {
            dataRequest.authenticate(usingCredential: credential)
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
        
        debugPrint(request)
        
        willSend(request: request)
        
        let destinationURL = request.destinationURL ?? SLNetworkDestinationFolderURL.appendingPathComponent(request.requestID)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationURL, request.downloadOptions)
        }

        var downloadRequest: DownloadRequest
        if request.isResume {
            let resumeDataURL = SLNetworkResumeFolderURL.appendingPathComponent(request.requestID)
            if let resumeData = resumeData(of: resumeDataURL) {
                downloadRequest = sessionManager.download(resumingWith: resumeData, to: destination)
                downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
                return
            }
        }
                
        downloadRequest = sessionManager.download(request.URLString, method: request.method, parameters: request.parameters, encoding: request.parameterEncoding, headers: request.headers, to: destination)
        downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
    }
    
    private func downloadResponse(with request:SLDownloadRequest, downloadRequest: DownloadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        let resumeDataURL = SLNetworkResumeFolderURL.appendingPathComponent(request.requestID)
        
        if let credential = request.credential {
            downloadRequest.authenticate(usingCredential: credential)
        }
        
        var totalUnitCount: Int64 = 0
        var progress: SLProgress?
        if let _ = progressClosure {
            progress = SLProgress(request: request)
        }
        downloadRequest.downloadProgress { (originalProgress) in
            if request.isResume && !FileManager.fileExists(at: resumeDataURL) {
                request.cancel()
            }
            
            if totalUnitCount != originalProgress.totalUnitCount {
                totalUnitCount = originalProgress.totalUnitCount
            }
            if let progressClosure = progressClosure, let progress = progress {
                progress.originalProgress = originalProgress
                debugPrint(progress)
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
                    if let errorCode = response.error?.code, errorCode == NSURLErrorCancelled {
                        
                        FileManager.createDirectory(at: strongSelf.SLNetworkResumeFolderURL, withIntermediateDirectories: true)
                        
                        do {
                            if !FileManager.fileExists(at: resumeDataURL) {
                                try originalResponse.resumeData?.write(to: resumeDataURL)
                                DispatchQueue.main.async {
                                    strongSelf.download(request, progressClosure: progressClosure, completionClosure: completionClosure)
                                }
                                return
                            }
                            
                            try originalResponse.resumeData?.write(to: resumeDataURL)
                            debugPrint("""
                                ------------------------ SLResponse ----------------------
                                URL:\(request.URLString)
                                resumeData has been writed to:
                                \(resumeDataURL.absoluteString)
                                ------------------------ SLResponse ----------------------
                                
                                """)
                        }
                        catch {
                            debugPrint("ResumeDataWriteError:\(error)")
                        }
                    }
                    else {
                        FileManager.removeItem(at: resumeDataURL)

                        if let resumeData = originalResponse.resumeData, let tempFileURL = strongSelf.tempFileURL(of: resumeData) {
                            FileManager.removeItem(at: tempFileURL)
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
                    if Int64(data.count) == totalUnitCount || totalUnitCount == 0 {
                        response.data = data
                        response.destinationURL = originalResponse.destinationURL
                    }
                    else {
                        let error = NSError(domain: strongSelf.target.host, code: NSURLErrorCannotOpenFile, userInfo: [NSLocalizedDescriptionKey : "File is damaged."])
                        response.error = error
                        
                        if let destinationURL = originalResponse.destinationURL {
                            FileManager.removeItem(at: destinationURL)
                        }
                    }
                }
                else {
                    response.data = data
                    response.destinationURL = originalResponse.destinationURL
                }
                
            }
            
            strongSelf.didReceive(response: response)

            debugPrint(response)
            
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
        
        debugPrint(request)
        
        willSend(request: request)
        
        var uploadRequest: UploadRequest
        
        if let multipartFormDataClosure = request.multipartFormDataClosure {
            sessionManager.upload(multipartFormData: multipartFormDataClosure, usingThreshold: request.encodingMemoryThreshold, to: request.URLString, method: request.method, headers: request.headers, encodingCompletion: { [weak self] (encodingResult) in
                guard let strongSelf = self else { return }
                
                switch encodingResult {
                case .success(let uploadRequest, _, _):
                    strongSelf.uploadResponse(with: request, uploadRequest: uploadRequest, progressClosure:progressClosure, completionClosure: completionClosure)
                    
                case .failure(let error):
                    let response = SLResponse(request: request, urlRequest: nil, httpURLResponse: nil)
                    response.error = error as NSError
                    completionClosure(response)
                }
            })
        }
        else {
            if let filePath = request.filePath, let fileURL = URL(string: filePath) {
                uploadRequest = sessionManager.upload(fileURL,
                                                      to: request.URLString,
                                                      method: request.method,
                                                      headers: request.headers)
            }
            else if let data = request.data {
                uploadRequest = sessionManager.upload(data,
                                                      to: request.URLString,
                                                      method: request.method,
                                                      headers: request.headers)
            }
            else if let inputStream = request.inputStream {
                
                if request.headers == nil {
                    request.headers = ["Content-Length" : "\(inputStream.length)"]
                }
                else {
                    request.headers!["Content-Length"] = "\(inputStream.length)"
                }
                
                uploadRequest = sessionManager.upload(inputStream.intputStream,
                                                      to: request.URLString,
                                                      method: request.method,
                                                      headers: request.headers)
            }
            else { return }
            uploadResponse(with: request, uploadRequest: uploadRequest, progressClosure:progressClosure, completionClosure: completionClosure)
        }
    }
    
    private func uploadResponse(with request:SLRequest, uploadRequest: UploadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        if let credential = request.credential {
            uploadRequest.authenticate(usingCredential: credential)
        }
        
        var progress: SLProgress?
        if let _ = progressClosure {
            progress = SLProgress(request: request)
        }
        uploadRequest.uploadProgress(closure: { (originalProgress) in
            if let progressClosure = progressClosure, let progress = progress {
                progress.originalProgress = originalProgress
                debugPrint(progress)
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
    
    // MARK: - Response
    private func dealResponseOfDataRequest(request: SLRequest, originalResponse: DataResponse<Data>, completionClosure: @escaping CompletionClosure) {
        
        let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
        
        switch originalResponse.result {
        case .failure(let error):
            response.error = error as NSError
            
        case .success(let data):
            response.data = data
        }
        
        didReceive(response: response)
        
        if let _ = response.data {
            toJsonObject(response: response)
            
            decode(request: request, response: response)
        }
        
        debugPrint(response)
        
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
        var tempData: Data?
        if let string = response.data as? String {
            tempData = string.data(using: .utf8)
        }
        else if let data = response.data as? Data {
            tempData = data
        }
        if let data = tempData, data.count > 0 {
            do {
                response.data = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
            catch {
                response.error = error as NSError
            }
        }
    }
    
    private func decode(request:SLRequest, response: SLResponse) {
        if let status = target.status, let dictionary = response.data as? [String: Any] {
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

}

extension SLNetwork {
    
    // MARK: - ResumeData

    private func resumeData(of resumeDataURL: URL) -> Data? {
        if FileManager.fileExists(at: resumeDataURL) {
            do {
                var resumeData = try Data(contentsOf: resumeDataURL)
                
                //The path of the iOS8 emulator changes every time it is run.
                if Platform.isSimulator, var resumeDict = resumeDict(of: resumeData), resumeDict.keys.contains(SLNetworkTempFilePathKey) {
                    let path = resumeDict[SLNetworkTempFilePathKey] as! NSString
                    let tempFilePath = SLNetworkTempFolderPath + path.lastPathComponent
                    resumeDict[SLNetworkTempFilePathKey] = tempFilePath
                    
                    do {
                        let propertyListForamt =  PropertyListSerialization.PropertyListFormat.binary
                        resumeData = try PropertyListSerialization.data(fromPropertyList: resumeDict, format: propertyListForamt, options: 0)
                    }
                    catch {
                        debugPrint("PropertyListSerialization.dataError:\(error)")
                    }
                }
                
                if checkValid(of: resumeData) {
                    return resumeData
                }
                else {
                    // fix the resumeData after App crash or App close
                    if var resumeDict = resumeDict(of: resumeData), let tempFileURL = tempFileURL(of: resumeData), let tempFileData = tempFileData(of: tempFileURL) {
                        resumeDict[SLNetworkTempFileDataCountKey] = tempFileData.count
                        
                        do {
                            let propertyListForamt =  PropertyListSerialization.PropertyListFormat.binary
                            resumeData = try PropertyListSerialization.data(fromPropertyList: resumeDict, format: propertyListForamt, options: 0)
                            return resumeData
                        }
                        catch {
                            debugPrint("PropertyListSerialization.dataError:\(error)")
                        }
                    }
                }
                
            } catch {
                debugPrint("ResumeDataInitError:\(error)")
            }
        }
        return nil
    }
    
    private func checkValid(of resumeData: Data) -> Bool {
        let dataCount = tempFileDataCount(of: resumeData)
        
        if let tempFileURL = tempFileURL(of: resumeData), let tempFileData = tempFileData(of: tempFileURL) {
            return tempFileData.count == dataCount
        }
        
        return false
    }
    
    private func tempFileData(of tempFileURL: URL) -> Data? {
        do {
            let tempFileData = try Data(contentsOf: tempFileURL)
            return tempFileData
        } catch {
            debugPrint("TempFileDataInitError:\(error)")
        }
        return nil
    }
    
    private func tempFileURL(of resumeData: Data) -> URL? {
        if let resumeDict = resumeDict(of: resumeData) {
            var tempFileName: String?
            var tempFilePath: String?
            if resumeDict.keys.contains(SLNetworkTempFileNameKey) {
                tempFileName = resumeDict[SLNetworkTempFileNameKey] as? String
            }
            else if resumeDict.keys.contains(SLNetworkTempFilePathKey) {
                let path = resumeDict[SLNetworkTempFilePathKey] as! NSString
                tempFileName = path.lastPathComponent
            }
            if let name = tempFileName {
                tempFilePath = SLNetworkTempFolderPath + name
            }
            if let path = tempFilePath {
                if FileManager.default.fileExists(atPath: path) {
                    let tempFileURL = URL(fileURLWithPath: path)
                    return tempFileURL
                }
            }
        }
        return nil
    }
    
    private func tempFileDataCount(of resumeData: Data) -> Int {
        if let resumeDict = resumeDict(of: resumeData) {
            let tempFileDataCount = resumeDict[SLNetworkTempFileDataCountKey] as! Int
            return tempFileDataCount
        }
        return 0
    }
    
    private func resumeDict(of resumeData: Data) -> [String: Any]? {
        do {
            var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml
            let resumeDict = try PropertyListSerialization.propertyList(from: resumeData, options: .mutableContainersAndLeaves, format: &propertyListForamt) as? [String: Any]
            return resumeDict
            
        } catch {
            debugPrint("ResumeDictSerializationError:\(error)")
        }
        return nil
    }
    
    struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }
    
}

extension FileManager {
    
    static func createDirectory(at URL: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) {
        if !FileManager.fileExists(at: URL) {
            do {
                try FileManager.default.createDirectory(at: URL, withIntermediateDirectories: createIntermediates, attributes: attributes)
            }
            catch {
                debugPrint("FileManager.createDirectoryError:\(error)")
            }
        }
    }
    
    static func removeItem(at URL: URL) {
        if FileManager.fileExists(at: URL) {
            do {
                try FileManager.default.removeItem(at: URL)
            }
            catch {
                debugPrint("FileManager.removeItemError:\(error)")
            }
        }
    }
    
    static func fileExists(at URL: URL) -> Bool {
        let path = URL.absoluteString.replacingOccurrences(of: "file://", with: "")
        return FileManager.default.fileExists(atPath: path)
    }
    
}
