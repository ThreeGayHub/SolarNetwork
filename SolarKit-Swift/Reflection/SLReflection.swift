//
//  SLReflection.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/8.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

public protocol SLReflection {
    func toJSONObject() -> Any?
    
    func blackList() -> [String]?
}

extension SLReflection {
    public func blackList() -> [String]? { return nil }
}

extension SLReflection {
    public func toJSONObject() -> Any? {
        let mirror = Mirror(reflecting: self)
        if let _ = mirror.displayStyle {
            var dict: [String: Any] = [:]
            for (optionalKey, value) in mirror.children {
                if let propertyNameString = optionalKey, let reflectionValue = value as? SLReflection {
                    if let blackList = blackList(), blackList.contains(propertyNameString) {
                        continue
                    }
                    dict[propertyNameString] = reflectionValue.toJSONObject()
                }
            }
            return dict
        }
        return self
    }
}

extension Optional: SLReflection {
    public func toJSONObject() -> Any? {
        if let x = self {
            if let value = x as? SLReflection {
                return value.toJSONObject()
            }
        }
        return nil
    }
}

extension Array: SLReflection {
    public func toJSONObject() -> Any? {
        let mirror = Mirror(reflecting: self)
        var array: [Any] = []
        for (_, value) in mirror.children {
            if let reflectionValue = value as? SLReflection, let obj = reflectionValue.toJSONObject() {
                array.append(obj)
            }
        }
        return array
    }
}

extension Dictionary: SLReflection {
    public func toJSONObject() -> Any? {
        var dict: [String: Any] = [:]
        for (key, obj) in self {
            if let keyString = key as? String, let reflectionValue = obj as? SLReflection {
                dict[keyString] = reflectionValue.toJSONObject()
            }
        }
        return dict
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
