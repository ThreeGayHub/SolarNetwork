//
//  SLProgress.swift
//
//  Created by wyhazq on 2018/1/23.
//  Copyright © 2018年 SolarNetwork. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public class SLProgress {
    
    public weak var request: SLRequest?

    public var originalProgress: Progress?
    
    
    /// The Request's progress: 0-1
    public var currentProgress: Double {
        return originalProgress?.fractionCompleted ?? 0
    }
    
    /// The Request's progress: 0% - 100%
    public var currentProgressString: String {
        if let fractionCompleted = originalProgress?.fractionCompleted {
            return String(format: "%.0lf%%", fractionCompleted * 100)
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
        URL:\(request?.URLString ?? "")
        Progress:\(currentProgressString)
        ----------------------------------------------------------
        
        """
    }
}
