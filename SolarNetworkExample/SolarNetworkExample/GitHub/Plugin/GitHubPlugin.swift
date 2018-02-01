//
//  GitHubPlugin.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubPlugin: SLPlugin {
    
    func willSend(request: SLRequest) {
        debugPrint("willSend request: \(request.URLString)")
        
        //Do whatever you want before request.
    }
    
    func didReceive(response: SLResponse) {
        debugPrint("didReceive response: \(response.request?.URLString ?? "")")

        //Do whatever you want after response.
    }
    
}
