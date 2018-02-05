## Plugin

Modify SLRequest in `willSend` and modify SLResponse in `didReceive`.

#### Modify SLRequest

```swift
func willSend(request: SLRequest) {
    //Do whatever you want before request.
    //Such as Log，Modify SLRequest，Encryption，Signature.
}
```

#### Modify SLResponse

```swift
func didReceive(response: SLResponse) {
    //Do whatever you want after response.
    //Such as Log，Modify SLResponse，Decryption.
}

```

#### Usage

```swift
import SolarNetwork

class GitHubPlugin: SLPlugin {
    
    func willSend(request: SLRequest) {}
    
    func didReceive(response: SLResponse) {}
}

struct GitHubTarget: SLTarget {

    var plugins: [SLPlugin]? {
    
        return [GitHubPlugin(), OtherPligin()]
    }
}
```

