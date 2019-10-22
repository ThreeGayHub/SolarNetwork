//
//  SLResumeData.swift
//  SolarNetwork
//
//  Created by wyhazq on 2019/9/23.
//
//  Extend form Tiercel

import UIKit

private let NSURLSessionResumeInfoVersion: String = "NSURLSessionResumeInfoVersion"
private let NSURLSessionResumeCurrentRequest: String = "NSURLSessionResumeCurrentRequest"
private let NSURLSessionResumeOriginalRequest: String = "NSURLSessionResumeOriginalRequest"
private let NSURLSessionResumeByteRange: String = "NSURLSessionResumeByteRange"
private let NSURLSessionResumeInfoTempFileName: String = "NSURLSessionResumeInfoTempFileName"
private let NSURLSessionResumeInfoLocalPath: String = "NSURLSessionResumeInfoLocalPath"
private let NSURLSessionResumeBytesReceived: String = "NSURLSessionResumeBytesReceived"

private let NSTemporaryPath: String = NSTemporaryDirectory()


class SLResumeData {
    
    static func data(of url: URL) -> Data? {
        guard FileManager.sl.fileExists(at: url) else { return nil }
        
        do {
            let resumeData = try Data(contentsOf: url)
            if isValid(of: resumeData) {
                return handleResumeData(resumeData)
            }
            
            guard var resumeDict = dictionary(of: resumeData), let tempFileURL = tmpFileURL(of: resumeData), let tempFileData = tmpFileData(of: tempFileURL) else { return nil }
            
            // fix the resumeData after App crash or App close
            resumeDict[NSURLSessionResumeBytesReceived] = tempFileData.count
            guard let data = tmpFileData(of: resumeDict) else { return nil }
            return handleResumeData(data)
            
        } catch {
            debugPrint("ResumeDataInitError:\(error)")
        }
        
        return nil
    }
    
    static func tmpFileURL(of data: Data) -> URL? {
        guard let tmpFileName = tmpFileName(of: data) else { return nil }
        
        let tmpFilePath = NSTemporaryPath + tmpFileName
        guard FileManager.default.fileExists(atPath: tmpFilePath) else { return nil }
        
        return URL(fileURLWithPath: tmpFilePath)
    }
    
    static func dictionary(of data: Data) -> [String: Any]? {
        var dictionary: [String: Any]?
        if #available(OSX 10.11, iOS 9.0, *) {
            let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
            
            do {
                if let dict = try keyedUnarchiver.decodeTopLevelObject(forKey: "NSKeyedArchiveRootObjectKey") as? [String: Any] {
                    dictionary = dict
                }
                if dictionary == nil {
                    if let dict = try keyedUnarchiver.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? [String: Any] {
                        dictionary = dict
                    }
                }
            } catch {
                debugPrint("ResumeData-NSKeyedUnarchiverError:\(error)")
            }
            keyedUnarchiver.finishDecoding()
        }
        
