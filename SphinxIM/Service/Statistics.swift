//
//  Statistics.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/8.
//

import Foundation


class Statistics {
    
    static let shared = Statistics()
    
    init() {
        NSLog("[Statistics] init")
        NotificationCenter.default.addObserver(self, selector: #selector(listener), name: SphinxIM.candidateInserted, object: nil)
    }
    
    @objc func listener(notification: Notification) {
        NSLog("[Statistics] listener: \(notification)")
        guard let candidate = notification.userInfo?["candidate"] as? Candidate else {
            return
        }
        if !Defaults[.enableStatistics] {
            return
        }
        if candidate.type_mode == CandidateTypeMode.placeholder { return }
        let sql = "insert into data(text, type, code, createdAt) values (:text, :type, :code, :createdAt)"
        
    }
}
