//
//  String+SolarNetwork.swift
//  Alamofire
//
//  Created by 温一鸿 on 2019/9/23.
//

import Foundation

extension String: SLNamespaceProtocol {}

extension SLNamespace where Base == String {

    var isIP: Bool {
        if let char = base.first {
            let zero: Character = "0"
            let nine: Character = "9"
            if char >= zero && char <= nine {
                return true
            }
        }
        
        return false;
    }
    
}
