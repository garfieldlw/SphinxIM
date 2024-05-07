//
//  Entity.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/7.
//

import Foundation

class EntityEn1Dict: Codable {
    var id: Int64
    var code: String
    var text: String
    var count: Int64
    var create: String
    
    init(id: Int64, code: String, text: String, count: Int64, create: String) {
        self.id = id
        self.code = code
        self.text = text
        self.count = count
        self.create = create
    }
}
