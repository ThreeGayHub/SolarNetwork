//
//  HTTPBinPUTRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinPUTRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .put
        path = "/put"
    }
    
    let testPUTProperty = "testPUTProperty"

}
