//
//  CandidatesWindow.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import SwiftUI
import InputMethodKit

class CandidatesController: NSWindow, NSWindowDelegate {
    let hostingView = NSHostingView(rootView: CandidatesView(candidates: [], origin: "", selected: 0))
    var inputController: SphinxIMInputController?

    func windowDidMove(_ notification: Notification) {
        DispatchQueue.main.async {
            self.limitFrameInScreen()
        }
    }

    func windowDidResize(_ notification: Notification) {
        limitFrameInScreen()
    }

    func setCandidates(list: [Candidate], selected: Int,originalString: String, topLeft: NSPoint) {
        hostingView.rootView.candidates = list
        hostingView.rootView.origin = originalString
        hostingView.rootView.selected = selected
        NSLog("origin top left: \(topLeft)")
        self.setFrameTopLeftPoint(topLeft)
        self.orderFront(nil)
    }
    
    func updateSelectedCandidate(_ selected: Int) {
        hostingView.rootView.selected = selected
    }

    func bindEvents() {
        let events: [NotificationObserver] = [
            (CandidatesView.candidateSelected, { notification in
                if let candidate = notification.userInfo?["candidate"] as? Candidate {
                    self.inputController?.insertCandidate(candidate)
                }
            }),
        ]
        
        events.forEach { (observer) in NotificationCenter.default.addObserver(
          forName: observer.name, object: nil, queue: nil, using: observer.callback
        )}

        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { (event) in
            NSLog("[CandidatesWindow] globalMonitorForEvents flagsChanged: \(event)")
            if !InputSource.shared.isSelected() {
                return
            }
            _ = self.inputController?.flagChangedHandler(event: event)
        }
    }

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        level = NSWindow.Level(rawValue: NSWindow.Level.RawValue(CGShieldingWindowLevel()))
        styleMask = .init(arrayLiteral: .fullSizeContentView, .borderless)
        isReleasedWhenClosed = false
        backgroundColor = NSColor.clear
        delegate = self
        setSizePolicy()
        bindEvents()
    }

    private func limitFrameInScreen() {
       let origin = self.transformTopLeft(originalTopLeft: NSPoint(x: self.frame.minX, y: self.frame.maxY))
       self.setFrameTopLeftPoint(origin)
    }

    private func setSizePolicy() {
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        guard self.contentView != nil else {
            return
        }
        self.contentView?.addSubview(hostingView)
        self.contentView?.leftAnchor.constraint(equalTo: hostingView.leftAnchor).isActive = true
        self.contentView?.rightAnchor.constraint(equalTo: hostingView.rightAnchor).isActive = true
        self.contentView?.topAnchor.constraint(equalTo: hostingView.topAnchor).isActive = true
        self.contentView?.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor).isActive = true
    }

    private func transformTopLeft(originalTopLeft: NSPoint) -> NSPoint {
        NSLog("[SphinxIMCandidatesWindow] transformTopLeft: \(frame)")

        let screenPadding: CGFloat = 6

        var left = originalTopLeft.x
        var top = originalTopLeft.y
        if let curScreen = Utils.shared.getScreenFromPoint(originalTopLeft) {
            let screen = curScreen.frame

            if originalTopLeft.x + frame.width > screen.maxX - screenPadding {
                left = screen.maxX - frame.width - screenPadding
            }
            if originalTopLeft.y - frame.height < screen.minY + screenPadding {
                top = screen.minY + frame.height + screenPadding
            }
        }
        return NSPoint(x: left, y: top)
    }

    static let shared = CandidatesController()
}
