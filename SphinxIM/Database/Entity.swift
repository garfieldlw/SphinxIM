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

class EntityEn2Dict: Codable {
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

class EntityEnSpellErrorDict: Codable {
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

class EntityStatistics: Codable {
    var id: Int64
    var code: String
    var text: String
    var type_mode: Int64
    var type_method: Int64
    var type_key: Int64
    var create: String
    
    init(id: Int64, code: String, text: String, type_mode: Int64, type_method: Int64, type_key: Int64, create: String) {
        self.id = id
        self.code = code
        self.text = text
        self.type_mode = type_mode
        self.type_method = type_method
        self.type_key = type_key
        self.create = create
    }
}

class EntityStatisticsData: Codable {
    var date: String
    var count: Int64
   
    init(date: String, count: Int64) {
        self.date = date
        self.count = count
    }
}
