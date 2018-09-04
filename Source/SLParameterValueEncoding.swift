//
//  SLParameterValueEncoding.swift
//  Alamofire
//
//  Created by 温一鸿 on 2018/9/4.
//

import Foundation

public struct SLParameterValueJSONEncoding: ParameterEncoding {
    
    // MARK: Properties
    
    /// Returns a `JSONEncoding` instance with default writing options.
    public static var `default`: SLParameterValueJSONEncoding { return SLParameterValueJSONEncoding() }
    
    /// Returns a `JSONEncoding` instance with `.prettyPrinted` writing options.
    public static var prettyPrinted: SLParameterValueJSONEncoding { return SLParameterValueJSONEncoding(options: .prettyPrinted) }
    
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    // MARK: Initialization
    
    /// Creates a `JSONEncoding` instance using the specified options.
    ///
    /// - parameter options: The options for writing the parameters as JSON data.
    ///
    /// - returns: The new `JSONEncoding` instance.
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }


    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        guard let parameters = parameters else { return urlRequest }

        if let value = parameters.values.first {
            if let string = value as? String {
                if let data = string.data(using: .utf8) {
                    urlRequest.httpBody = data
                }
            }
            else if let array = value as? [Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: array, options: options)
                    urlRequest.httpBody = data
                } catch {
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
                }
            }
        }
        
        return urlRequest
    }
}

public struct SLParameterValuePropertyListEncoding: ParameterEncoding {
    
    /// Returns a default `PropertyListEncoding` instance.
    public static var `default`: SLParameterValuePropertyListEncoding { return SLParameterValuePropertyListEncoding() }
    
    /// Returns a `PropertyListEncoding` instance with xml formatting and default writing options.
    public static var xml: SLParameterValuePropertyListEncoding { return SLParameterValuePropertyListEncoding(format: .xml) }
    
    /// Returns a `PropertyListEncoding` instance with binary formatting and default writing options.
    public static var binary: SLParameterValuePropertyListEncoding { return SLParameterValuePropertyListEncoding(format: .binary) }
    
    /// The property list serialization format.
    public let format: PropertyListSerialization.PropertyListFormat
    
    /// The options for writing the parameters as plist data.
    public let options: PropertyListSerialization.WriteOptions
    
    // MARK: Initialization
    
    /// Creates a `PropertyListEncoding` instance using the specified format and options.
    ///
    /// - parameter format:  The property list serialization format.
    /// - parameter options: The options for writing the parameters as plist data.
    ///
    /// - returns: The new `PropertyListEncoding` instance.
    public init(
        format: PropertyListSerialization.PropertyListFormat = .xml,
        options: PropertyListSerialization.WriteOptions = 0)
    {
        self.format = format
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-plist", forHTTPHeaderField: "Content-Type")
        }
        
        guard let parameters = parameters else { return urlRequest }
        
        if let value = parameters.values.first {
            if let string = value as? String {
                if let data = string.data(using: .utf8) {
                    urlRequest.httpBody = data
                }
            }
            else if let array = value as? [Any] {
                do {
                    let data = try PropertyListSerialization.data(
                        fromPropertyList: array,
                        format: format,
                        options: options
                    )
                    
                    urlRequest.httpBody = data
                } catch {
                    throw AFError.parameterEncodingFailed(reason: .propertyListEncodingFailed(error: error))
                }
            }
        }
        
        return urlRequest
    }
}
