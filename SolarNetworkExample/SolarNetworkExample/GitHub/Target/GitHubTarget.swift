//
//  GitHubTarget.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork
import Alamofire

struct GitHubTarget: SLTarget {
    var baseURLString: String { return "https://api.github.com" }
    
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    var policies: [String : ServerTrustPolicy]? {
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "api.github.com": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        return serverTrustPolicies
        
    }
}
