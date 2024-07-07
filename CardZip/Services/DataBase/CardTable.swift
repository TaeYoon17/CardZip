//
//  CardTable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import RealmSwift

final class CardTable: Object,Identifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted(originProperty: "cardList") var parentSet: LinkingObjects<CardSetTable>
    @Persisted var term: String
    @Persisted var definition: String
    @Persisted var imagePathes: List<String>
    @Persisted var isCheck: Bool = false
    @Persisted var isLike: Bool = false
    convenience init(parent: ObjectId,term: String, definition:String, imagePathes:[String]) {
        self.init()
        self.term = term
        self.definition = definition
        self.imagePathes = .init()
        imagePathes.forEach { self.imagePathes.append($0) }
    }
    func change(parent: ObjectId,term: String, definition:String, imagePathes:[String],isLike:Bool){
        self.term = term
        self.definition = definition
        self.imagePathes = .init()
        imagePathes.forEach { str in
            self.imagePathes.append(str)
        } 
    }
}


