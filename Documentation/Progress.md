## Progress

Return progress when download or upload.

Download Progress

```swift
HTTPBinNetwork.download(HTTPBinDownLoadRequest(), progressClosure: { (progress) in
	debugPrint(progress.currentProgress) //0~1
	debugPrint(progress.currentProgressString) //0%~100%
}) { (resposne) in
                    
}
```

Upload Progress

```swift
HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
	debugPrint(progress.currentProgress) //0~1
    debugPrint(progress.currentProgressString) //0%~100%
}) { (response) in
                        
}
```
