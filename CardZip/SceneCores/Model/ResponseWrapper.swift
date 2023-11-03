//
//  ResponseWrapper.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/03.
//

import Foundation

struct ResponseWrapper<T:Codable>:Codable{
    let items: [T]
    let lastBuildDate: String
    let total:Int
    let display: Int
    let start: String
    enum CodingKeys:String, CodingKey {
        case lastBuildDate
        case items
        case total
        case display
        case start
    }
}
