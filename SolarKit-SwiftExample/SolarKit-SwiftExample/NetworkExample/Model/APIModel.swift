//
//  APIModel.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

struct APIModel: Decodable {
    
    var current_user_url: String
    var current_user_authorizations_html_url: String
    var authorizations_url: String
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
 "current_user_url": "https://api.github.com/user",
 "current_user_authorizations_html_url": "https://github.com/settings/connections/applications{/client_id}",
 "authorizations_url": "https://api.github.com/authorizations",
 "code_search_url": "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}",
 "commit_search_url": "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}",
 "emails_url": "https://api.github.com/user/emails",
 "emojis_url": "https://api.github.com/emojis",
 "events_url": "https://api.github.com/events",
 "feeds_url": "https://api.github.com/feeds",
 "followers_url": "https://api.github.com/user/followers",
 "following_url": "https://api.github.com/user/following{/target}",
 "gists_url": "https://api.github.com/gists{/gist_id}",
 "hub_url": "https://api.github.com/hub",
 "issue_search_url": "https://api.github.com/search/issues?q={query}{&page,per_page,sort,order}",
 "issues_url": "https://api.github.com/issues",
 "keys_url": "https://api.github.com/user/keys",
 "notifications_url": "https://api.github.com/notifications",
 "organization_repositories_url": "https://api.github.com/orgs/{org}/repos{?type,page,per_page,sort}",
 "organization_url": "https://api.github.com/orgs/{org}",
 "public_gists_url": "https://api.github.com/gists/public",
 "rate_limit_url": "https://api.github.com/rate_limit",
 "repository_url": "https://api.github.com/repos/{owner}/{repo}",
 "repository_search_url": "https://api.github.com/search/repositories?q={query}{&page,per_page,sort,order}",
 "current_user_repositories_url": "https://api.github.com/user/repos{?type,page,per_page,sort}",
 "starred_url": "https://api.github.com/user/starred{/owner}{/repo}",
 "starred_gists_url": "https://api.github.com/gists/starred",
 "team_url": "https://api.github.com/teams",
 "user_url": "https://api.github.com/users/{user}",
 "user_organizations_url": "https://api.github.com/user/orgs",
 "user_repositories_url": "https://api.github.com/users/{user}/repos{?type,page,per_page,sort}",
 "user_search_url": "https://api.github.com/search/users?q={query}{&page,per_page,sort,order}"
 }

*/
