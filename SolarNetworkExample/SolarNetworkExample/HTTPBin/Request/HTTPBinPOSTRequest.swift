//
//  HTTPBinPOSTRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinPOSTRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.method = .post
        self.path = "/post"
    }
    
    let testPOSTProperty = "testPOSTProperty"
    
    var name: String?

}
