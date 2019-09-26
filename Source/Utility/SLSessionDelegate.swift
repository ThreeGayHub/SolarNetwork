//
//  SLSessionDelegate.swift
//  Alamofire
//
//  Created by 温一鸿 on 2019/9/26.
//

import Foundation

class SLSessionDelegate: SessionDelegate {
    
    open var taskDidReceiveChallenge: ((URLSession, URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let taskDidReceiveChallenge = taskDidReceiveChallenge {
            //ServerTrust(HTTPS IP direct) && ClientCertificate
            if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host.sl.isIP) || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                let result = taskDidReceiveChallenge(session, task, challenge)
                completionHandler(result.0, result.1)
                return
            }            
        }
        
        super.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
}
