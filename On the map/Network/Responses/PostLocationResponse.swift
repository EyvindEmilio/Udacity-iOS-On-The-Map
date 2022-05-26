//
//  PostLocation.swift
//  On the map
//
//  Created by Eyvind on 25/5/22.
//

import Foundation

struct PostLocationResponse: Codable {
    let objectId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey{
        case objectId = "objectId"
        case createdAt = "createdAt"
    }
}
