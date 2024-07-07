//
//  CardVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/22.
//

import Foundation
import Combine
final class CardVM{
    @MainActor private let setRepository = CardSetRepository()
    @MainActor private let cardRepository = CardRepository()
    @Published var studyType: StudyType = .basic
    @Published var startItem:CardItem?
    @Published var startCardNumber: Int? = 0
    @Published var cardNumber = -1
    @Published var setItem: SetItem!
    var passthroughExpandImage = PassthroughSubject<(CardItem,Int),Never>()
    var passthroughUpdateCard = PassthroughSubject<CardItem,Never>()
    
    @MainActor var setTables: CardSetTable?{
        guard let dbKey = setItem?.dbKey else {return nil}
        let setTable = setRepository?.objectByPrimaryKey(primaryKey: dbKey)
        return setTable
    }
    @MainActor var cardTables:[CardTable]{
        guard let setTable = self.setTables else {return []}
        let cardTables:[CardTable]
        switch studyType {
        case .basic,.random: cardTables = Array(setTable.cardList)
        case .check: cardTables = Array(setTable.cardList.where { table in table.isCheck })
        }
        return cardTables
    }
    @MainActor func saveRepository(cardItems: [CardItem]){
        print("업데이트 할 데이터들 \(cardItems)")
        cardItems.forEach { item in
            if let dbKey = item.dbKey,
               let table:CardTable =  cardRepository?.getTableBy(tableID: dbKey){
                cardRepository?.update(card: table, item: item)
            }
        }
        App.Manager.shared.updateLikes()
    }
}
