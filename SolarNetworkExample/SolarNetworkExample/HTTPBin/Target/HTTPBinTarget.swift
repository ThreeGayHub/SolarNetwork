//
//  HTTPBinTarget.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import SolarNetwork

struct HTTPBinTarget: SLTarget {
    var baseURLString: String { return "https://httpbin.org" }
}