        if dictionary == nil {
            do {
                var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml
                if let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamt) as? [String: Any] {
                    dictionary = dict
                }
            } catch {
                debugPrint("ResumeData-PropertyListSerializationError:\(error)")
            }
        }
        
        return dictionary
    }
    
    private static func handleResumeData(_ data: Data) -> Data? {
        if #available(iOS 11.3, *) {
            return data
        } else if #available(iOS 11.0, *) {
            // fix 11.0 - 11.2 bug
            return deleteResumeByteRange(data)
        } else if #available(iOS 10.2, *) {
            return data
        } else if #available(iOS 10.0, *) {
            // fix 10.0 - 10.1 bug
            return correctResumeData(data)
        } else {
            return data
        }
    }
    
    private static func tmpFileData(of url: URL) -> Data? {
        do {
            let tempFileData = try Data(contentsOf: url)
            return tempFileData
        } catch {
            debugPrint("TempFileDataInitError:\(error)")
        }
        return nil
    }
    
    private static func tmpFileData(of dictionary: [String : Any]) -> Data? {
        do {
            let propertyListForamt = PropertyListSerialization.PropertyListFormat.binary
            let resumeData: Data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: propertyListForamt, options: 0)
            return resumeData
        }
        catch {
            debugPrint("PropertyListSerialization.dataError:\(error)")
        }
        return nil
    }
    
    private static func tmpFileName(of data: Data) -> String? {
        guard let resumeDictionary = dictionary(of: data), let version = resumeDictionary[NSURLSessionResumeInfoVersion] as? Int else { return nil }
        if version > 1 {
            return resumeDictionary[NSURLSessionResumeInfoTempFileName] as? String
        } else {
            guard let path = resumeDictionary[NSURLSessionResumeInfoLocalPath] as? String else { return nil }
            let url = URL(fileURLWithPath: path)
            return url.lastPathComponent
        }
    }
    
    /// fix 11.0 - 11.2 resumeData bug
    ///
    /// - Parameter data:
    /// - Returns:
    private class func deleteResumeByteRange(_ data: Data) -> Data? {
        guard var resumeDictionary = dictionary(of: data) else { return nil }
        resumeDictionary.removeValue(forKey: NSURLSessionResumeByteRange)
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    /// fix 10.0 - 10.1 resumeData bug: https://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10/39347461#39347461
    ///
    /// - Parameter data:
    /// - Returns:
    private class func correctResumeData(_ data: Data) -> Data? {
        guard var resumeDictionary = dictionary(of: data) else { return nil }
        
        resumeDictionary[NSURLSessionResumeCurrentRequest] = correct(requestData: resumeDictionary[NSURLSessionResumeCurrentRequest] as? Data)
        resumeDictionary[NSURLSessionResumeOriginalRequest] = correct(requestData: resumeDictionary[NSURLSessionResumeOriginalRequest] as? Data)
        
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    private static func correct(requestData data: Data?) -> Data? {
        guard let data = data else {
            return nil
        }
        if NSKeyedUnarchiver.unarchiveObject(with: data) != nil {
            return data
        }
        guard let archive = (try? PropertyListSerialization.propertyList(from: data, options: [.mutableContainersAndLeaves], format: nil)) as? NSMutableDictionary else {
            return nil
        }
        // Rectify weird __nsurlrequest_proto_props objects to $number pattern
        var k = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "$\(k)") != nil {
            k += 1
        }
        var i = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_prop_obj_\(i)") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_prop_obj_\(i)"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_prop_obj_\(i)")
                arr?[1] = dic
                archive["$objects"] = arr
            }
            i += 1
        }
        if ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_props") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_props"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_props")
                arr?[1] = dic
                archive["$objects"] = arr
            }
        }
        
        if let obj = (archive["$top"] as? NSMutableDictionary)?.object(forKey: "NSKeyedArchiveRootObjectKey") as AnyObject? {
            (archive["$top"] as? NSMutableDictionary)?.setObject(obj, forKey: NSKeyedArchiveRootObjectKey as NSString)
            (archive["$top"] as? NSMutableDictionary)?.removeObject(forKey: "NSKeyedArchiveRootObjectKey")
        }
        // Reencode archived object
        let result = try? PropertyListSerialization.data(fromPropertyList: archive, format: PropertyListSerialization.PropertyListFormat.binary, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    private static func count(ofNSURLSessionResumeBytesReceived data: Data) -> Int {
        guard let resumeDict = dictionary(of: data), let count = resumeDict[NSURLSessionResumeBytesReceived] as? Int else { return 0 }
        return count
    }
    
    private static func isValid(of data: Data) -> Bool {
        let dataCount = count(ofNSURLSessionResumeBytesReceived: data)
        guard let tmpFileURL = tmpFileURL(of: data), let tmpFileData = tmpFileData(of: tmpFileURL) else {
            return false
        }
        return tmpFileData.count == dataCount
    }
    
}

