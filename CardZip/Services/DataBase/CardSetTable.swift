//
//  CardSetTable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import RealmSwift

final class CardSetTable: Object{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var setDescription: String
    @Persisted var imagePath: String?
    @Persisted var cardList: List<CardTable>
    convenience init(title:String,description: String,imagePath: String? = nil) {
        self.init()
        self.title = title
        self.setDescription = description
        self.imagePath = imagePath
    }
    
}
