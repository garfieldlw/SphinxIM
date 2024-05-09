//
//  SphinxIMInputController.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import SwiftUI
import InputMethodKit

typealias NotificationObserver = (name: Notification.Name, callback: (_ notification: Notification) -> Void)

class SphinxIMInputController: IMKInputController {
    private var _candidates: [Candidate] = []
    
    private var _candidatesMap: [Int: [Candidate]] = [:]
    
    private var _lastInputIsNumber = false
    
    private var _lastInputText = ""
    
    deinit {
        NSLog("[SphinxIMInputController] deinit")
        close()
    }
    
    private var _originalString = "" {
        didSet {
            if self._curPage > 0 {
                self._curPage = 0
            }
            
            NSLog("[SphinxIMInputController] original changed: \(self._originalString), refresh window")
            
            self.markText()
            
            self._originalString.count > 0 ? self._curPage = 1 : CandidatesController.shared.close()
        }
    }
    
    private var _curPage: Int = 0 {
        didSet {
            if self._curPage == 0 {
                self._candidates = []
                self._candidatesMap = [:]
                return
            }
            
            if oldValue == self._curPage {
                return
            }
            
            NSLog("[SphinxIMInputController] page changed")
            
            if oldValue > self._curPage {
                self.refreshCandidatesWindow(pre_next:false)
            }else {
                self.refreshCandidatesWindow(pre_next: true)
            }
     
            return
            
        }
    }
    
    func prevPage() {
        self._curPage = self._curPage > 1 ? self._curPage - 1 : 1
    }
    func nextPage() {
        self._curPage = self._curPage + 1
    }
    
    private func markText() {
        let attrs = mark(forStyle: kTSMHiliteConvertedText, at: NSRange(location: NSNotFound, length: 0))
        if let attributes = attrs as? [NSAttributedString.Key: Any] {
            var selected = self._originalString
            selected = self._originalString.count > 0 ? " " : ""
            let text = NSAttributedString(string: selected, attributes: attributes)
            client()?.setMarkedText(text, selectionRange: selectionRange(), replacementRange: replacementRange())
        }
    }
    
    private func getPreviousText(_ count: Int = 1) -> String {
        let selectedRange = client().selectedRange()
        let markedRange = client().markedRange()
        var previousLocation = selectedRange.location - markedRange.length - 1
        if selectedRange.location < markedRange.location + markedRange.length {
            previousLocation = selectedRange.location - 1
        }
        if previousLocation <= 0 {
            return ""
        }
        return client().attributedSubstring(from: NSMakeRange(previousLocation, 1))?.string ?? ""
    }
    
    private func hotkeyHandler(event: NSEvent) -> Bool? {
        if event.type == .flagsChanged {
            return nil
        }
        
        if event.charactersIgnoringModifiers == nil {
            return nil
        }
        
        guard let num = Int(event.charactersIgnoringModifiers!) else {
            return nil
        }
        
        if event.modifierFlags == .control && num > 0 && num <= self._candidates.count {
            NSLog("hotkey: control + \(num)")
            return true
        }
        
        return nil
    }
    
    func flagChangedHandler(event: NSEvent) -> Bool? {
        if event.type == .flagsChanged || (event.modifierFlags != .init(rawValue: 0) && event.modifierFlags != .shift && event.modifierFlags != .init(arrayLiteral: .numericPad, .function)) {
            return false
        }
        return nil
    }
    
    private func predictorHandler(event: NSEvent) -> Bool? {
        self._lastInputIsNumber = false
        
        self._lastInputText = getPreviousText()
        
        NSLog("[SphinxIMInputController] predictorHandler range, selectionRange: \(selectionRange()), replacementRange: \(replacementRange()), client.selectedRange: \(client().selectedRange()), client.markedRange: \(client().markedRange())")
        NSLog("[SphinxIMInputController] predictorHandler previous text, \(self._lastInputText)")
        
        return nil
    }
    
    private func pageKeyHandler(event: NSEvent) -> Bool? {
        let keyCode = event.keyCode
        
        if self._originalString.count > 0 {
            let needNextPage = keyCode == kVK_ANSI_Equal || (keyCode == kVK_DownArrow && Defaults[.candidatesDirection] == .horizontal) || (keyCode == kVK_RightArrow && Defaults[.candidatesDirection] == .vertical)
            if needNextPage {
                nextPage()
                return true
            }
            
            let needPrevPage = keyCode == kVK_ANSI_Minus || (keyCode == kVK_UpArrow && Defaults[.candidatesDirection] == .horizontal) || (keyCode == kVK_LeftArrow && Defaults[.candidatesDirection] == .vertical)
            if needPrevPage {
                prevPage()
                return true
            }
        }else {
            if keyCode == kVK_ANSI_Equal || keyCode == kVK_ANSI_Minus || keyCode == kVK_DownArrow  || keyCode == kVK_RightArrow  || keyCode == kVK_UpArrow  || keyCode == kVK_LeftArrow  {
                return false
            }
        }
        return nil
    }
    
