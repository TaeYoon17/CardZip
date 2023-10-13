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
    func appendCard(set: CardSetTable,cards: [CardTable]){
        try! self.realm.write({
            set.cardList.removeAll()
            cards.forEach { set.cardList.append($0) }
        })
    }
    func removeAllCard(set: CardSetTable){
        try! self.realm.write({
            set.cardList.removeAll()
        })
    }
    func update(set: CardSetTable,setItem:SetItem){
        try! self.realm.write({
            set.imagePath = setItem.imagePath
            set.setDescription = setItem.setDescription
            set.title = setItem.title
            set.cardList.removeAll()
        })
    }
//    func updateAll<U>(subPath: WritableKeyPath<GoodsSub,U>,data: U){
//        getTasks.forEach {
//            self.update(item: $0, subPath: subPath, data: data)
//        }
//    }
//    func update<U>(item: GoodsTable,subPath:WritableKeyPath<GoodsSub,U>,data: U){
//        guard var memo = item.memo else {return}
//        do{
//            try realm.write{ memo[keyPath: subPath] = data }
//        }catch{
//            print(error)
//        }
//    }
//    func update<U>(goodsId: String,subPath:WritableKeyPath<GoodsSub,U>,data: U){
//        if let findTable = getTasks.where({ $0.goodsId.equals(goodsId)}).first{
//            update(item: findTable, subPath: subPath, data: data)
//        }else{
//            print("찾기 실패")
//        }
//    }
//    func firstBy(id: String)->GoodsTable?{
//        getTasks.where { $0.goodsId.equals(id) }.first
//    }
//    func checkSaving(table: GoodsTable){
//        guard let memo = table.memo else { fatalError("여기 메모가 남으면 안된다...") }
//        if (!memo.isLike && !memo.isRecent){
//            print("지울 거야...")
//            print(table.goodsId,table.memo?.isLike,table.memo?.isRecent)
//            UIImage.removeFromDocument(fileName: table.goodsId)
//
//            delete(item: table)
//        }
//    }
}
