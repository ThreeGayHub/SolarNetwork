//
//  HTTPBinPOSTRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinPOSTRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .post
        path = "/post"
//        parameterEncoding = JSONEncoding.default
        
        headers = ["test": "testValue"]
    }
    
    let testPOSTProperty = "testPOSTProperty"
    
    var name: String?
    
    let testBlackListProperty = "testBlackListProperty"

    override var blackList: [String] {
        return ["testBlackListProperty"]
    }
}
