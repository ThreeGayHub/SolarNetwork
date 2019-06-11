//
//  GitHubSignoutRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubSignoutRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .delete
        path = "/applications" + "/\(GitHubAppClientID)" + "/tokens/"
        basicAuthentication = (GitHubAppClientID, GitHubAppClientSecret)
    }
}
