//
//  AppDelegate.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import Cocoa
import InputMethodKit

// Necessary to launch this app
class NSManualApplication: NSApplication {
    private let appDelegate = AppDelegate()
    
    override init() {
        super.init()
        self.delegate = appDelegate
    }
    
    required init?(coder: NSCoder) {
        // No need for implementation
        fatalError("init(coder:) has not been implemented")
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var sphinx: SphinxIM!
    var statistics: Statistics!
    
    func installInputSource() {
        print("install input source")
        InputSource.shared.registerInputSource()
        InputSource.shared.activateInputSource()
        InputSource.shared.selectInputSource { _ in
            NSApp.terminate(self)
        }
    }
    
    func stop() {
        InputSource.shared.deactivateInputSource()
        NSApp.terminate(nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("[SphinxIM] app is running")
        
        Dao.shared.InitDB()
        
        sphinx = SphinxIM.shared
        statistics = Statistics.shared
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}
