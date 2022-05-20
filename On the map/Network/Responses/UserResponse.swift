//
//  UserResponse.swift
//  On the map
//
//  Created by Eyvind on 20/5/22.
//

import Foundation

struct UserResponse: Codable {
    let userName: String
    let lastName: String
    let socialAccounts: [String]
    let websiteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case lastName = "last_name"
        case socialAccounts = "social_accounts"
        case websiteUrl = "website_url"
    }
}
