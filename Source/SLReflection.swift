//
//  SLReflection.swift
//
//  Created by wyhazq on 2018/1/8.
//  Copyright © 2018年 SolarKit. All rights reserved.
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

public protocol SLReflection {
    
    /// model to jsonObject
    var jsonObject: Any? { get }
    
    
    /// properties of model which don't encode to jsonObject
    var blackList: [String] { get }
}

extension SLReflection {
    
    public var blackList: [String] { return [] }

}

extension SLReflection {
    public var jsonObject: Any? {
        let mirror = Mirror(reflecting: self)
        if mirror.children.count > 0, let _ = mirror.displayStyle {
            var dict: [String: Any] = [:]
            for (optionalKey, value) in mirror.children {
                if let propertyNameString = optionalKey, let reflectionValue = value as? SLReflection {
                    if blackList.contains(propertyNameString) {
                        continue
                    }
                    dict[propertyNameString] = reflectionValue.jsonObject
                }
            }
            return dict.count > 0 ? dict : nil
        }
        return self
    }
}

extension Optional: SLReflection {
    public var jsonObject: Any? {
        if let x = self {
            if let value = x as? SLReflection {
                return value.jsonObject
            }
        }
        return nil
    }
}

extension Array: SLReflection {
    public var jsonObject: Any? {
        let mirror = Mirror(reflecting: self)
        if mirror.children.count > 0 {
            var array: [Any] = []
            for (_, value) in mirror.children {
                if let reflectionValue = value as? SLReflection, let obj = reflectionValue.jsonObject {
                    array.append(obj)
                }
            }
            return array.count > 0 ? array : nil
        }
        return self
    }
}

extension Dictionary: SLReflection {
    public var jsonObject: Any? {
        if self.count > 0 {
            var dict: [String: Any] = [:]
            for (key, obj) in self {
                if let keyString = key as? String, let reflectionValue = obj as? SLReflection {
                    dict[keyString] = reflectionValue.jsonObject
                }
            }
            return dict.count > 0 ? dict : nil
        }
        return self
    }
}

extension Bool: SLReflection {}

extension Int: SLReflection {}
extension Int8: SLReflection {}
extension Int16: SLReflection {}
extension Int32: SLReflection {}
extension Int64: SLReflection {}

extension Float: SLReflection {}
//extension Float80: SLReflection {}
extension Double: SLReflection {}
extension Decimal: SLReflection {}

extension String: SLReflection {}
