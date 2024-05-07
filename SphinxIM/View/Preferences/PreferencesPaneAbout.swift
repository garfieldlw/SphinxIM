//
//  PreferencesPaneAbout.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import SwiftUI

struct PreferencesPaneAbout: View {
    var body: some View {
        Settings.Container(contentWidth: 450.0) {
            Settings.Section(title: "About") {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

#Preview {
    PreferencesPaneAbout()
}
