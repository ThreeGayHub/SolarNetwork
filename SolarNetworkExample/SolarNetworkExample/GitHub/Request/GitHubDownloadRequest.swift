//
//  GitHubDownloadRequest.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/31.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

class GitHubDownloadRequest: SLDownloadRequest {
    
    override func loadRequest() {
        self.URLString = "http://cdnvue.com/video/rzGHzRA19L/64tBZo"
    }
    
//GitHub is not support resume download
//    "https://codeload.github.com/raywenderlich/swift-algorithm-club/zip/master"
    
    
//    "https://video.cdnvue.com/uploads/1746405174696532785/video/asBF81t"
//    "https://video.cdnvue.com/uploads/812734077666566393/video/ar9RkFL"
//    "http://cdnvue.com/video/rzGHzRA19L/64tBZo"
//    "https://video.cdnvue.com/uploads/-3518274263869595162/video/asBqjiJ"
//    "https://video.cdnvue.com/uploads/6921208716048356378/video/asCjvhf"
}
