//
//  CardSetRepository.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import RealmSwift

@MainActor final class CardSetRepository: TableRepository<CardSetTable>{
    let cardRespository = CardRepository()
    func appendCard(id: ObjectId,cards: [CardTable]){
        guard let table = self.getTableBy(tableID: id) else {return}
        appendCard(set: table, cards: cards)
    }
    
    func appendCard(set: CardSetTable,cards: [CardTable]){
        try! self.realm.write({
            set.cardList.append(objectsIn: cards)
        })
    }
    //MARK: -- ReplaceAllCards
    func replaceAllCards(id: ObjectId,cards: Results<CardTable>){
        guard let table = self.getTableBy(tableID: id) else {return}
        replaceAllCards(set: table, cards: Array(cards))
    }
    func replaceAllCards(id: ObjectId,cards: [CardTable]){
        guard let table = self.getTableBy(tableID: id) else {return}
        replaceAllCards(set: table, cards: Array(cards))
    }
    func replaceAllCards(set: CardSetTable,cards: Results<CardTable>){
        replaceAllCards(set: set, cards: Array(cards))
    }
    func replaceAllCards(set: CardSetTable,cards: [CardTable]){
        self.deleteAllCards(setTable: set)
        try! self.realm.write({
            set.cardList.append(objectsIn: cards)
        })
    }
    // MARK: -- removeAllCards 세트 리스트와 카드의 연결을 끊는 정도
    func removeAllCards(set: CardSetTable){
        try! self.realm.write({ set.cardList.removeAll() })
    }
    func removeAllCards(id: ObjectId){
        guard let cardTable = self.getTableBy(tableID: id) else {return}
        removeAllCards(set: cardTable)
    }
    func removeCards(set: CardSetTable,card: CardTable){
        try! self.realm.write({
            if let idx = set.cardList.firstIndex(of: card){
                set.cardList.remove(at: idx)
            }
        })
    }
    func removeCards(setId: ObjectId,card:CardTable){
        guard let setTable = self.getTableBy(tableID: setId) else {return}
        removeCards(set: setTable, card: card)
    }
    // MARK: -- deleteAlllCards 카드들 내부 데이터도 함께 전부 삭제함
    func deleteAllCards(setTable: CardSetTable){
        setTable.cardList.forEach { table in
            _ = cardRespository?.delete(item: table)
        }
    }
    func deleteAllCards(id: ObjectId){
        guard let cardTable = self.getTableBy(tableID: id) else {return}
        deleteAllCards(setTable: cardTable)
    }
    func delete(id: ObjectId){
        guard let _ = self.getTableBy(tableID: id) else {return}
        deleteAllCards(id: id)
        do{ try super.deleteTableBy(tableID: id)
        }catch{ print(error)
        }
    }
    func create(set: CardSetTable,setItem:SetItem){
        self.create(item: set)
        try! self.realm.write({
                set.imagePath = setItem.imagePath
                set.setDescription = setItem.setDescription
                set.title = setItem.title
        })
    }
    func updateHead(set: CardSetTable,setItem:SetItem){
        try! self.realm.write({
            set.imagePath = setItem.imagePath
            set.setDescription = setItem.setDescription
            set.title = setItem.title
        })
    }
    
}
