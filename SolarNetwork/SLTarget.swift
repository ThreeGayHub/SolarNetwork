//
//  SLTarget.swift
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

public extension SLTarget {
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
     First get the Certificates of Host:
     openssl s_client -connect test.example.com:443 </dev/null 2>/dev/null | openssl x509 -outform DER > example.cer
     
     then put the Certificates of Host in Bundle.
     
     Example:
     ---------------------------------------------------------
     var policies: [String : ServerTrustPolicy]? {
     let serverTrustPolicies: [String: ServerTrustPolicy] = [
     "test.example.com": .pinCertificates(
     certificates: ServerTrustPolicy.certificates(),
     validateCertificateChain: true,
     validateHost: true
     )
     ]
     return serverTrustPolicies
     }
     ---------------------------------------------------------
     
     if Debug, advice set
     validateCertificateChain: false
     validateHost: false
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
