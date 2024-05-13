//
//  Dao.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import Foundation
import SQLite

class Dao {
    static let shared = Dao()
    
    var db: Connection?
    var dbStatistics: Connection?
    
    private let upgrade:[String] = []
    private let upgradeStatistics = [
        //data for statistics
        //mode: 1en, 2py
        //method: 1en1, 2en2, 3en spell
        //key: space, enter, number
        """
        CREATE TABLE IF NOT EXISTS "data" (
            "id" INTEGER PRIMARY KEY NOT NULL,
            "code" TEXT NOT NULL,
            "text" TEXT NOT NULL,
            "type_mode" INTEGER NOT NULL,
            "type_method" INTEGER NOT NULL,
            "type_key" INTEGER NOT NULL,
            "create" TEXT NOT NULL DEFAULT (datetime('now'))
        )
        """
    ]
    
    private init () {
        NSLog("[Dao]init")
        do{
            let dir = getDir()
            
            let resourcesDir = Bundle.main.resourceURL?.appendingPathComponent("db.sqlite3")
            let dbPath = dir.appendingPathComponent("db.sqlite3")
            
            if  FileManager().fileExists(atPath: dbPath.relativePath) {
                try FileManager().removeItem(at: dbPath)
            }
            
            try FileManager().copyItem(at:resourcesDir!,to:dbPath)
            
            db = try Connection(dir.relativePath+"/db.sqlite3")
            dbStatistics = try Connection(dir.relativePath+"/db_statistics.sqlite3")
        }catch {
            NSLog("[Dao]init: \(error)")
        }
        
    }
    
    public func InitDB() {
        NSLog("[Dao]InitDB")
        do {
            try upgrade.forEach { sql in
                _ =  try db?.run(sql)
            }
            
            try upgradeStatistics.forEach { sql in
                _ =  try dbStatistics?.run(sql)
            }
        }catch {
            NSLog("[Dao]InitDB: \(error)")
        }
    }
    
    func getDir () -> URL {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "")
        }
        
        let appDir = dir.appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent("db")
        if !FileManager.default.fileExists(atPath: appDir.path) {
            NSLog("create directory")
            try? FileManager.default.createDirectory(
                atPath: appDir.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        return appDir
    }
    
}
