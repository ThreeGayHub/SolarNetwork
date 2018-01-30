//
//  HTTPBinPUTRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

class HTTPBinPUTRequest: SLRequest {
    
    override func loadRequest() {
        self.path = "/put"
        self.method = .put
    }
    
    let testPUTProperty = "testPUTProperty"

}
