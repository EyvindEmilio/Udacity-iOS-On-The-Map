//
//  LoginErrorResponse.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import Foundation

struct ErrorResponse: Codable{
    let status: Int
    let error: String
    
    enum CodingKeys: String, CodingKey{
        case status
        case error
    }
}
