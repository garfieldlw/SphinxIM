//
//  Utils.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import AppKit
import InputMethodKit
import SwiftUI

enum HandlerStatus {
    case next
    case stop
}

class Utils {
    init() {
    }
    
    func processHandlers<T>(
        handlers: [(NSEvent) -> T?]
    ) -> ((NSEvent) -> T?) {
        func handleFn(event: NSEvent) -> T? {
            for handler in handlers {
                if let result = handler(event) {
                    return result
                }
            }
            return nil
        }
        return handleFn
    }

    func getScreenFromPoint(_ point: NSPoint) -> NSScreen? {
        // find current screen
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        return NSScreen.main
    }

    static let shared = Utils()
}
