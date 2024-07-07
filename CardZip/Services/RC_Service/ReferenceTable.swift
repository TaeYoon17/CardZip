//
//  ImageTable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import RealmSwift

class ReferenceTable: Object,Identifiable,ReferenceCountable{
    @Persisted(primaryKey: true) var name: String
    @Persisted var count: Int = 0
     
    required convenience init(fileName: String) {
        self.init()
        self.name = fileName
    }
    convenience init(fileName:String, count: Int) {
        self.init(fileName: fileName)
        self.count = count
    }
}
