//
//  HTTPBinStringParametersRequest.swift
//  SolarNetworkExample
//
//  Created by 温一鸿 on 2018/9/4.
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
//        parameterEncoding = SLParameterValuePropertyListEncoding.default

    }
    
    let anyKey = "anyString"
}
