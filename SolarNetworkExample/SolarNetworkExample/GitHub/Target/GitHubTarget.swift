//
//  GitHubTarget.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

struct GitHubTarget: SLTarget {

    var baseURLString: String = "https://api.github.com"
    
    var IPURLString: String? {
        get {
            return storeIPURLString
        }
        set {
            storeIPURLString = newValue
        }
    }
    
    var parameterEncoding: ParameterEncoding = JSONEncoding.default
    
    var allHostsMustBeEvaluated: Bool = false
    
    var serverEvaluators: [String : ServerTrustEvaluating]? {
        #if DEBUG
        let validateHost = false
        #else
        let validateHost = true
        #endif
        
        let evaluators: [String: ServerTrustEvaluating] = [
            host: PinnedCertificatesTrustEvaluator(validateHost: validateHost)
        ]
        
        return evaluators
    }
    
    var clientTrustPolicy: (secPKCS12Path: String, password: String)? = (secPKCS12Path: Bundle.main.path(forResource: "github", ofType: "p12") ?? "", password: "123456")
    
    var plugins: [SLPlugin]? = [GitHubPlugin()]
    
    var reachabilityListener: ReachabilityListener? {
        return { (status) in
            switch status {
                
            case .unknown:
                debugPrint("unknown")
                
            case .notReachable:
                debugPrint("notReachable")
                
            case .reachable(let connectionType):
                switch connectionType {
                    
                case .ethernetOrWiFi:
                    debugPrint("ethernetOrWiFi")
                    
                case .cellular:
                    debugPrint("cellular")
                    
                }
            }
        }
    }
    
    var storeIPURLString: String?
    
}

//"api.github.com"
//"https://192.30.255.117"

