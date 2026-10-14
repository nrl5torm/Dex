//
//  DexLanguageCode.swift
//  Dex
//
//  Created by Olivier Sbg on 13/10/2026.
//

import Foundation

enum DexLanguageCode: String, Decodable, Identifiable {
    case defaultEN = "en"
    case de
    case es
    case es419 = "es-419"
    case fr
    case it
    
    case ja
    case jaHrkt = "ja-hrkt"
    case jaRoma = "ja-roma"
    case ko
    case zhHans = "zh-hans"
    case zhHant = "zh-hant"
    
    var id: DexLanguageCode { self }
    
    var displayName: String {
        switch self {
        case .defaultEN:
            "English"
        case .fr:
            "Français"
        case .ja:
            "日本語"
        default:
            rawValue
        }
    }
    
    var flag: String {
        switch self {
        case .defaultEN:
            "🇬🇧"
        case .fr:
            "🇫🇷"
        case .ja:
            "🇯🇵"
        default:
            "🌐"
        }
    }
    
    static var userLanguage: DexLanguageCode {
        let storedLanguage = UserDefaults(
            suiteName: DexLanguageCode.Storage.group
        )?.string(
            forKey: DexLanguageCode.Storage.key
        ) ?? ""
        
        return DexLanguageCode(rawValue: storedLanguage) ?? .defaultEN
    }
    
    
    static var supportedLanguages: [DexLanguageCode] {
        [.defaultEN, .fr, .ja]
    }
    
    struct Storage {
        static let group = "group.artificiali.se.Dex"
        static let key = "selectedLanguage"
    }
}

