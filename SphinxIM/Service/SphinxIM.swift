//
//  SphinxIM.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import AppKit
import InputMethodKit

class SphinxIM: NSObject {
    
    static let candidateInserted = Notification.Name("SphinxIM.candidateInserted")
    
    var inputMode: InputMode = .enUS
    
    override init() {
        super.init()
    }
    
    var server: IMKServer = IMKServer.init(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier)
    
    func getCandidates(origin: String, lastCandidate: Candidate?) -> ( [Candidate],  Bool) {
        if origin.count <= 0 {
            return ([], false)
        }
        
        var lastId: Int64 = 0
        
        if let c = lastCandidate {
            lastId = c.id
        }
        
        let  candidates =   DaoDictEn1.shared.List(id: lastId, code: origin, limit: 6)
        let hasNext = true
        let transformed = candidates.map { (candidate) -> Candidate in
            return Candidate(id: candidate.id, code: candidate.code, text: candidate.text, count: candidate.count, type_mode: .enUS ,type_method:.en1)
        }
        return (transformed, hasNext)
    }
    
    static let shared = SphinxIM()
}