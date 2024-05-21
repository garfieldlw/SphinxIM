//
//  PreferencesPaneAbout.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import SwiftUI

struct PreferencesPaneAbout: View {

    let mainVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String as String
    let minorVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String as String
    
    var body: some View {
        Settings.Container(contentWidth: 450.0) {
            Settings.Section(title: "") {
                VStack(alignment: .center) {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    Text("\(Bundle.main.appName), [@github](https://github.com/garfieldlw/SphinxIM)")
                    Text(mainVersion + "(" + minorVersion + ")")
                }.frame(width: 450)
            }
        }
    }
}

#Preview {
    PreferencesPaneAbout()
}
