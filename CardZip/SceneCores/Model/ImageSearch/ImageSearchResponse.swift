//
//  ImageSearchResponse.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/03.
//

import Foundation
struct ImageSearchResponse:Codable,ImageSearchable{
    let title: String
    var imagePath: String
    var thumbnail: String
    var sizeheight:String
    var sizewidth:String
    enum CodingKeys:String, CodingKey {
        case title
        case thumbnail
        case sizeheight
        case sizewidth
        case imagePath = "link"
    }
}
