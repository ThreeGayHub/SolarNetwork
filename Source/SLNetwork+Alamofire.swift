//
//  SLNetwork+Alamofire.swift
//  SolarNetwork
//
//  Created by wyhazq on 2018/2/6.
//

import Foundation
import Alamofire

public typealias Session = Alamofire.Session
public typealias URLRequestConvertible = Alamofire.URLRequestConvertible

public typealias HTTPHeader = Alamofire.HTTPHeader
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias Request = Alamofire.Request
public typealias DownloadRequest = Alamofire.DownloadRequest
public typealias UploadRequest = Alamofire.UploadRequest
public typealias DataRequest = Alamofire.DataRequest
public typealias DataResponse = Alamofire.DataResponse
public typealias SessionDelegate = Alamofire.SessionDelegate
public typealias Destination = DownloadRequest.Destination
public typealias AFError = Alamofire.AFError
public typealias RequestInterceptor = Alamofire.RequestInterceptor

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding

public typealias Options = Alamofire.DownloadRequest.Options
public typealias MultipartFormData = Alamofire.MultipartFormData

public typealias ServerTrustManager = Alamofire.ServerTrustManager
public typealias ServerTrustEvaluating = Alamofire.ServerTrustEvaluating
public typealias DefaultTrustEvaluator = Alamofire.DefaultTrustEvaluator
public typealias RevocationTrustEvaluator = Alamofire.RevocationTrustEvaluator
public typealias PinnedCertificatesTrustEvaluator = Alamofire.PinnedCertificatesTrustEvaluator
public typealias PublicKeysTrustEvaluator = Alamofire.PublicKeysTrustEvaluator
public typealias CompositeTrustEvaluator = Alamofire.CompositeTrustEvaluator
public typealias DisabledEvaluator = Alamofire.DisabledEvaluator

public typealias NetworkReachabilityManager = Alamofire.NetworkReachabilityManager
public typealias ReachabilityListener = Alamofire.NetworkReachabilityManager.Listener

public let SLHostKey = "Host"
