//
//  SLPlugin.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/11.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

public protocol SLPlugin {
    
    func willSend(request: SLRequest)
    
    func didReceive(response: SLResponse)
    
}

extension SLPlugin {
    
    func willSend(request: SLRequest) {}
    
    func didReceive(response: SLResponse) {}
    
}
