//
//  SLNetwork+Alamofire.swift
//  Alamofire
//
//  Created by wyh on 2018/2/6.
//

import Foundation
import Alamofire

public typealias SessionManager = Alamofire.SessionManager
public typealias URLRequestConvertible = Alamofire.URLRequestConvertible

internal typealias Request = Alamofire.Request
internal typealias DownloadRequest = Alamofire.DownloadRequest
internal typealias UploadRequest = Alamofire.UploadRequest
internal typealias DataRequest = Alamofire.DataRequest
internal typealias DataResponse = Alamofire.DataResponse
internal typealias SessionDelegate = Alamofire.SessionDelegate
internal typealias MultipartFormDataEncodingResult = SessionManager.MultipartFormDataEncodingResult

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding
public typealias PropertyListEncoding = Alamofire.PropertyListEncoding

public typealias DownloadOptions = Alamofire.DownloadRequest.DownloadOptions
public typealias MultipartFormData = Alamofire.MultipartFormData

public typealias ServerTrustPolicyManager = Alamofire.ServerTrustPolicyManager
public typealias ServerTrustPolicy = Alamofire.ServerTrustPolicy

internal typealias NetworkReachabilityManager = Alamofire.NetworkReachabilityManager
public typealias Listener = Alamofire.NetworkReachabilityManager.Listener

public let SLHostKey = "Host"
