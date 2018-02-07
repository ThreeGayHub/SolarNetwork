# ![SLNetwork](SLNetwork.png)

![Build Status](https://travis-ci.org/Alamofire/Alamofire.svg?branch=master) ![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SolarNetwork.svg) ![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)  ![Platform](https://img.shields.io/cocoapods/p/SolarNetwork.svg?style=flat)

Elegant network abstraction layer in Swift.



- [Design](#design)
- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
  - [Base Usage](#base-usage) - [Target](#target) - [Request](#request) - [Download](#download) - [Upload](#upload) - [Decode](#decode)
  - [Target](Documentation/Target.md) - Configuration of a Host.
  - [Request](Documentation/Request.md) - Configuration of a DataRequest.
  - [Download](Documentation/Download.md) - Configuration of a DownloadRequest or ResumeDownloadRequest.
  - [Upload](Documentation/Upload.md) - Configuration of a UploadRequest(Data - File - InputStream - FormData).
  - [Progress](Documentation/Progress.md) - Progress
  - [Response](Documentation/Response.md) - Decode - Error
  - [Plugin](Documentation/Plugin.md) - WillSend - DidReceive
- [License](#license)

---

# Design

**Alamofire**和**Moya**都是优雅的网络框架，他们各有其优点。刚开始用Swift做项目时，两个框架都有用过，但慢慢地项目逐渐增大，使用Alamofire时，各种接口和参数难以管理，后来用了Moya，Moya是基于Alamofire的封装，十分优秀。接口和参数很乱的情况稍微好了点，但随着TargetType慢慢增大时，每次看一个接口的信息都感觉很不清晰，太多Switch，case，case，case了……所以一直在想，应该如何结合两者的优点，所以在Alamofire的基础上进行了封装，借鉴了Moya的TargetType和Plugin的设计思想，并保留了Alamofire的部分API。形成了**SolarNetwork**。

**SLNetwork** 对应一个SessionManager，负责Request的发送，Progress和Response的对调。

**SLTarget** 对应一个Host或者一系列具有相同配置请求的配置。

**SLRequest**, **SLDownloadRequest**, **SLUploadRequest** 分别对应Data, Download和Upload，是这3中请求的配置。

**SLProgress** 下载和上传进度的回调。

**SLResponse** 是一个已处理过的Response，你可以进一步选择转换为JsonObject或者Model。

**SLPlugin** 提供了两个切入点，用来在请求发送前修改请求的`willSend` 和 接收到网络回调后修改回调内容的 `didReceive`。

所以整个网络请求的流程为：

```swift
SLNetwork(SLTarget).request(SLRequest).willSend(SLRequest)
                   .progressClosure(SLProgress)
                   .reponseData(OriginalResponse)
                   .didReceive(SLResponse).decodeTo(Dictionary)
                   .completionClosure(SLResponse)
                   .decodeTo(Model: Decodable).dealWithError
```

大多数情况下，你只需要关心的是：

```swift
SLNetwork(SLTarget).request(SLRequest)
                   .progressClosure(SLProgress)
                   .completionClosure(SLResponse)
```

---

# Features

- [x] URL / JSON / plist Parameter Encoding
- [x] Upload File / Data / Stream / MultipartFormData
- [x] Download File using Request or Resume Data
- [x] Authentication with URLCredential
- [x] Upload and Download Progress Closures with Progress
- [x] Dynamically Adapt and Retry Requests
- [x] TLS Certificate and Public Key Pinning
- [x] Network Reachability
- [x] Complete Logger

---

## Requirements

- iOS 8.0+
- Xcode 9+
- Swift 4+

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

> CocoaPods 1.1+ is required.

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

### Target

```swift
import SolarNetwork

struct HTTPBinTarget: SLTarget {
    var baseURLString: String { return "https://httpbin.org" }
}

let HTTPBinNetwork = SLNetwork(HTTPBinTarget())
```

### Request

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
    if let dictionary = response.dataDictionary {
                        
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
     利用反射，将属性自动转换为Parameters，不需要自己组装了
     ["userName": "myUserName",
      "password": "myPassword"]
     */
    let userName = "myUserName"
    let password = "myPassword"

}

HTTPBinNetwork.request(HTTPBinPOSTRequest()) { (response) in
    if let dictionary = response.dataDictionary {
                        
    }
    else if let error = response.error {
        //show error
    }
}
```

### Download

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

### Upload

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

### Decode

In Swift 4, you can use Codable.

```swift
import SolarNetwork

struct User: Decodable { //Swift 4 Codable
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



---

## License

Alamofire is released under the MIT license. [See LICENSE](https://github.com/ThreeGayHub/SolarNetwork/blob/master/LICENSE) for details.

