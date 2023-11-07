//
//  ImageTable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import RealmSwift
final class ImageTable: Object,Identifiable{
    @Persisted(primaryKey: true) var imagePath: String
    @Persisted var usingCount: Int = 0
    convenience init(imagePath: String) {
        self.init()
        self.imagePath = imagePath
    }
}
