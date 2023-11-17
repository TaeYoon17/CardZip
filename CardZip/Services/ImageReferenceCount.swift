//
//  ImageReferenceCount.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/08.
//

import Foundation
import RealmSwift
struct FileModel:Identifiable{
    var id:String{fileName}
    var fileName: String
    var count: Int = 0
}
