# ![SLNetwork](SLNetwork.png)

![Build Status](https://travis-ci.org/Alamofire/Alamofire.svg?branch=master)

![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

![Platform](https://img.shields.io/cocoapods/p/Alamofire.svg?style=flat)

Elegant network abstraction layer in Swift.



- [Design](#design)
- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
  - **[Base Usage](#base-usage) -** [Target](#target-usage) - [Request](#request-usage) - [Download](#download-usage) - [Upload](#upload-usage) - [Decode](#decode-usage)
  - **[Target](#target)** - Configuration of a Host.
  - **[Request](#request)** - Configuration of a DataRequest.
  - **[Download](#download)** - Configuration of a DownloadRequest or ResumeDownloadRequest.
  - **[Upload](#upload)** - Configuration of a UploadRequest(Data - File - InputStream - FormData).
  - **[Progress](#progress)** - Progress
  - **[Response](#response)** - Decode - Error
  - **[Plugin](#plugin)** - WillSend - DidReceive

---

# Design

**Alamofire** and **Moya** are elegant Swift network frames. They each have their own advantages. When I use them, I always want to combine the advantages of both, make them easy to use and retain their original features. So I wrote the **SolarNetwork**.

**SLNetwork** corresponds to a SessionManager.

**SLTarget** corresponds to a Host, or a set of requests for the same configuration.

**SLRequest**, **SLDownloadRequest**, **SLUploadRequest** corresponds to Request of Data, Download, Upload.

**SLProgress** return progress when download or upload.

**SLResponse** response of a request which you can decode to Dictionary or Model.

**SLPlugin** you can modify SLRequest in `willSend` and modify SLResponse in `didReceive`.

So a complete request process is:

```swift
SLNetwork(SLTarget).request(SLRequest).willSend(SLRequest)
                   .progressClosure(SLProgress)
                   .reponseData(OriginalResponse)
                   .didReceive(SLResponse).decodeTo(Dictionary)
                   .completionClosure(SLResponse)
                   .decodeTo(Model: Decodable).dealWithError
```

In most cases, what you need to concerned about is:

```swift
SLNetwork(SLTarget).request(SLRequest)
                   .progressClosure(SLProgress)
                   .completionClosure(SLResponse)
```

---

# Features

-[x] URL / JSON / plist Parameter Encoding
-[x] Upload File / Data / Stream / MultipartFormData
-[x] Download File using Request or Resume Data
-[x] Authentication with URLCredential
-[x] Upload and Download Progress Closures with Progress
-[x] Dynamically Adapt and Retry Requests
-[x] TLS Certificate and Public Key Pinning
-[x] Network Reachability

---

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.3+
- Swift 3.1+

---

## Communication

- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/alamofire).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

---

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1+ is required to build Alamofire 4.0+.

To integrate SolarNetwork into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SolarNetwork'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ThreeGayHub/SolarNetwork"
```

Run `carthage update` 

If this is your first time using Carthage in the project, you'll need to go through some additional steps as explained [over at Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

---

# Usage

## Base Usage

### Target Usage

```swift
import SolarNetwork

struct HTTPBinTarget: SLTarget {
    var baseURLString: String { return "https://httpbin.org" }
}

let HTTPBinNetwork = SLNetwork(target: HTTPBinTarget())
```

### Request Usage

```swift
import SolarNetwork

//Mark: - GET
class HTTPBinGETRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/get"
    }
    
}

HTTPBinNetwork.request(HTTPBinGETRequest()) { (response) in
    if let dictionary = response.data as? [String: Any] {
                        
    }
    else if let error = response.error {
        //show error
    }
}

//Mark: - POST
class HTTPBinPOSTRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.method = .post
        self.path = "/post"
    }
    
    /**
     properties will encode to parameters by Reflection
     ["userName": "myUserName",
      "password": "myPassword"]
     */
    let userName = "myUserName"
    let password = "myPassword"

}

HTTPBinNetwork.request(HTTPBinPOSTRequest()) { (response) in
    if let dictionary = response.data as? [String: Any] {
                        
    }
    else if let error = response.error {
        //show error
    }
}
```

### Download Usage

```swift
import SolarNetwork

class HTTPBinDownLoadRequest: SLDownloadRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/image/png"
        self.isResume = true //control the download request is resume or not, default is false
    }
}

HTTPBinNetwork.download(HTTPBinDownLoadRequest(), progressClosure: { (progress) in
                    
}) { (resposne) in
                    
}

```

### Upload Usage

```swift
import SolarNetwork

class HTTPBinUploadRequest: SLUploadRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/post"
    }
    
}

let uploadRequest = HTTPBinUploadRequest()
uploadRequest.data = data //data to upload
HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                            
}) { (response) in
                            
}
```

### Decode Usage

```swift
import SolarNetwork

struct User: Decodable {
	var id: Int
	var name: String
	var token: String
}

HTTPBinNetwork.request(UserRequest()) { (response) in
    if let user = response.decode(to: User.self) {
                        
    }
    else if let error = response.error {
        //show error
    }
}
```







