## Target

You can use Target to Configuration of a Host or a set of Requests for the same configuration.

```swift
import SolarNetwork
import Alamofire

struct GitHubTarget: SLTarget {
    /// Required: You have to specify baseURLString.
    var baseURLString: String { return "https://api.github.com" }
    
    /// Optional: You can specify the default HTTPMethod of the host, so you will not have to specify the method of a request each time. The default is .get.
    var method: HTTPMethod { return .get }

    /// Optional: You can specify the default Headers of the host, and you can change the header if you need. The default is nil.
    var headers: [String : String]? {
        get {
            return storeHeader
        }
        set {
            storeHeader = newValue
        }
    }
    
    /// Optional: You can specify the default ParameterEncoding of the host. e.g.: URLEncoding, JSONEncoding, PropertyListEncoding or Custom ParameterEncoding. The default is URLEncoding.default.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Optional: You can specify the URLSessionConfiguration of the host. The default is this.
    var configuration: URLSessionConfiguration { return URLSessionConfiguration.default }

    /// Optional: 
    /**
    Optional: The default is nil.
     
    You can specify the ServerTrustPolicy of the host. This can improve the difficulty of Charles view all of the HTTP and SSL / HTTPS traffic between machine and the Internet. 
     
    First get the Certificates of Host:
    openssl s_client -connect test.example.com:443 </dev/null 2>/dev/null | openssl x509 -outform DER > example.cer
     
    Then put the Certificates of Host in Bundle.
    Last, specify ServerTrustPolicy like this.
    */
    var policies: [String : ServerTrustPolicy]? {
        
        #if DEBUG
            let validateCertificateChain = false
            let validateHost = false
        #else
            let validateCertificateChain = true
            let validateHost = true
        #endif
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            host: .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: validateCertificateChain,
                validateHost: validateHost
            )
        ]
        return serverTrustPolicies
        
    }
    
    /// Optional: SolarNetwork resposne in a background serial queue, you can specify the responseQueue if you need. The default is nil.
    var responseQueue: DispatchQueue? { return nil }

    /// Optional: You can specify the Plugins of the host. The default is nil.
    var plugins: [SLPlugin]? { return nil }
    
    /// Optional: You can observe the reachability of the host. The default is nil.
    var reachability: NetworkReachabilityManager.Listener? {
        return { (status) in
            switch status {
            case .unknown:
                debugPrint("unknown")
            case .notReachable:
                debugPrint("notReachable")
            case .reachable(.wwan):
                debugPrint("wwan")
            case .reachable(.ethernetOrWiFi):
                debugPrint("ethernetOrWiFi")
            }
        }
    }
    
    /// Read only. You should not specify it. The default is this.
    var host: String {
        var host: String = baseURLString
        if host.hasPrefix("https://") {
            host = host.replacingOccurrences(of: "https://", with: "")
        }
        else if host.hasPrefix("http://") {
            host = host.replacingOccurrences(of: "http://", with: "")
        }
        return host
    }
    
    /**
     Optional: The default is nil.
     
     In most cases, the response json like this:
     {
     "code" : 1,
     "message" : "succeed",
     "data" : {
        //json
     }
     }
     
     So, you can specify status like this.
     If response isn't the case, you don't need to specify it.
     */
    var status: (codeKey: String, successCode: Int, messageKey: String?, dataKeyPath: String?)? {
        return (codeKey: "code", successCode:1, messageKey:"message", dataKeyPath:"data")
    }
    
    /// Optional: You can specify the JSONDecoder of the host. The default is this.
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
    var storeHeader: [String : String]? = ["TestHeaderKey": "TestHeaderValue"]
}
```

Usage

```swift

let GitHubNetwork = SLNetwork(GitHubTarget())

```