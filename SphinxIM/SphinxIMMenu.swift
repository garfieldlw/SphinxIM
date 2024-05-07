//
//  SphinxIMMenu.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import Foundation
import AppKit

extension SphinxIMInputController {
    @objc func openAbout (_ sender: Any!) {
        NSApp.setActivationPolicy(.accessory)
        PreferencesController.shared.showPane("about")
    }
    
    override func showPreferences(_ sender: Any!) {
        NSApp.setActivationPolicy(.accessory)
        PreferencesController.shared.show()
    }

    @objc func setAppicationMode(_ sender: Any!) {
        if let menuWrapper = sender as? [String: Any],
           let menuItem = menuWrapper["IMKCommandMenuItem"] as? NSMenuItem,
           let dict = menuItem.representedObject as? [String: Any],
           let bundleID = dict["bundleID"] as? String,
           let mode = dict["mode"] as? InputMode {
            NSLog("[SphinxIMInputController] setApplicationMode, \(bundleID), \(mode)")
        }
    }
    
    override func menu() -> NSMenu! {
        NSLog("[SphinxIMInputController] menu")
        let menu = NSMenu()
        menu.items = [
            NSMenuItem(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent: ""),
            NSMenuItem(title: "About", action: #selector(openAbout(_:)), keyEquivalent: ""),
        ]
        return menu
    }
}
