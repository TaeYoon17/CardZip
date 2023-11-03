//
//  ImageSearchModel.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import Foundation
struct ImageSearch:Identifiable,Hashable{
    var id:String { imagePath }
    var imagePath: String
    var isCheck: Bool = false
}
