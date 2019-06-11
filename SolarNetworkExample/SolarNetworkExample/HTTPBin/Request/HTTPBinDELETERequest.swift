//
//  HTTPBinDELETERequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinDELETERequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.method = .delete
        self.path = "/delete"
    }
    
    let testDELETEProperty = "testDELETEProperty"

}
