//
//  ImageSearchModel.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import Foundation
struct ImageSearch:Identifiable,Hashable,ImageSearchable,Codable{
    var sizeheight: String
    var sizewidth: String
    var imagePath: String
    var thumbnail: String
    var id:String { imagePath }
    var height: Int{ Int(sizeheight) ?? -1}
    var width: Int{  Int(sizewidth) ?? -1 }
    var isCheck: Bool! = false
     
    enum CodingKeys:String, CodingKey {
        case thumbnail
        case sizeheight
        case sizewidth
        case imagePath = "link"
    }
}
