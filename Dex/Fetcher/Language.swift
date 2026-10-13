//
//  Language.swift
//  Dex
//
//  Created by Olivier Sbg on 13/10/2026.
//

import Foundation

struct Language: Decodable {
    let name: LanguageCode
    let url: URL
}

enum LanguageCode: String, Decodable {
    case de
    case en
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
}

extension LanguageCode {
    var displayName: String {
        switch self {
        case .en:
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
        case .en:
            "🇬🇧"
        case .fr:
            "🇫🇷"
        case .ja:
            "🇯🇵"
        default:
            "🌐"
        }
    }
}

