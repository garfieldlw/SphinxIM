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
    var selected: Bool = false
    var indexVisible = true

    @Default(.themeConfig) private var themeConfig
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let indexColor = selected
            ? themeConfig[colorScheme].selectedIndexColor
            : themeConfig[colorScheme].candidateIndexColor
        let codeColor = selected
            ? themeConfig[colorScheme].selectedCodeColor
            : themeConfig[colorScheme].candidateCodeColor

        return HStack(alignment: .center, spacing: 2) {
            if indexVisible {
                Text("\(index + 1).")
                    .foregroundColor(Color(indexColor))
            }
            
            Text(candidate.text).foregroundColor(Color(codeColor))
            
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
    static let nextPageBtnTapped = Notification.Name("CandidatesView.nextPageBtnTapped")
    static let prevPageBtnTapped = Notification.Name("CandidatesView.prevPageBtnTapped")

    var candidates: [Candidate]
    var origin: String
    var hasPrev: Bool = false
    var hasNext: Bool = false

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
                selected: index == 0,
                indexVisible: candidates.count > 1
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
        let arrowUp = getIndicatorIcon(
            imageName: "arrowUp",
            direction: direction,
            disabled: !hasPrev,
            eventName: CandidatesView.prevPageBtnTapped
        )
        let arrowDown = getIndicatorIcon(
            imageName: "arrowDown",
            direction: direction,
            disabled: !hasNext,
            eventName: CandidatesView.nextPageBtnTapped
        )
        if direction == CandidatesDirection.horizontal {
            return AnyView(VStack(spacing: 0) { arrowUp; arrowDown })
        } else {
            return AnyView(HStack(spacing: 4) { arrowUp; arrowDown })
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CandidatesView(candidates: [
            Candidate(id:1, code: "a", text: "a", count:1, type_mode: CandidateTypeMode.enUS, type_method: CandidateTypeMethod.en1),
        ], origin: "a")
    }
}
