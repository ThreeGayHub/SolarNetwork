//
//  SLResponse.swift
//
//  Created by wyh on 2018/1/11.
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
    
    public var dataDictionary: [String: Any]? {
        if let dataDictionary = data as? [String: Any] {
            return dataDictionary
        }
        return nil
    }
    
    public var dataArray: [[String: Any]]? {
        if let dataArray = data as? [[String: Any]] {
            return dataArray
        }
        return nil
    }
    
    
    /// JsonObject to Model
    ///
    /// - Parameter Model: Model: Decodable
    /// - Returns: Model
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
        
        var dataString: String? = "nil"
        
        if let data = data {
            let isJson = JSONSerialization.isValidJSONObject(data)
            if isJson {
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted])
                dataString = String(data: jsonData ?? Data(), encoding: .utf8)
            }
            else {
                if let url = destinationURL {
                    dataString = url.absoluteString
                }
                else {
                    dataString = "\(data)"
                }
            }
        }
        
        return """
        
        ------------------------ SLResponse ----------------------
        URL:\(request?.URLString ?? "")
        \(dataString!)
        error:\(String(describing: error))
        ----------------------------------------------------------
        
        """
    }
    
}
