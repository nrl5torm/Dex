//
//  Language.swift
//  Dex
//
//  Created by Olivier Sbg on 13/10/2026.
//

import Foundation

struct Language: Decodable {
    let name: LanguageName
    let url: URL
}

enum LanguageName: String, Decodable {
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
