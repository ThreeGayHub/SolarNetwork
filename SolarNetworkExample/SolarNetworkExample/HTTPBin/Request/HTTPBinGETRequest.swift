//
//  HTTPBinGETRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinGETRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/get"
    }
    
    let testGETProperty = "testGETProperty"

}
