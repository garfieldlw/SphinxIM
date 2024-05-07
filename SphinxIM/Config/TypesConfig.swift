//
//  Types.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/5.
//

import Foundation
import SwiftUI

enum CandidatesDirection: Int, Decodable, Encodable, Defaults.Serializable {
    case vertical
    case horizontal
}

enum InputModeTipWindowType: Int, Decodable, Encodable, Defaults.Serializable {
    case followInput
    case centerScreen
    case none
}

// 应用切换时，显示输入模式框时机
enum AppInputModeTipShowTime: Int, Decodable, Encodable, Defaults.Serializable {
    case onlyChanged
    case always
    case none
}

enum ModifierKey: String, Codable, Defaults.Serializable {
  case shift
  case leftShift
  case rightShift
  case control
  case command
  case option
  case function
}

class ApplicationSettingItem: ObservableObject, Codable, Identifiable, Defaults.Serializable {
//    let identifier: String = ""

    @Published var bundleIdentifier: String = ""

    @Published var inputModeSetting: InputModeSetting = InputModeSetting.enUS {
        didSet {
            self.objectWillChange.send()
        }
    }

    var createdTimestamp: Int = 0

    private enum CodingKeys: String, CodingKey {
        case bundleIdentifier
        case inputModeSetting
        case createdTimestamp
    }

    init(bundleId: String, inputMs: InputModeSetting) {
        bundleIdentifier = bundleId
        inputModeSetting = inputMs
        createdTimestamp = Int(Date().timeIntervalSince1970)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bundleIdentifier = try values.decode(String.self, forKey: .bundleIdentifier)
        inputModeSetting = try values.decode(InputModeSetting.self, forKey: .inputModeSetting)
        createdTimestamp = try values.decode(Int.self, forKey: .createdTimestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(inputModeSetting, forKey: .inputModeSetting)
        try container.encode(createdTimestamp, forKey: .createdTimestamp)
    }
}

extension Defaults.Keys {
    static let candidatesDirection = Key<CandidatesDirection>(
        "candidatesDirection",
        default: CandidatesDirection.horizontal
    )
    
    static let showCodeInWindow = Key<Bool>("showCodeInWindow", default: true)
    
    static let candidateCount = Key<Int>("candidateCount", default: 5)

    static let themeConfig = Key<ThemeConfig>("themeConfig", default: defaultThemeConfig)
    static let importedThemeConfig = Key<ThemeConfig?>("importedThemeConfig", default: nil)

    static let appInputModeTipShowTime = Key<AppInputModeTipShowTime>("appInputModeTipShowTime", default: .onlyChanged)
    static let appSettings = Key<[String: ApplicationSettingItem]>("AppSettings", default: [:])
    
    static let enableStatistics = Key<Bool>("enableStatistics", default: true)
}

enum InputMode: String, Defaults.Serializable {
    case enUS
}

enum InputModeSetting: String, Codable {
    case enUS
}

enum CandidateTypeMode: Int {
    case placeholder = 0
    case enUS = 1
}

enum CandidateTypeMethod: Int {
    case placeholder  = 0
    case en1 = 1
    case en2 = 2
    case enSpellError  = 3
}

struct Candidate: Hashable {
    let id: Int64
    let code: String
    let text: String
    let count: Int64
    let type_mode: CandidateTypeMode
    let type_method: CandidateTypeMethod
    
    init(id: Int64, code: String, text: String, count: Int64, type_mode: CandidateTypeMode, type_method: CandidateTypeMethod) {
        self.id = id
        self.code = code
        self.text = text
        self.count = count
        self.type_mode = type_mode
        self.type_method = type_method
    }
}