    private func deleteKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Delete {
            if self._originalString.count > 0 {
                self._originalString = String(self._originalString.dropLast())
                return true
            }
            return false
        }
        return nil
    }
    
    private func charKeyHandler(event: NSEvent) -> Bool? {
        let string = event.characters!
        
        guard let reg = try? NSRegularExpression(pattern: "^[a-zA-Z]+$") else {
            return nil
        }
        
        let match = reg.firstMatch(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.count)
        )
        
        if  self._originalString.count <= 0 && match == nil {
            return nil
        }
        
        if match != nil {
            self._originalString += string
            
            return true
        }
        return nil
    }
    
    private func numberKeyHandlder(event: NSEvent) -> Bool? {
        let string = event.characters!
        if let pos = Int(string) {
            if self._originalString.count > 0 {
                let index = pos - 1
                if index < self._candidates.count {
                    insertCandidate(self._candidates[index])
                } else {
                    self._originalString += string
                }
                return true
            }
            self._lastInputIsNumber = true
            
            return false
        }
        return nil
    }
    
    private func escKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Escape{
            if self._originalString.count > 0 {
                close()
                return true
            }
            return false
        }
        return nil
    }
    
    private func enterKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Return {
            if  self._originalString.count > 0 {
                insertText(self._originalString)
                return true
            }
            return false
        }
        return nil
    }
    
    private func spaceKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Space {
            if self._originalString.count > 0 {
                if let first = self._candidates.first {
                    insertCandidate(first)
                }
                return true
            }
            return false
        }
        return nil
    }
    
    private func punctuationKeyHandler(event: NSEvent) -> Bool? {
        let string = event.characters!
        insertText(string)
        return true
    }
    
    override func recognizedEvents(_ sender: Any!) -> Int {
        let isCurrentApp = client().bundleIdentifier() == Bundle.main.bundleIdentifier
        var events = NSEvent.EventTypeMask(arrayLiteral: .keyDown)
        if isCurrentApp {
            events = NSEvent.EventTypeMask(arrayLiteral: .keyDown, .flagsChanged)
        }
        
        return Int(events.rawValue)
    }
    
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event else { return false }
        NSLog("[SphinxIMInputController] handle: \(event.debugDescription)")
        
        CandidatesController.shared.inputController = self
        
        let handler = Utils.shared.processHandlers(handlers: [
            hotkeyHandler,
            flagChangedHandler,
            predictorHandler,
            pageKeyHandler,
            deleteKeyHandler,
            charKeyHandler,
            numberKeyHandlder,
            escKeyHandler,
            enterKeyHandler,
            spaceKeyHandler,
            punctuationKeyHandler
        ])
        
        return handler(event) ?? false
    }
    
    func refreshCandidatesWindow(pre_next: Bool) {
        if let index = self._candidatesMap.index(forKey: self._curPage) {
            self._candidates = self._candidatesMap.values[index]
        } else {
            self._candidates = SphinxIM.shared.getCandidates(origin: self._originalString, lastCandidate: self._candidates.last)
            self._candidatesMap[self._curPage] = self._candidates
        }
        
        let candidatesData = (list: self._candidates, hasPrev: self._curPage > 1, hasNext: true)
        
        CandidatesController.shared.setCandidates(candidatesData,originalString: self._originalString,topLeft: getOriginPoint())
    }
    
    override func selectionRange() -> NSRange {
        return NSRange(location: 0, length: self._originalString.count)
    }
    
    func insertCandidate(_ candidate: Candidate) {
        insertText(candidate.text)
        let notification = Notification(
            name: SphinxIM.candidateInserted,
            object: nil,
            userInfo: [ "candidate": candidate ]
        )
        // 异步派发事件，防止阻塞当前线程
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
    }
    
    func insertText(_ text: String) {
        NSLog("insertText: %@", text)
        if text.count > 0 {
            var newText = text
            let value = NSAttributedString(string: newText)
            client()?.insertText(value, replacementRange: replacementRange())
            self._lastInputIsNumber = newText.last != nil && Int(String(newText.last!)) != nil
        }
        
        close()
    }
    
    func insertOriginText() {
        if self._originalString.count > 0 {
            self.insertText(self._originalString)
        }
    }
    
    func getOriginPoint() -> NSPoint {
        let xd: CGFloat = 0
        let yd: CGFloat = 4
        var rect = NSRect()
        client()?.attributes(forCharacterIndex: 0, lineHeightRectangle: &rect)
        return NSPoint(x: rect.minX + xd, y: rect.minY - yd)
    }
    
    func close() {
        NSLog("[SphinxIMInputController] close")
        self._originalString = ""
        self._curPage = 0
        CandidatesController.shared.close()
    }
}
