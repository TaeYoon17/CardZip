//
//  Card.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/10.
//

import Foundation
import RealmSwift
struct CardItem:Identifiable,Hashable{
    let id = UUID()
    var title: String = ""
    var description: String = ""
    var imageID: [String] = []
    var dbKey: ObjectId?
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    init(){}
    init(title: String, description: String, imageID: [String], dbKey: ObjectId? = nil) {
        self.title = title
        self.description = description
        self.imageID = imageID
        self.dbKey = dbKey
    }
    init(table: CardTable){
        self.title = table.term
        self.description = table.definition
        self.imageID = Array(table.imagePathes)
        self.dbKey = table._id
    }
}
