//
//  EnSpellErrorDictDao.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/7.
//

import Foundation
import SQLite

class DaoDictEnSpellError {
    
    static let shared = DaoDictEnSpellError()
    
    private let table = Table("dict_en_spell_error")
    private let cId = Expression<Int64>("id")
    private let cCode = Expression<String>("code")
    private let cText = Expression<String>("text")
    private  let cCount = Expression<Int64>("count")
    private  let cCreate = Expression<String>("create")
    
    //get list
    func List(id: Int64, code: String, limit: Int) -> [EntityEnSpellErrorDict] {
        var query = table.filter(cId > 0)
        if (id > 0 ) {
            query = query.filter(cId<id)
        }
        
        if (!code.isEmpty) {
            query = query.filter(cCode.glob(code))
        }
        
        query = query.limit(limit).order(cId.desc)
        
        NSLog(query.expression.description)
        
        var dicts:[EntityEnSpellErrorDict] = []
        do {
            
            let ds = try Dao.shared.db?.prepare(query)
            for d in ds! {
                dicts.append( EntityEnSpellErrorDict(id:d[cId], code:d[cCode], text:d[cText], count:d[cCount], create:d[cCreate]))
            }
            
        }catch {
            NSLog("[DaoDictEnSpellError]list: "+error.localizedDescription)
        }
        
        return dicts
    }
    
}

