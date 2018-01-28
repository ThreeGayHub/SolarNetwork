//
//  SLNetwork.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/9.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

//TODO-OAuth

import Foundation
import Alamofire

private let SLNetworkResponseQueue: String = "com.SLNetwork.ResponseQueue"
private let SLNetworkCacheURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("SLNetwork")
private let SLNetworkCacheDestinationURL = SLNetworkCacheURL.appendingPathComponent("destination")
private let SLNetworkCacheResumeURL = SLNetworkCacheURL.appendingPathComponent("resume")

private let SLNetworkTempPath: String = NSTemporaryDirectory()
private let SLNetworkTempFileNameKey: String = "NSURLSessionResumeInfoTempFileName"
private let SLNetworkTempFileDataCountKey: String = "NSURLSessionResumeBytesReceived"
private let SLNetworkTempFilePathKey: String = "NSURLSessionResumeInfoLocalPath"//iOS8 resumeTempFilePath

public class SLNetwork {
    
    public typealias CompletionClosure = (SLResponse) -> Void
    
    public typealias ProgressClosure = (SLProgress) -> Void
        
    //MARK: - Property
    private var target: SLTarget
    private let sessionManager: SessionManager
    private lazy var responseQueue = DispatchQueue(label: SLNetworkResponseQueue)
    private lazy var reachabilityManager: NetworkReachabilityManager? = {
        let reachabilityManager = NetworkReachabilityManager(host: target.host)
        return reachabilityManager
    }()
    
    //MARK: - Init
    public init(target: SLTarget) {
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
    
    //MARK: - Data Request
    public func request(_ request: SLRequest, completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        debugPrint(request)
        
        willSend(request: request)
        
        let dataRequest = sessionManager.request(request.URLString,
                                                 method: request.method,
                                                 parameters: request.parameters,
                                                 encoding: target.requestEncoding,
                                                 headers: request.headers)
        
        if let credential = target.credential {
            dataRequest.authenticate(usingCredential: credential)
        }
            
        dataRequest.responseData(queue: target.responseQueue ?? responseQueue) { [weak self] (originalResponse) in
            
            self?.dealResponseOfDataRequest(request: request, originalResponse: originalResponse, completionClosure: completionClosure)
            
        }
        
        request.originalRequest = dataRequest
    }
    
}

extension SLNetwork {
    
    //MARK: - Download
    func download(_ request: SLDownloadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        debugPrint(request)
        
        willSend(request: request)
        
        let destinationURL = request.destinationURL ?? SLNetworkCacheDestinationURL.appendingPathComponent(request.requestID)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationURL, request.downloadOptions)
        }

