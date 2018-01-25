//
//  SLProgress.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/23.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

public class SLProgress {
    
    public let request: SLRequest

    public var originalProgress: Progress?
    
    public var currentProgress: Double {
        return originalProgress?.fractionCompleted ?? 0
    }
    
    public var currentProgressString: String {
        if let fractionCompleted = originalProgress?.fractionCompleted {
            return String(format: "%.2lf%%", fractionCompleted * 100)
        }
        return ""
    }
    
    init(request: SLRequest) {
        self.request = request
    }
    
}

extension SLProgress: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        ------------------------ SLProgress ----------------------
        URL:\(request.URLString)
        Progress:\(currentProgressString)
        ------------------------ SLProgress ----------------------
        
        """
    }
}
