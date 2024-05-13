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
        
        guard let keyCode = notification.userInfo?["key_code"] as? Int64 else {
            return
        }
        
        if !Defaults[.enableStatistics] {
            return
        }
        
        if candidate.type_mode == CandidateTypeMode.placeholder { return }
        
        if candidate.type_method == CandidateTypeMethod.placeholder { return }
        
        DaoStatistics.shared.insert(code: candidate.code, text: candidate.text, typeMode: Int64(candidate.type_mode.rawValue), typeMethod: Int64(candidate.type_method.rawValue), typeKey: keyCode)
    }
}
