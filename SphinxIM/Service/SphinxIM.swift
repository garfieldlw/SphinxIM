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
    
    func getCandidates(origin: String, lastCandidate: Candidate?, limit: Int) -> [Candidate] {
        if origin.count <= 0 {
            return []
        }
        
        var method = CandidateTypeMethod.enSpellError
        var lastId: Int64 = 0
        if let c = lastCandidate {
            method = c.type_method
            lastId = c.id
        }
        
        var transformed:[Candidate] = []
        if method == CandidateTypeMethod.enSpellError {
            let  candidates =   DaoDictEnSpellError.shared.List(id: lastId, code: origin, limit: limit)
            _ = candidates.map { (candidate)  in
                let temp =  Candidate(id: candidate.id, code: candidate.code, text: candidate.text, count: candidate.count, type_mode: .enUS ,type_method:.en1)
                transformed.append(temp)
            }
        }
        
        if (method == CandidateTypeMethod.enSpellError && transformed.count < limit) || method == CandidateTypeMethod.en1 {
            let  candidates =   DaoDictEn1.shared.List(id: lastId, code: origin, limit: limit - transformed.count)
            _ = candidates.map { (candidate)  in
                let temp =  Candidate(id: candidate.id, code: candidate.code, text: candidate.text, count: candidate.count, type_mode: .enUS ,type_method:.en1)
                transformed.append(temp)
            }
        }
        
        if method == CandidateTypeMethod.en2 {
            let  candidates =   DaoDictEn2.shared.List(id: lastId, code: origin, limit: limit)
            _ = candidates.map { (candidate)  in
                let temp =  Candidate(id: candidate.id, code: candidate.code, text: candidate.text, count: candidate.count, type_mode: .enUS ,type_method:.en1)
                transformed.append(temp)
            }
        }
        
        return transformed
    }
    
    static let shared = SphinxIM()
}
