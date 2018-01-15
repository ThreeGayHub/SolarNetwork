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
    
    public let request: SLRequest
    
    public let urlRequest: URLRequest?
    
    public let httpURLResponse: HTTPURLResponse?
    
    public var data: Any?
    
    public var error: NSError?
    
    public var message: String?
    
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
            if let target = self.request.target {
                let data: T = try target.decoder.decode(Model.self, from: decodeData)
                return data
            }
        } catch {
            self.error = error as NSError
        }
        return nil
    }
    
}

extension SLResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        ------------------------ SLResponse ----------------------
        URL:\(request.URLString)
        data:\(data ?? "")
        error:\(String(describing: error))
        ------------------------ SLResponse ----------------------
        """
    }
    
}
