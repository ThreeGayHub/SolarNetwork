//
//  SLTarget.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/9.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Alamofire

public protocol SLTarget {
    
    /// The target's baseURLString.
    var baseURLString: String { get }
    
    /// The target's HTTPMethod.
    var method: HTTPMethod { get }
    
    /// The target's HTTPHeaders.
    var headers: [String: String]? { get set }
    
    /// The target's ParameterEncoding.
    var parameterEncoding: ParameterEncoding { get }
 
    /// The target's URLSessionConfiguration.
    var configuration: URLSessionConfiguration { get }
    
    /// The target's serverTrustPolicies
    var policies: [String : ServerTrustPolicy]? { get }
    
    /// The target's ResponseQueue
    var responseQueue: DispatchQueue? { get }
    
    /// The target's Plugins
    var plugins: [SLPlugin]? { get }
    
    /// The target's Reachability
    var reachability: NetworkReachabilityManager.Listener? { get }
    
    /// The target's Host.
    var host: String { get }
    
    /// The target's Response Status
    var status: (codeKey: String, successCode: Int, messageKey: String?, dataKeyPath: String?)? { get }
    
    /// The target's Response JSONDecoder
    var decoder: JSONDecoder { get }
    
}

extension SLTarget {
    var method: HTTPMethod { return .get }
    
    var headers: [String: String]? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    var parameterEncoding: ParameterEncoding { return URLEncoding.default }
    
    var configuration: URLSessionConfiguration { return URLSessionConfiguration.default }
    
    /**
     how to use?
     First put the Certificates of Host in Bundle,
     then:
     let serverTrustPolicies: [String: ServerTrustPolicy] = [
     "test.example.com": .pinCertificates(
     certificates: ServerTrustPolicy.certificates(),
     validateCertificateChain: true,
     validateHost: true
     )
     ]
     return serverTrustPolicies
     */
    var policies: [String : ServerTrustPolicy]? { return nil }
        
    var responseQueue: DispatchQueue? { return nil }
    
    var plugins: [SLPlugin]? { return nil }

    var reachability: NetworkReachabilityManager.Listener? { return nil }
    
    var host: String {
        var host: String = baseURLString
        if host.hasPrefix("https://") {
            host = host.replacingOccurrences(of: "https://", with: "")
        }
        else if host.hasPrefix("http://") {
            host = host.replacingOccurrences(of: "http://", with: "")
        }
        return host
    }
    
    var status: (codeKey: String, successCode: Int, messageKey: String?, dataKeyPath: String?)? { return nil }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
}
