//
//  InputSource.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import Carbon
import AppKit

enum InputSourceUsage {
    case register
    case enable
    case selected
}

class InputSource {
    let installLocation = "/Library/Input Methods/SphinxIM.app"
    let kSourceID = Bundle.main.bundleIdentifier!
    
    func registerInputSource() {
        let (_, able ) = findInputSource(forUsage: .register)
        if !able! {
            let installedLocationURL = NSURL(fileURLWithPath: installLocation)
            let err = TISRegisterInputSource(installedLocationURL as CFURL)
            NSLog("register input source: \(err)")
        }
    }
    
    private func findInputSource(forUsage: InputSourceUsage) -> (TISInputSource?, Bool?) {
        let conditions = NSMutableDictionary()
        conditions.setValue(kSourceID, forKey: kTISPropertyInputSourceID as String)
        
        guard let sourceList = TISCreateInputSourceList(conditions, true)?.takeRetainedValue() as? [TISInputSource] else {
            return (nil, false)
        }
        
        if sourceList.count == 0 {
            return (nil, false)
        }
        
        let inputSource = sourceList[0]
        
        let selectable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
            TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsSelectCapable)
        ).takeUnretainedValue())
        
        let enableable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(
            TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsEnableCapable)
        ).takeUnretainedValue())
        
        switch forUsage {
        case .register:
            return (inputSource, true)
        case .enable:
            return (inputSource, enableable)
        case .selected:
            return (inputSource, selectable)
        }
    }
    
    func activateInputSource() {
        let (result, able) = findInputSource(forUsage: .enable)
        
        if !able! {
            let err = TISEnableInputSource(result)
            NSLog("Enabled input source: \(err)")
        }
    }
    
    func deactivateInputSource() {
        let (result, able) = findInputSource(forUsage: .register)
        
        if !able! {
            return
        }
        
        TISDeselectInputSource(result)
        TISDisableInputSource(result)
        NSLog("Disable input source")
    }
    
    static let shared = InputSource()
}
