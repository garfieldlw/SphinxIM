//
//  CandidateView.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import SwiftUI

struct CandidateView: View {
    var candidate: Candidate
    var index: Int
    var origin: String
    var indexVisible = true
    
    var selected: Int
    
    @Default(.themeConfig) private var themeConfig
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        return HStack(alignment: .center, spacing: 2) {
            if selected == index {
                if indexVisible {
                    Text("\(index + 1).")
                        .foregroundColor(Color(themeConfig[colorScheme].selectedIndexColor))
                }
                
                Text(candidate.text).foregroundColor(Color(themeConfig[colorScheme].selectedCodeColor))
            } else {
                if indexVisible {
                    Text("\(index + 1).")
                        .foregroundColor(Color(themeConfig[colorScheme].candidateIndexColor))
                }
                
                Text(candidate.text).foregroundColor(Color(themeConfig[colorScheme].candidateCodeColor))
            }
        }
        .onTapGesture {
            NotificationCenter.default.post(
                name: CandidatesView.candidateSelected,
                object: nil,
                userInfo: [
                    "candidate": candidate,
                    "index": index
                ]
            )
        }
        
    }
}

struct CandidatesView: View {
    static let candidateSelected = Notification.Name("CandidatesView.candidateSelected")
    
    var candidates: [Candidate]
    var origin: String
    var selected: Int
    
    @Default(.candidatesDirection) private var direction
    @Default(.themeConfig) private var themeConfig
    @Default(.showCodeInWindow) private var showCodeInWindow
    @Environment(\.colorScheme) var colorScheme
    
    var _candidatesView: some View {
        ForEach(Array(candidates.enumerated()), id: \.offset) { (index, candidate) -> CandidateView in
            CandidateView(
                candidate: candidate,
                index: index,
                origin: origin,
                indexVisible: candidates.count > 1,
                selected: selected
            )
        }
    }
    
    func getIndicatorIcon(
        imageName: String,
        direction: CandidatesDirection,
        disabled: Bool,
        eventName: Notification.Name
    ) -> some View {
        return Image(imageName)
            .renderingMode(.template)
            .resizable()
            .frame(width: 10, height: 10, alignment: .center)
            .rotationEffect(Angle(degrees: direction == CandidatesDirection.horizontal ? 0 : -90), anchor: .center)
            .onTapGesture {
                if disabled { return }
                NotificationCenter.default.post(
                    name: eventName,
                    object: nil
                )
            }
            .foregroundColor(Color(disabled
                                   ? themeConfig[colorScheme].pageIndicatorDisabledColor
                                   : themeConfig[colorScheme].pageIndicatorColor
                                  ))
    }
    
    var _indicator: some View {
        if candidates.count <= 1 {
            return AnyView(EmptyView())
        }
        
        return AnyView(VStack(spacing: 0) {  })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat( themeConfig[colorScheme].originCandidatesSpace), content: {
            if showCodeInWindow {
                Text(origin)
                    .foregroundColor(Color(themeConfig[colorScheme].originCodeColor))
                    .fixedSize()
            }
            if direction == CandidatesDirection.horizontal {
                HStack(alignment: .center, spacing: CGFloat(themeConfig[colorScheme].candidateSpace)) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            } else {
                VStack(alignment: .leading, spacing: CGFloat(themeConfig[colorScheme].candidateSpace)) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            }
        })
        .padding(.top, CGFloat(themeConfig[colorScheme].windowPaddingTop))
        .padding(.bottom, CGFloat(themeConfig[colorScheme].windowPaddingBottom))
        .padding(.leading, CGFloat(themeConfig[colorScheme].windowPaddingLeft))
        .padding(.trailing, CGFloat(themeConfig[colorScheme].windowPaddingRight))
        .fixedSize()
        .font(.system(size: CGFloat(themeConfig[colorScheme].fontSize)))
        .background(Color(themeConfig[colorScheme].windowBackgroundColor))
        .cornerRadius(CGFloat(themeConfig[colorScheme].windowBorderRadius), antialiased: true)
    }
}

