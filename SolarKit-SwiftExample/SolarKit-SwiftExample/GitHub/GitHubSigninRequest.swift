//
//  GitHubSigninRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

class GitHubSigninRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.method = .put
        self.path = "/authorizations/clients/\(GitHubAppClientID)"
    }
    
    var client_secret = GitHubAppClientSecret
        
    var scopes = ["repo", "user"]
}
