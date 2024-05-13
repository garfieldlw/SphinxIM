//
//  StatisticsDao.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/7.
//

import Foundation
import SQLite

class DaoStatistics {
    
    static let shared = DaoStatistics()
    
    private let table = Table("data")
    private let cId = Expression<Int64>("id")
    private let cCode = Expression<String>("code")
    private let cText = Expression<String>("text")
    private let cTypeMode = Expression<Int64>("type_mode")
    private let cTypeMethod = Expression<Int64>("type_method")
    private let cTypeKey = Expression<Int64>("type_key")
    private let cCreate = Expression<String>("create")
    
    public func insert(code: String, text: String, typeMode: Int64, typeMethod: Int64, typeKey: Int64){
        
        let insert = table.insert( cCode <- code, cText <- text, cTypeMode <- typeMode, cTypeMethod <- typeMethod, cTypeKey <- typeKey)
        
        do {
            let ds = try Dao.shared.dbStatistics?.run(insert)
        }catch {
            NSLog("[DaoStatistics]insert: \(error)")
        }
    }
    
    public func queryDataByDate(startDate: Date, endDate: Date) -> [EntityStatisticsData]{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        
        let query = """
        select date, count from
        (select date("create") as date, sum(1) as count from data where date("create") >= "\(start)" and date("create") <= "\(end)" group by date("create"))
        order by date desc;
        """
        
        var data:[EntityStatisticsData] = []
        do {
            let ds = try Dao.shared.dbStatistics?.prepare(query)
            for d in ds! {
                data.append(EntityStatisticsData(date:d[0] as! String, count:d[1] as! Int64))
            }
            
        }catch {
            NSLog("[DaoStatistics]queryDataByDate: \(error)")
        }
        
        return data
    }
    
    public func queryCount() -> Int64{
        let query = table.filter(cId > 0)
        do {
            let count = try Dao.shared.dbStatistics?.scalar(query.count)
            if let c = count {
                return Int64(c)
            }
            
        }catch {
            NSLog("[DaoStatistics]StatisticsQueryCount: \(error)")
        }
        
        return 0
    }
    
}
