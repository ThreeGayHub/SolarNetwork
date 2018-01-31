//
//  GitHubAuthenticationModel.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

struct GitHubAuthenticationModel: Decodable {
    
    var id: Int
    var url: String
    var app: [String: String]
    
    var token: String
    var hashed_token: String
    var token_last_eight: String
    
    var note: String?
    var note_url: String?

    var created_at: String
    var updated_at: String

    var scopes: [String]
    
    var fingerprint: String?
    
}

/**
{
    "id": 161486498,
    "url": "https://api.github.com/authorizations/161486498",
    "app": {
        "name": "GayHub",
        "url": "https://github.com/ThreeGayHub/SolarKit/GayHub",
        "client_id": "e02a05e02e13bc1d1e51"
    },
    "token": "",
    "hashed_token": "",
    "token_last_eight": "",
    "note": null,
    "note_url": null,
    "created_at": "2018-01-30T02:30:05Z",
    "updated_at": "2018-01-30T02:30:05Z",
    "scopes": [
    "repo",
    "user"
    ],
    "fingerprint": null
}
*/
