//
//  SphinxIMInputServer.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import Foundation

extension SphinxIMInputController {
    func previousClientHandler() {
        clean()
    }

    override func activateServer(_ sender: Any!) {
        NSLog("[SphinxIMInputController] activate server: \(client()?.bundleIdentifier() ?? sender.debugDescription)")

        previousClientHandler()

        CandidatesController.shared.inputController = self
        
    }
    override func deactivateServer(_ sender: Any!) {
        insertOriginText()
        clean()
        NSLog("[SphinxIMInputController] deactivate server: \(client()?.bundleIdentifier() ?? "no client deactivate")")
    }
}
