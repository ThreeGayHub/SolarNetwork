//
//  SLResponse.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/11.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation
import Alamofire

public class SLResponse {
    
    public weak var request: SLRequest?
    
    public let urlRequest: URLRequest?
    
    public let httpURLResponse: HTTPURLResponse?
    
    public var data: Any?
    
    public var error: NSError?
    
    public var message: String?
    
    public var destinationURL: URL?
    
    init(request: SLRequest, urlRequest: URLRequest?, httpURLResponse: HTTPURLResponse?) {
        self.request = request
        self.urlRequest = urlRequest
        self.httpURLResponse = httpURLResponse
    }
    
    public func decode<T: Decodable>(to Model: T.Type) -> T? {
        var decodeData: Data = Data()
        do {
            if let data = self.data as? Data {
                decodeData = data;
            }
            else {
                if let data = self.data {
                    decodeData = try JSONSerialization.data(withJSONObject: data)
                }
            }
            if let target = self.request?.target {
                let data: T = try target.decoder.decode(Model.self, from: decodeData)
                return data
            }
        } catch {
            self.error = error as NSError
            debugPrint(error)
        }
        return nil
    }
    
}

extension SLResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let dataString = destinationURL == nil ? "data:\(data ?? "")" : "destinationURL:\(destinationURL?.absoluteString ?? "")"
        
        return """
        ------------------------ SLResponse ----------------------
        URL:\(request?.URLString ?? "")
        \(dataString)
        error:\(String(describing: error))
        ------------------------ SLResponse ----------------------
        
        """
    }
    
}
