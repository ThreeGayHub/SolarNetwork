//
//  HTTPBinDownLoadRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

class HTTPBinDownLoadRequest: SLDownloadRequest {
    
    override func loadRequest() {
        self.path = "/image/png"
    }
}