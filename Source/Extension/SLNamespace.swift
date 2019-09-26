//
//  SLNamespace.swift
//  SolarNetwork
//
//  Created by wyhazq on 2019/1/25.
//  Copyright © 2019年 SolarNetwork. All rights reserved.
//

/**
 Use `Reactive` proxy as customization point for constrained protocol extensions.
 General pattern would be:
 // 1. Extend Reactive protocol with constrain on Base
 // Read as: Reactive Extension where Base is a SomeType
 extension Reactive where Base: SomeType {
 // 2. Put any specific reactive extension for SomeType here
 }
 With this approach we can have more specialized methods and properties using
 `Base` and not just specialized on common base type.
 */

public struct SLNamespace<Base> {
    /// Base object to extend.
    public let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has reactive extensions.
public protocol SLNamespaceProtocol {
    /// Extended type
    associatedtype SLCompatibleType
    
    /// Reactive extensions.
    static var sl: SLNamespace<SLCompatibleType>.Type { get set }
    
    /// Reactive extensions.
    var sl: SLNamespace<SLCompatibleType> { get set }
}

extension SLNamespaceProtocol {
    /// Reactive extensions.
    public static var sl: SLNamespace<Self>.Type {
        get {
            return SLNamespace<Self>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }
    
    /// Reactive extensions.
    public var sl: SLNamespace<Self> {
        get {
            return SLNamespace(self)
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

import class Foundation.NSObject

extension NSObject: SLNamespaceProtocol { }
