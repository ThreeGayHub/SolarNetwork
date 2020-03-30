//
//  HTTPBinStringParametersRequest.swift
//  SolarNetworkExample
//
//  Created by wyhazq on 2018/9/4.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class HTTPBinStringParametersRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .post
        path = "/post"
        parameterEncoding = SLParameterValueJSONEncoding.default

    }
    
    let anyKey = "anyString"
}
