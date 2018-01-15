//
//  SLNetwork.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/9.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import Alamofire

private let SolarKitResponseQueue: String = "com.SolarKit.ResponseQueue"

public class SLNetwork {
    
    public typealias Completion = (SLResponse) -> Void
    
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
    
    @discardableResult
    public func request(_ request: SLRequest, completion: @escaping Completion) -> DataRequest {
        request.target = target
        
        willSend(request: request)
        
        return sessionManager.request(request.URLString,
                                      method: request.method,
                                      parameters: request.parameters,
                                      encoding: target.requestEncoding,
                                      headers: request.headers)
            .responseData(queue: responseQueue) { [weak self] (response) in
                
                let slResponse = SLResponse(request: request, urlRequest: response.request, httpURLResponse: response.response)

                switch response.result {
                    case .failure(let error):
                        slResponse.error = error as NSError

                    case .success(let data):
                        slResponse.data = data
                }

                self?.didReceive(response: slResponse)
                
                self?.toDictionary(response: slResponse)
                                
                self?.decode(request: request, response: slResponse)
                
                DispatchQueue.main.async {
                    completion(slResponse)
                }
        }
    }
    
}

extension SLNetwork {
    
    private func willSend(request: SLRequest) {
        responseQueue.async(flags: .barrier) {
            if let plugins = self.target.plugins {
                plugins.forEach { $0.willSend(request: request) }
            }
        }
    }
    
    private func didReceive(response: SLResponse) {
        responseQueue.async(flags: .barrier) {
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
        if let dictionary = response.data as? Dictionary<String, Any> {
            
            if let status = self.target.status {
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

}
