## Download

Configuration of a DownloadRequest or ResumeDownloadRequest.

#### Override the SLDownloadRequest

```swift
import SolarNetwork

class GitHubDownloadRequest: SLDownloadRequest {
    
    override func loadRequest() {
        super.loadRequest()
		
        self.URLString = "http://cdnvue.com/video/rzGHzRA19L/64tBZo"
    }
}
```

#### Usage

```swift
let downloadRequest = GitHubDownloadRequest()
GitHubNetwork.download(downloadRequest, progressClosure: { (progress) in
                    
}) { (response) in
                    
}

//if you want to use resume download
downloadRequest.isResume = true

//if you want to specify the destination URL to receive the file. The default is "/Library/Caches/SLNetwork/Destination/(requestID)"
downloadRequest.destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
```

#### Why can resume download work.

1.Every time begin a resume download request, SolarNetwork cancel the request and save the `Alamofire.Response.resumeData` to cache path when data is first received.  And then send the request again. So it can resume download when the app restart. 

2.It also have other logic to fix the `Alamofire.Response.resumeData` when app crash or user kill the process.

3.After the download is complete, I will check to see if the download file is complete.
