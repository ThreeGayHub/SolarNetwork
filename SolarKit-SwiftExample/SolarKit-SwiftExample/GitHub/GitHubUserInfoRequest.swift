//
//  GitHubUserInfoRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

class GitHubUserInfoRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/users/wyhazq"
    }
    
}
