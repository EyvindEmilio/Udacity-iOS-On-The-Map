//
//  LoginRequest.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import Foundation

struct LoginRequest: Codable {
    let udacity: CredentialsField
    
    enum CodingKeys: String, CodingKey{
        case udacity
    }
    
    struct CredentialsField: Codable {
        let username: String
        let password: String
        
        enum CodingKeys: String, CodingKey{
            case username
            case password
        }
    }
}
