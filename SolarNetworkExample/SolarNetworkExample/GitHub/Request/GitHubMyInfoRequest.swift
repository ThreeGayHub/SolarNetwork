//
//  GitHubMyInfoRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubMyInfoRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        path = "/user"
    }
}
