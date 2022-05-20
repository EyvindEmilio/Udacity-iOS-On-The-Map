//
//  PostLocation.swift
//  On the map
//
//  Created by Eyvind on 20/5/22.
//

import Foundation

struct PostLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case uniqueKey = "uniqueKey"
        case firstName = "firstName"
        case lastName = "lastName"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case latitude = "latitude"
        case longitude = "longitude"
    }
}
