//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import Foundation
import Combine

final class AddSetVM{
    enum CardActionType{
        case imageTapped
        case delete
    }
    enum SetActionType{
        case hello
    }
    @MainActor let repository = CardSetRepository()
    var dataProcess: DataProcessType = .add
    var setItem: SetItem?
    var nowItemsCount: Int = 0
    
    // Edit했을 때 변경 사항을 던져주는 passthrough
    var passthroughEditSet = PassthroughSubject<SetItem,Never>()
    
    
    var passthroughCloseAction = PassthroughSubject<Void,Never>() // 닫을 때
    var passthroughErrorMessage = PassthroughSubject<String,Never>() // 에러 메시지를 던질 때
//    var passthroughDidBegin = PassthroughSubject<Void,Never>() // 시작할떼..?
    
    var updatedCardItem = PassthroughSubject<(CardItem,Bool),Never>() // 리스트에서 단일 카드 내용을 업데이트 할 때
    var updatedSetItem = PassthroughSubject<SetItem,Never>() // 세트 정보를 업데이트 할 때
    // 카드에서 뷰컨 프로퍼티를 사용하는 액션을 요청할 때
    var cardAction = PassthroughSubject<(CardActionType,CardItem?),Never>()
    var setAction = PassthroughSubject<(SetActionType,SetItem?),Never>()
    
    @Published var cards:[CardItem] = []
    init(dataProcess: DataProcessType,setItem: SetItem?){
        self.dataProcess = dataProcess
        self.setItem = setItem
    }
    func createItem(){ cards.append(.init()) }
    @MainActor var setTable:CardSetTable?{
        if let dbKey = setItem?.dbKey,let table = repository?.getTableBy(tableID: dbKey){
            return table
        }
        return nil
    }
    
    @MainActor func deleteTable(cardItem: CardItem){
        do{
            try repository?.cardRespository?.deleteTableBy(tableID: cardItem.dbKey)
            print("데베에 있어서 삭제하는 데이터")
        }catch{
            print("데베에 없어서 삭제 못하는 데이터")
        }
    }
    

    @MainActor func saveRepository(setItem: SetItem,cardItems:[CardItem]){
        var setItem = setItem
        let cardSetTable:CardSetTable
        //            if let dbKey = setData.dbKey,let setTable = repository?.getTableBy(tableID: dbKey)
        if let setTable{
            cardSetTable = setTable// 데베에 존재함
        }else{
            cardSetTable = CardSetTable()// 데베에 존재하지 않음 (새로 추가함)
        }
        let prevCardTables = Set(cardSetTable.cardList)
        let cardRepository:CardRepository = repository!.cardRespository!
        let results:[CardTable] = cardItems.map {
            let cardTable:CardTable
            if let dbKey = $0.dbKey,let table = cardRepository.getTableBy(tableID:dbKey){
                cardTable =  table
            }else{
                cardTable = CardTable()
            }
            cardRepository.update(card: cardTable, item: $0)
            return cardTable
        }
        repository?.create(set: cardSetTable, setItem: setItem)
        prevCardTables.subtracting(results).forEach { cardRepository.delete(item: $0) } // 이전에 존재한 카드 테이블들을 삭제한다.
        repository?.removeAllCards(set: cardSetTable)
        repository?.replaceAllCards(set: cardSetTable, cards: results)
        
        if dataProcess == .edit{
            setItem.cardList = cardItems
            passthroughEditSet.send(setItem)
        }
        passthroughCloseAction.send()
    }
}
