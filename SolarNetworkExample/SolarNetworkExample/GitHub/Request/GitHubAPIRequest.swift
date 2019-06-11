//
//  GitHubAPIRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubAPIRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        parameterEncoding = URLEncoding.default
    }
    
    let client_id: String = GitHubAppClientID
    let client_secret: String = GitHubAppClientSecret

}
