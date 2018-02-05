## Response

Response of a request which you can decode to JsonObject or Model.

#### Decode to Dictionary

```swift
HTTPBinNetwork.request(GetDictionaryRequest()) { (response) in
    if let dictionary = response.dataDictionary {
                        
    }
    else if let error = response.error {
        //show error
    }
}
```

#### Decode to Array

```swift
HTTPBinNetwork.request(GetArrayRequest()) { (response) in
    if let dictionary = response.dataArray {
                        
    }
    else if let error = response.error {
        //show error
    }
}
```

#### Decode to Model

```swift
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

