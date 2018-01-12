//
//  APIModel.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

struct APIModel: Decodable {
    
    var current_user_url: String?
    var current_user_authorizations_html_url: String?
    var authorizations_url: String?
    var code_search_url: String?
    var commit_search_url: String?
    var emails_url: String?
    var emojis_url: String?
    var events_url: String?
    var feeds_url: String?
    var followers_url: String?
    var following_url: String?
    var gists_url: String?
    var hub_url: String?
    var issue_search_url: String?
    var issues_url: String?
    var keys_url: String?
    var notifications_url: String?
    var organization_repositories_url: String?
    var organization_url: String?
    var public_gists_url: String?
    var rate_limit_url: String?
    var repository_url: String?
    var repository_search_url: String?
    var current_user_repositories_url: String?
    var starred_url: String?
    var starred_gists_url: String?
    var team_url: String?
    var user_url: String?
    var user_organizations_url: String?
    var user_repositories_url: String?
    var user_search_url: String?

}

/**

{
    "login": "wyhazq",
    "id": 4343342,
    "avatar_url": "https://avatars2.githubusercontent.com/u/4343342?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/wyhazq",
    "html_url": "https://github.com/wyhazq",
    "followers_url": "https://api.github.com/users/wyhazq/followers",
    "following_url": "https://api.github.com/users/wyhazq/following{/other_user}",
    "gists_url": "https://api.github.com/users/wyhazq/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/wyhazq/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/wyhazq/subscriptions",
    "organizations_url": "https://api.github.com/users/wyhazq/orgs",
    "repos_url": "https://api.github.com/users/wyhazq/repos",
    "events_url": "https://api.github.com/users/wyhazq/events{/privacy}",
    "received_events_url": "https://api.github.com/users/wyhazq/received_events",
    "type": "User",
    "site_admin": false,
    "name": null,
    "company": null,
    "blog": "",
    "location": null,
    "email": null,
    "hireable": null,
    "bio": null,
    "public_repos": 12,
    "public_gists": 0,
    "followers": 2,
    "following": 4,
    "created_at": "2013-05-05T02:37:47Z",
    "updated_at": "2018-01-05T01:57:04Z"
}

*/
