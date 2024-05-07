//
//  PreferencesController.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//


import Foundation
import AppKit

class PreferencesController: NSObject, NSWindowDelegate {
    private var controller: SettingsWindowController?
    static let shared = PreferencesController()

    var isVisible: Bool {
        controller?.window?.isVisible ?? false
    }

    private func initController() {
        if let controller = controller {
            controller.show()
            return
        }
        self.controller = SettingsWindowController.init(
            panes: [
                Settings.Pane(
                    identifier: Settings.PaneIdentifier(rawValue: "general"),
                     title: "General",
                    toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
                ) {
                    PreferencesPaneAbout()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier(rawValue: "statistics"),
                     title: "Statistics",
                    toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
                ) {
                    PreferencesPaneAbout()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier(rawValue: "user"),
                     title: "User",
                    toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
                ) {
                    PreferencesPaneAbout()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier(rawValue: "about"),
                     title: "About",
                    toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
                ) {
                    PreferencesPaneAbout()
                },
            ],
            style: .toolbarItems,
            animated: true,
            hidesToolbarForSingleItem: true
        )
        self.controller?.window?.delegate = self
    }

    func showPane(_ name: String) {
        initController()
        controller?.show(pane: Settings.PaneIdentifier(rawValue: name))
    }

    func show() {
        initController()
        controller?.show()
    }
}
