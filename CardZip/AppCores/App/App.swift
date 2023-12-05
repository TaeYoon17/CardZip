//
//  App.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import Foundation
enum App{
    static var dbVersion:UInt64{ 1 }
    enum Logo{
        static let like: String = "star"
        static let check: String = "bookmark"
        static let emptyImage: String = "questionmark.circle"
        static let speaker:String = "speaker"
    }
    enum Language{
        case english
        case korean
    }
}
