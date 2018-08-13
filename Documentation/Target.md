## Target

You can use Target to Configuration of a Host or a set of Requests for the same configuration.

```swift
import SolarNetwork

struct GitHubTarget: SLTarget {
    /// Required: You have to specify baseURLString.
    var baseURLString: String { return "https://api.github.com" }
    
    /// Optional: You can specify the default ParameterEncoding of the host. e.g.: URLEncoding, JSONEncoding, PropertyListEncoding or Custom ParameterEncoding. The default is URLEncoding.default.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }

    /// Optional: 
    /**
    Optional: The default is nil.
     
    You can specify the ServerTrustPolicy of the host. This can improve the difficulty of Charles view all of the HTTP and SSL / HTTPS traffic between machine and the Internet. 
     
    First get the Certificates of Host:
    openssl s_client -connect api.github.com:443 </dev/null 2>/dev/null | openssl x509 -outform DER > github.cer
     
    Then put the Certificates of Host in MainBundle.
    Last, specify ServerTrustPolicy like this.
    */
    var serverTrustPolicies: [String : ServerTrustPolicy]? {
        
        #if DEBUG
            let validateCertificateChain = false
            let validateHost = false
        #else
            let validateCertificateChain = true
            let validateHost = true
        #endif
        
        let policies: [String: ServerTrustPolicy] = [
            host: .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: validateCertificateChain,
                validateHost: validateHost
            )
        ]
        return policies
        
    }
    
    /** Optional: 
     how to use?
     First put the p12 of client in MainBundle.
     */
   	var clentTrustPolicy: (secPKCS12Name: String, secPKCS12Password: String)? {
        return (secPKCS12Name: "github", secPKCS12Password: "123456")
    }
}
```

#### Usage

```swift
let GitHubNetwork = SLNetwork(GitHubTarget())
```
#### You can also specify the following properties if you need.

```swift
struct GitHubTarget: SLTarget {
	/// Optional: You can specify the default HTTPMethod of the host, so you will not have to specify the method of a request each time. The default is .get.
    var method: HTTPMethod { return .get }
    
    /// Optional: You can specify the default Headers of the host, and you can change the header if you need. The default is nil.
    var storeHeader: [String : String]? = ["TestHeaderKey": "TestHeaderValue"]
    var headers: [String : String]? {
        get {
            return storeHeader
        }
        set {
            storeHeader = newValue
        }
    }
    
    /// Optional: You can specify the URLSessionConfiguration of the host. The default is this.
    var configuration: URLSessionConfiguration { return URLSessionConfiguration.default }
    
    /// Optional: SolarNetwork resposne in a background serial queue, you can specify the responseQueue if you need. The default is nil.
    var responseQueue: DispatchQueue? { return nil }

    /// Optional: You can specify the Plugins of the host. The default is nil.
    var plugins: [SLPlugin]? {
    
        return [GitHubPlugin(), OtherPligin()]
    }
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
    
    /// Optional: The target's debugPrint Switch, default is on.
    var enableLog: Bool { return true }
}
```

#### [Pre-populate the DNS cache(HTTPS直连IP、防止DNS劫持)](https://github.com/AFNetworking/AFNetworking/issues/2954)

```swift
struct GitHubTarget: SLTarget {

    var baseURLString: String { return "https://api.github.com" }
    
    var IPURLString: String? {
        get {
            return storeIPURLString
        }
        set {
            storeIPURLString = newValue
        }
    }
}

//after get ip of domain Such as the use HTTPDNS，then
GitHubNetwork.target.IPURLString = "https://IP"
```