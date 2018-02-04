## Download

Configuration of a UploadRequest(Data - File - InputStream - FormData).

Override the SLUploadRequest

```swift
import SolarNetwork

class HTTPBinUploadRequest: SLUploadRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        self.path = "/post"
    }
    
}
```

Upload Data

```swift
let bundle = Bundle.main
let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
do {
    if let path = resourcePath {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let uploadRequest = HTTPBinUploadRequest()
        uploadRequest.data = data
        HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
            
        }) { (response) in
            
        }
    }
}
catch {
    debugPrint(error)
}
```

Upload File

```swift
if let path = resourcePath {
    let uploadRequest = HTTPBinUploadRequest()
    uploadRequest.filePath = path
    HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
        
    }) { (response) in
        
    }
}
```

Upload InputStream

```swift
do {
    if let path = resourcePath {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let inputStream = InputStream(data: data)
        
        let uploadRequest = HTTPBinUploadRequest()
        uploadRequest.inputStream = (inputStream, data.count)
        HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
            
        }) { (response) in
            
        }
    }
}
catch {
    debugPrint(error)
}
```

Upload FormData

```swift
if let path = resourcePath {
    let uploadRequest = HTTPBinUploadRequest()
    uploadRequest.multipartFormDataClosure { (multipartFormData) in
        let url = URL(fileURLWithPath: path)
        multipartFormData.append(url, withName: "SLNetwork")
    }
    
    HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
        
    }) { (response) in
        
    }
}
```

