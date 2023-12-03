//
//  AddSetVM+Table.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/16.
//

import Foundation
import RealmSwift
//MARK: -- REALM 테이블에 대하여
extension AddSetVM{
    @MainActor var setTable:CardSetTable?{
        if let dbKey = setItem?.dbKey,
           let table = repository?.getTableBy(tableID: dbKey){
            return table
        }
        return nil
    }
    
    @MainActor func deleteTable(cardItem: CardItem){
        do{
            try repository?.cardRespository?.deleteTableBy(tableID: cardItem.dbKey)
            print("데베에 있어서 삭제하는 데이터")
        }catch{
//            print("데베에 없어서 삭제 못하는 데이터")
        }
    }
    @MainActor func saveRepository(setItem: SetItem,cardItems:[CardItem]){
        var setItem = setItem
        let cardSetTable:CardSetTable
        if let setTable{
            cardSetTable = setTable// 데베에 존재함
        }else{
            cardSetTable = CardSetTable()// 데베에 존재하지 않음 (새로 추가함)
        }
        let prevCardTables = Set(cardSetTable.cardList)
        let results:[CardTable] = cardItems.map {
            let cardTable:CardTable
            if let dbKey = $0.dbKey,let table = cardRepository?.getTableBy(tableID:dbKey){
                cardTable =  table
            }else{
                cardTable = CardTable()
            }
            cardRepository?.update(card: cardTable, item: $0)
            return cardTable
        }
        repository?.create(set: cardSetTable, setItem: setItem)
        prevCardTables.subtracting(results).forEach { cardRepository?.delete(item: $0) } // 이전에 존재한 카드 테이블들을 삭제한다.
        repository?.removeAllCards(set: cardSetTable)
        repository?.replaceAllCards(set: cardSetTable, cards: results)
        setItem.dbKey = cardSetTable._id
        setItem.cardList = cardItems
        passthroughEditSet.send(setItem)
        passthroughCloseAction.send()
        Task{
            ImageRC.shared.apply(ircSnapshot)
            await ImageRC.shared.saveRepository()
        }
    }
}
