//
//  GitHubSigninRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubSigninRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .put
        path = "/authorizations/clients/\(GitHubAppClientID)"
    }
    
    var client_secret = GitHubAppClientSecret
        
    var scopes = ["repo", "user"]
}
