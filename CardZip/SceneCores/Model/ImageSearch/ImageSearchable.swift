//
//  ImageSearchable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/03.
//

import Foundation
protocol ImageSearchable{
    var thumbnail:String {get set}
    var imagePath: String{ get set}
    var sizeheight:String {get set}
    var sizewidth:String {get set}
}
