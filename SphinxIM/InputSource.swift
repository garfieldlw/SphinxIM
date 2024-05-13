//
//  InputSource.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import Carbon
import AppKit

enum InputSourceUsage {
    case enable
    case selected
}

class InputSource {
    let installLocation = "/Library/Input Methods/SphinxIM.app"
    let kSourceID = Bundle.main.bundleIdentifier!
    
    func registerInputSource() {
        if !isEnabled() {
            let installedLocationURL = NSURL(fileURLWithPath: installLocation)
            let err = TISRegisterInputSource(installedLocationURL as CFURL)
            NSLog("register input source: \(err)")
        }
    }
    
    private func findInputSource(forUsage: InputSourceUsage = .enable)
    -> TISInputSource? {
        let conditions = NSMutableDictionary()
        conditions.setValue(kSourceID, forKey: kTISPropertyInputSourceID as String)
        guard let sourceList = TISCreateInputSourceList(conditions, true)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        
        for index in 0..<sourceList.count {
            let inputSource = sourceList[index]
            let selectable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
                TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsSelectCapable)
            ).takeUnretainedValue())
            let enableable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
                TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsEnableCapable)
            ).takeUnretainedValue())
            if forUsage == .enable && enableable {
                return inputSource
            }
            if forUsage == .selected && selectable {
                return inputSource
            }
            if selectable {
                return inputSource
            }
        }
        return nil
    }
    
    func selectInputSource(callback: @escaping (Bool) -> Void) {
        let maxTryTimes = 30
        var tryTimes = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if tryTimes > maxTryTimes {
                timer.invalidate()
                callback(false)
                return
            }
            tryTimes += 1
            guard let result = self.findInputSource(forUsage: .selected) else {
                return
            }
            let err = TISSelectInputSource(result)
            NSLog("select input source: \(err)")
            let isSelected = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
                TISGetInputSourceProperty(result, kTISPropertyInputSourceIsSelected)
            ).takeUnretainedValue())
            if isSelected {
                timer.invalidate()
                callback(true)
            }
        }
    }
    
    func activateInputSource() {
        guard let result = findInputSource() else {
            return
        }
        let enabled = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
            TISGetInputSourceProperty(result, kTISPropertyInputSourceIsEnabled)
        ).takeUnretainedValue())
        if !enabled {
            let err = TISEnableInputSource(result)
            NSLog("Enabled input source: \(err)")
        }
    }
    
    func deactivateInputSource() {
        guard let source = findInputSource() else {
            return
        }
        TISDeselectInputSource(source)
        TISDisableInputSource(source)
        NSLog("Disable input source")
    }
    
    func onSelectChanged(callback: @escaping (Bool) -> Void) -> NSObjectProtocol {
        let observer = DistributedNotificationCenter.default()
            .addObserver(
                forName: .init(String(kTISNotifySelectedKeyboardInputSourceChanged)),
                object: nil,
                queue: nil,
                using: { _ in
                    callback(self.isSelected())
                }
            )
        return observer
    }
    
    func isSelected() -> Bool {
        guard let result = findInputSource(forUsage: .selected) else {
            return false
        }
        let unsafeIsSelected = TISGetInputSourceProperty(
            result,
            kTISPropertyInputSourceIsSelected
        ).assumingMemoryBound(to: CFBoolean.self)
        let isSelected = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsSelected).takeUnretainedValue())
        
        return isSelected
    }
    
    func isEnabled() -> Bool {
        guard let result = findInputSource(forUsage: .enable) else {
            return false
        }
        let unsafeIsEnabled = TISGetInputSourceProperty(
            result,
            kTISPropertyInputSourceIsEnabled
        ).assumingMemoryBound(to: CFBoolean.self)
        let isEnabled = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsEnabled).takeUnretainedValue())
        
        return isEnabled
    }
    
    static let shared = InputSource()
}
