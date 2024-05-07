//
//  En1DictDao.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/7.
//

import Foundation
import SQLite

class DaoDictEn1 {
    
    static let shared = DaoDictEn1()
    
    private let tEn1Dict = Table("dict_en_1")
    private let cId = Expression<Int64>("id")
    private let cCode = Expression<String>("code")
    private let cText = Expression<String>("text")
    private  let cCount = Expression<Int64>("count")
    private  let cCreate = Expression<String>("create")
    
    //get list
    func List(id: Int64, code: String, limit: Int) -> [EntityEn1Dict] {
        var query = tEn1Dict.filter(cId > 0)
        if (id > 0 ) {
            query = query.filter(cId<id)
        }
        
        if (!code.isEmpty) {
            query = query.filter(cCode.glob(code+"*"))
        }
        
        query = query.limit(limit).order(cId.desc)
        
        NSLog(query.expression.description)
        
        var dicts:[EntityEn1Dict] = []
        do {
            
            let ds = try Dao.shared.db?.prepare(query)
            for d in ds! {
                dicts.append( EntityEn1Dict(id:d[cId], code:d[cCode], text:d[cText], count:d[cCount], create:d[cCreate]))
            }
            
        }catch {
            NSLog("[DaoDictEn1]init: "+error.localizedDescription)
        }
        
        return dicts
    }
    
}
