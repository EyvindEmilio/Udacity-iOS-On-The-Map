//
//  MessageError.swift
//  On the map
//
//  Created by Eyvind on 25/5/22.
//

import Foundation

struct MessageError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
