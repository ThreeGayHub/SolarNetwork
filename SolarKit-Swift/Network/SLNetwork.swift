//
//  SLNetwork.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/9.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

//TODO-0:上传
//TODO-1:断点续传
//TODO-2:下载
//TODO-3:断点下载

import Foundation
import Alamofire

private let SolarKitResponseQueue: String = "com.SolarKit.ResponseQueue"

public class SLNetwork {
    
    public typealias Completion = (SLResponse) -> Void
    
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
        
    //MARK: - Private
    private var target: SLTarget
    private let sessionManager: SessionManager
    private lazy var responseQueue = DispatchQueue(label: SolarKitResponseQueue)
    private lazy var reachabilityManager: NetworkReachabilityManager? = {
        let reachabilityManager = NetworkReachabilityManager(host: target.host)
        return reachabilityManager
    }()
}

extension SLNetwork {
    
    //MARK: - Data Request
    
    @discardableResult
    public func request(_ request: SLRequest, completion: @escaping Completion) -> DataRequest {
        request.target = target
        
        debugPrint(request)
        
        willSend(request: request)
        
        return sessionManager.request(request.URLString,
                                      method: request.method,
                                      parameters: request.parameters,
                                      encoding: target.requestEncoding,
                                      headers: request.headers)
            .responseData(queue: responseQueue) { [weak self] (originalResponse) in
                
                let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)

                switch originalResponse.result {
                    case .failure(let error):
                        response.error = error as NSError

                    case .success(let data):
                        response.data = data
                }

                self?.didReceive(response: response)
                
                self?.toDictionary(response: response)
                                
                self?.decode(request: request, response: response)
                
                debugPrint(response)

                DispatchQueue.main.async {
                    completion(response)
                }
        }
    }
    
}

extension SLNetwork {
    
    func upload(_ request: SLUploadRequest, completion: @escaping Completion) -> UploadRequest {
        request.target = target

        debugPrint(request)

        willSend(request: request)
        
        var uploadRequest: UploadRequest?
        
        if let filePath = request.filePath, let fileURL = URL(string: filePath) {
            uploadRequest = sessionManager.upload(fileURL, to: request.URLString, method: request.method, headers: request.headers)
        }
        else if let data = request.data {
            uploadRequest = sessionManager.upload(data, to: request.URLString, method: request.method, headers: request.headers)
        }
        else if let inputStream = request.inputStream {
            uploadRequest = sessionManager.upload(inputStream, to: request.URLString, method: request.method, headers: request.headers)
        }
        
        uploadRequest = uploadRequest?.responseData(completionHandler: { [weak self] (originalResponse) in
            
            let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)

            switch originalResponse.result {
            case .failure(let error):
                response.error = error as NSError
                
            case .success(let data):
                response.data = data
            }
            
            self?.didReceive(response: response)
            
            self?.toDictionary(response: response)
            
            self?.decode(request: request, response: response)
            
            debugPrint(response)
            
            DispatchQueue.main.async {
                completion(response)
            }
            
        })
        return uploadRequest!

    }
    
}

extension SLNetwork {
    
//    private func dealResponseOfDataRequest(request: SLRequest, originalResponse: DataResponse<Data>, completion: @escaping Completion) {
//        
//        let response = SLResponse(request: request, urlRequest: originalResponse.request, httpURLResponse: originalResponse.response)
//        
//        switch originalResponse.result {
//        case .failure(let error):
//            response.error = error as NSError
//            
//        case .success(let data):
//            response.data = data
//        }
//        
//        self.didReceive(response: response)
//        
//        self.toDictionary(response: response)
//        
//        self.decode(request: request, response: response)
//        
//        debugPrint(response)
//        
//        DispatchQueue.main.async {
//            completion(response)
//        }
//        
//    }
    
    private func willSend(request: SLRequest) {
        if let plugins = self.target.plugins {
            plugins.forEach { $0.willSend(request: request) }
        }
    }
    
    private func didReceive(response: SLResponse) {
        DispatchQueue.main.sync {
            if let plugins = self.target.plugins {
                plugins.forEach { $0.didReceive(response: response) }
            }
        }
    }
    
    func toDictionary(response: SLResponse) {
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
    
    func decode(request:SLRequest, response: SLResponse) {
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
