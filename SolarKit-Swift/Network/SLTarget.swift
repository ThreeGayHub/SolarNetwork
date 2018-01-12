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
    var requestEncoding: ParameterEncoding { get }
 
    /// The target's URLSessionConfiguration.
    var configuration: URLSessionConfiguration { get }
    
    /// The target's serverTrustPolicies
    var policies: [String : ServerTrustPolicy]? { get }
    
    
    //jsonReadingOption
    
    //Plugins
    var plugins: [SLPlugin]? { get }
    
    var reachability: NetworkReachabilityManager.Listener? { get }
    
    /// The target's host.
    var host: String { get }
    
    var status: (codeKey: String, successCode: Int, messageKey: String?, dataKeyPath: String?)? { get }
    
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
    
    var requestEncoding: ParameterEncoding { return URLEncoding.default }
    
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
