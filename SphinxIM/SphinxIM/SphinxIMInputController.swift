//
//  SphinxIMInputController.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import Cocoa
import InputMethodKit

@objc(IMKitSampleInputController)
class IMKitSampleInputController: IMKInputController {
    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        NSLog(string)
        // get client to insert
        guard let client = sender as? IMKTextInput else {
            return false
        }
        client.insertText(string+string, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        return true
    }
}
