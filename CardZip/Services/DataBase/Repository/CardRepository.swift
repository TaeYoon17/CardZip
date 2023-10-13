//
//  CardRepository.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import Foundation
import RealmSwift
@MainActor final class CardRepository: TableRepository<CardTable>{
    
    func update(card:CardTable,item:CardItem){
        try! self.realm.write({
            card.definition = item.description
            card.term = item.title
            card.imagePathes.removeAll()
            item.imageID.forEach {  card.imagePathes.append($0) }
        })
    }
    
}
