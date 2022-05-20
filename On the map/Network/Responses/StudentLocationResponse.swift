//
//  StudentLocationResponse.swift
//  On the map
//
//  Created by Eyvind on 19/5/22.
//

import Foundation

struct StudemtLocationResponse: Codable {
    let results: [StudentLocation]
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
    }
}













