//
//  FileManager+Extension.swift
//  SolarNetwork
//
//  Created by wyhazq on 2019/9/23.
//

import Foundation

extension SLNamespace where Base == FileManager {

    static func createDirectory(at URL: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) {
        if !fileExists(at: URL) {
            do {
                try FileManager.default.createDirectory(at: URL, withIntermediateDirectories: createIntermediates, attributes: attributes)
            }
            catch {
                debugPrint("FileManager.createDirectoryError:\(error)")
            }
        }
    }
    
    static func removeItem(at URL: URL) {
        if fileExists(at: URL) {
            do {
                try FileManager.default.removeItem(at: URL)
            }
            catch {
                debugPrint("FileManager.removeItemError:\(error)")
            }
        }
    }
    
    static func fileExists(at URL: URL) -> Bool {
        let path = URL.absoluteString.replacingOccurrences(of: "file://", with: "")
        return FileManager.default.fileExists(atPath: path)
    }
    
}
