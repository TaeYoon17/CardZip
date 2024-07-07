//
//  Card.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/10.
//

import Foundation
import RealmSwift
struct CardItem:Identifiable,Hashable{
    static func == (lhs: CardItem, rhs: CardItem) -> Bool { lhs.id == rhs.id }
    let id = UUID()
    var title: String = ""
    var definition: String = ""
    var imageID: [String] = []
    var dbKey: ObjectId?
    var isLike: Bool = false
    var isChecked: Bool = false
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    init(){}
    init(title: String, definition: String, imageID: [String], dbKey: ObjectId? = nil, isLike: Bool, isChecked: Bool) {
        self.title = title
        self.definition = definition
        self.imageID = imageID
        self.dbKey = dbKey
        self.isLike = isLike
        self.isChecked = isChecked
    }
    init(table: CardTable){
        self.title = table.term
        self.definition = table.definition
        self.imageID = Array(table.imagePathes)
        self.dbKey = table._id
        self.isLike = table.isLike
        self.isChecked = table.isCheck
    }
}
