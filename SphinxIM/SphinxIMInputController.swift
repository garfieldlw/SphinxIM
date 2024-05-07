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
    
    private var _hasNext: Bool = false
    
    private var _lastInputIsNumber = false
    
    private var _lastInputText = ""
    
    deinit {
        NSLog("[SphinxIMInputController] deinit")
        clean()
    }
    
    private var _originalString = "" {
        didSet {
            if self.curPage != 1 {
                _candidates = []
                _hasNext = false
                self.curPage = 1
                self.markText()
                return
            }
            NSLog("[SphinxIMInputController] original changed: \(self._originalString), refresh window")
            
            self.markText()
            
            self._originalString.count > 0 ? self.refreshCandidatesWindow() : CandidatesController.shared.close()
        }
    }
    private var curPage: Int = 1 {
        didSet(old) {
            guard old == self.curPage else {
                NSLog("[SphinxIMInputController] page changed")
                self.refreshCandidatesWindow()
                return
            }
        }
    }
    func prevPage() {
        self.curPage = self.curPage > 1 ? self.curPage - 1 : 1
    }
    func nextPage() {
        self.curPage = self._hasNext ? self.curPage + 1 : self.curPage
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
        if event.modifierFlags == .control &&
            num > 0 && num <= _candidates.count {
            NSLog("hotkey: control + \(num)")
            _candidates = []
            _hasNext = false
            self.curPage = 1
            self.refreshCandidatesWindow()
            return true
        }
        return nil
    }
    
    func flagChangedHandler(event: NSEvent) -> Bool? {
        if event.type == .flagsChanged ||
            (event.modifierFlags != .init(rawValue: 0) &&
             event.modifierFlags != .shift &&
             event.modifierFlags != .init(arrayLiteral: .numericPad, .function)
            ) {
            return false
        }
        return nil
    }
    
    private func predictorHandler(event: NSEvent) -> Bool? {
        _lastInputIsNumber = false
        
        _lastInputText = getPreviousText()
        
        NSLog("[SphinxIMInputController] predictorHandler range, selectionRange: \(selectionRange()), replacementRange: \(replacementRange()), client.selectedRange: \(client().selectedRange()), client.markedRange: \(client().markedRange())")
        NSLog("[SphinxIMInputController] predictorHandler previous text, \(_lastInputText)")
        
        return nil
    }
    
    private func pageKeyHandler(event: NSEvent) -> Bool? {
        let keyCode = event.keyCode
        
        if _originalString.count > 0 {
            let needNextPage = keyCode == kVK_ANSI_Equal ||
            (keyCode == kVK_DownArrow && Defaults[.candidatesDirection] == .horizontal) ||
            (keyCode == kVK_RightArrow && Defaults[.candidatesDirection] == .vertical)
            if needNextPage {
                curPage = _hasNext ? curPage + 1 : curPage
                return true
            }
            
            let needPrevPage = keyCode == kVK_ANSI_Minus ||
            (keyCode == kVK_UpArrow && Defaults[.candidatesDirection] == .horizontal) ||
            (keyCode == kVK_LeftArrow && Defaults[.candidatesDirection] == .vertical)
            if needPrevPage {
                curPage = curPage > 1 ? curPage - 1 : 1
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
            if _originalString.count > 0 {
                _originalString = String(_originalString.dropLast())
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
        
        if  _originalString.count <= 0 && match == nil {
            return nil
        }
        
        if match != nil {
            _originalString += string
            
            return true
        }
        return nil
    }
    
    private func numberKeyHandlder(event: NSEvent) -> Bool? {
        let string = event.characters!
        if let pos = Int(string) {
            if _originalString.count > 0 {
                let index = pos - 1
                if index < _candidates.count {
                    insertCandidate(_candidates[index])
                } else {
                    _originalString += string
                }
                return true
            }
            _lastInputIsNumber = true
            
            return false
        }
        return nil
    }
    
    private func escKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Escape{
            if _originalString.count > 0 {
                clean()
                return true
            }
            return false
        }
        return nil
    }
    
    private func enterKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Return {
            if  _originalString.count > 0 {
                insertText(_originalString)
                return true
            }
            return false
        }
        return nil
    }
    
    private func spaceKeyHandler(event: NSEvent) -> Bool? {
        if event.keyCode == kVK_Space {
            if _originalString.count > 0 {
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
    
    func updateCandidates(_ sender: Any!) {
        let (candidates, hasNext) = SphinxIM.shared.getCandidates(origin: self._originalString,lastCandidate: _candidates.last)
        _candidates = candidates
        _hasNext = hasNext
    }
    
    func refreshCandidatesWindow() {
        updateCandidates(client())
        let candidatesData = (list: _candidates, hasPrev: curPage > 1, hasNext: _hasNext)
        CandidatesController.shared.setCandidates(
            candidatesData,
            originalString: _originalString,
            topLeft: getOriginPoint()
        )
    }
    
    override func selectionRange() -> NSRange {
        return NSRange(location: 0, length: _originalString.count)
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
            _lastInputIsNumber = newText.last != nil && Int(String(newText.last!)) != nil
        }
        clean()
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
    
    func clean() {
        NSLog("[SphinxIMInputController] clean")
        _originalString = ""
        _candidates = []
        _hasNext = false
        curPage = 1
        CandidatesController.shared.close()
    }
}
