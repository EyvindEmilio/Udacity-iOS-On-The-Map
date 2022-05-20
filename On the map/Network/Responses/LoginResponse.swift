//
//  LoginResponse.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import Foundation

class LoginResponse: Codable {
    let account: AccountField
    let session: SessionField
    
    enum CodingKeys: String, CodingKey {
        case account
        case session
    }
    
    class AccountField: Codable {
        let registered: Bool
        let key: String
        
        enum CodingKeys: String, CodingKey{
            case registered
            case key
        }
    }
    
    class SessionField: Codable {
        let id: String
        let expiration: String
        
        enum CodingKeys: String, CodingKey{
            case id
            case expiration
        }
    }
}
