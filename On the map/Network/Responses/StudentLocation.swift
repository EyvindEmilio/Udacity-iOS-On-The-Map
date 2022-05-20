//
//  StudentLocation.swift
//  On the map
//
//  Created by Eyvind on 19/5/22.
//

import Foundation

struct StudentLocation: Codable {
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mapString: String
    let mediaURL: String
    let uniqueKey: String
    let objectId: String
    let createdAt: String
    let updatedAt: String
    
    enum CondingKeys: String, CodingKey{
        case firstName = "firstName"
        case lastName = "lastName"
        case longitude = "longitude"
        case latitude = "latitude"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case uniqueKey = "uniqueKey"
        case objectId = "objectId"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}