        var downloadRequest: DownloadRequest
        if request.isResume {
            let resumeDataURL = SLNetworkCacheResumeURL.appendingPathComponent(request.requestID)
            if let resumeData = resumeData(of: resumeDataURL) {
                downloadRequest = sessionManager.download(resumingWith: resumeData, to: destination)
                downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
                return
            }
        }
        downloadRequest = sessionManager.download(request.URLString, method: request.method, parameters: request.parameters, encoding: target.requestEncoding, headers: request.headers, to: destination)
        downloadResponse(with: request, downloadRequest: downloadRequest, progressClosure: progressClosure, completionClosure: completionClosure)
    }
    
    private func downloadResponse(with request:SLDownloadRequest, downloadRequest: DownloadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        if let credential = target.credential {
            downloadRequest.authenticate(usingCredential: credential)
        }
        
        var progress: SLProgress?
        if let _ = progressClosure {
            progress = SLProgress(request: request)
        }
        downloadRequest.downloadProgress { (originalProgress) in
            if let progressClosure = progressClosure, let progress = progress {
                progress.originalProgress = originalProgress
                debugPrint(progress)
                progressClosure(progress)
            }
        }
        
        downloadRequest.responseData(queue: target.responseQueue ?? responseQueue) { [weak self] (originalResponse) in
            let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
            let resumeURL = SLNetworkCacheResumeURL.appendingPathComponent(request.requestID)
            
            switch originalResponse.result {
            case .failure(let error):
                response.error = error as NSError
                
                if request.isResume {
                    if let errorCode = response.error?.code, errorCode == NSURLErrorCancelled {
                        
                        FileManager.createDirectory(at: SLNetworkCacheResumeURL, withIntermediateDirectories: true)
                        
                        do {
                            try originalResponse.resumeData?.write(to: resumeURL)
                            debugPrint("""
                                ------------------------ SLResponse ----------------------
                                URL:\(request.URLString)
                                resumeData has been writed to:
                                \(resumeURL.absoluteString)
                                ------------------------ SLResponse ----------------------
                                
                                """)
                        }
                        catch {
                            debugPrint("ResumeDataWriteError:\(error)")
                        }
                    }
                    else {
                        FileManager.removeItem(at: resumeURL)

                        if let resumeData = originalResponse.resumeData, let tempFileURL = self?.tempFileURL(of: resumeData) {
                            FileManager.removeItem(at: tempFileURL)
                        }
                        
                        if !request.hsaResume {
                            DispatchQueue.main.async {
                                self?.download(request, progressClosure: progressClosure, completionClosure: completionClosure)
                            }
                            request.hsaResume = true
                            return
                        }
                    }
                }
                
            case .success(let data):
                
                FileManager.removeItem(at: resumeURL)

                response.data = data
                response.destinationURL = originalResponse.destinationURL
            }
            
            self?.didReceive(response: response)

            debugPrint(response)
            
            DispatchQueue.main.async {
                completionClosure(response)
                
                request.originalRequest = nil
            }
            
        }
        
        request.originalRequest = downloadRequest
        
    }
    
    private func resumeData(of resumeDataURL: URL) -> Data? {
        let resumeDataPath = resumeDataURL.absoluteString.replacingOccurrences(of: "file://", with: "")
        if FileManager.default.fileExists(atPath: resumeDataPath) {
            do {
                var resumeData = try Data(contentsOf: resumeDataURL)
                
                //The path of the iOS8 emulator changes every time it is run.
                if Platform.isSimulator, var resumeDict = resumeDict(of: resumeData), resumeDict.keys.contains(SLNetworkTempFilePathKey) {
                    let path = resumeDict[SLNetworkTempFilePathKey] as! NSString
                    let tempFilePath = SLNetworkTempPath + path.lastPathComponent
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
    
    func tempFileData(of tempFileURL: URL) -> Data? {
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
                tempFilePath = SLNetworkTempPath + name
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

extension SLNetwork {
    
    //MARK: - Upload
    public func upload(_ request: SLUploadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        request.target = target
        
        debugPrint(request)
        
        willSend(request: request)
        
        var uploadRequest: UploadRequest
        
        if let multipartFormDataClosure = request.multipartFormDataClosure {
            sessionManager.upload(multipartFormData: multipartFormDataClosure, usingThreshold: request.encodingMemoryThreshold, to: request.URLString, method: request.method, headers: request.headers, encodingCompletion: { [weak self] (encodingResult) in
                switch encodingResult {
                    
                case .success(let uploadRequest, _, _):
                    self?.uploadResponse(with: request, uploadRequest: uploadRequest, progressClosure:progressClosure, completionClosure: completionClosure)
                    
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
                uploadRequest = sessionManager.upload(inputStream,
                                                      to: request.URLString,
                                                      method: request.method,
                                                      headers: request.headers)
            }
            else { return }
            uploadResponse(with: request, uploadRequest: uploadRequest, progressClosure:progressClosure, completionClosure: completionClosure)
        }
    }
    
    private func uploadResponse(with request:SLRequest, uploadRequest: UploadRequest, progressClosure: ProgressClosure? = nil,  completionClosure: @escaping CompletionClosure) {
        
        if let credential = target.credential {
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
            
            self?.dealResponseOfDataRequest(request: request, originalResponse: originalResponse, completionClosure: completionClosure)
            
        }
        
        request.originalRequest = uploadRequest
    }
    
}

extension SLNetwork {
    
    //MARK: - Response
    private func dealResponseOfDataRequest(request: SLRequest, originalResponse: DataResponse<Data>, completionClosure: @escaping CompletionClosure) {
        
        let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
        
        switch originalResponse.result {
        case .failure(let error):
            response.error = error as NSError
            
        case .success(let data):
            response.data = data
        }
        
        self.didReceive(response: response)
        
        self.toDictionary(response: response)
        
        self.decode(request: request, response: response)
        
        debugPrint(response)
        
        DispatchQueue.main.async {
            completionClosure(response)
            
            request.originalRequest = nil
        }
        
    }
    
    private func willSend(request: SLRequest) {
        if let plugins = self.target.plugins {
            plugins.forEach { $0.willSend(request: request) }
        }
    }
    
    private func didReceive(response: SLResponse) {
        if Thread.isMainThread {
            if let plugins = self.target.plugins {
                plugins.forEach { $0.didReceive(response: response) }
            }
        }
        else {
            DispatchQueue.main.sync {
                if let plugins = self.target.plugins {
                    plugins.forEach { $0.didReceive(response: response) }
                }
            }
        }
    }
    
    private func toDictionary(response: SLResponse) {
        var tempData: Data?
        if let string = response.data as? String {
            tempData = string.data(using: .utf8)
        }
        else if let data = response.data as? Data {
            tempData = data
        }
        if let data = tempData {
            do {
                response.data = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
            catch {
                response.error = error as NSError
            }
        }
    }
    
    private func decode(request:SLRequest, response: SLResponse) {
        if let status = self.target.status, let dictionary = response.data as? Dictionary<String, Any> {
            let statusValue: Int = dictionary[status.codeKey] as! Int
            var message: String = ""
            if let messageKey = status.messageKey {
                message = dictionary[messageKey] as! String
            }
            response.message = message
            if statusValue == status.successCode {
                if let dataKeyPath = request.dataKeyPath {
                    if let dataObject = (dictionary as AnyObject).value(forKeyPath: dataKeyPath) {
                        response.data = dataObject
                    }
                }
            }
            else {
                let error = NSError(domain: self.target.host, code: statusValue, userInfo: [NSLocalizedDescriptionKey : message])
                response.error = error
            }
        }
    }

}

extension FileManager {
    
    static func createDirectory(at URL: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) {
        let path = URL.absoluteString.replacingOccurrences(of: "file://", with: "")
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(at: URL, withIntermediateDirectories: createIntermediates, attributes: attributes)
            }
            catch {
                debugPrint("FileManager.createDirectoryError:\(error)")
            }
        }
    }
    
    static func removeItem(at URL: URL) {
        let path = URL.absoluteString.replacingOccurrences(of: "file://", with: "")
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(at: URL)
            }
            catch {
                debugPrint("FileManager.removeItemError:\(error)")
            }
        }
    }
    
}
