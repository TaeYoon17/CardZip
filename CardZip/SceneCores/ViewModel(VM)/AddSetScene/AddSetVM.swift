//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import Foundation
import Combine
extension AddSetVM{
    enum CardActionType{ case imageTapped, delete }
    enum SetActionType{ case imageTapped }
}
final class AddSetVM{
    deinit{ print("AddSetVM DEINIT!") }
    @MainActor private let repository = CardSetRepository()
    @MainActor private let cardRepository = CardRepository()
    weak var photoService:PhotoService! = PhotoService.shared
    @Published var dataProcess: DataProcessType
    @Published var nowItemsCount: Int = 0
    @DefaultsState(\.recentSet) var recentKey
    var IRC: ImageRC = .init()
    var setItem: SetItem?
    // DataProcessTyppe Edit했을 때 변경 사항을 던져주는 passthrough
    var passthroughEditSet = PassthroughSubject<SetItem,Never>()
    var passthroughCloseAction = PassthroughSubject<Void,Never>() // 닫을 때
    var passthroughErrorMessage = PassthroughSubject<String,Never>() // 에러 메시지를 던질 때
    var updatedCardItem = PassthroughSubject<(CardItem,Bool),Never>() // 리스트에서 단일 카드 내용을 업데이트 할 때
    var updatedSetItem = PassthroughSubject<(SetItem,Bool),Never>() // 세트 정보를 업데이트 할 때
    // 카드에서 뷰컨 프로퍼티를 사용하는 액션을 요청할 때
    var cardAction = PassthroughSubject<(CardActionType,CardItem?),Never>()
    var setAction = PassthroughSubject<(SetActionType,SetItem?),Never>()
    init(dataProcess: DataProcessType,setItem: SetItem?){
        self.dataProcess = dataProcess
        switch dataProcess{
        case.add:
            self.setItem = .init(title: "", setDescription: "", cardList: [CardItem()], cardCount: 0)
        case .edit:
            self.setItem = setItem
        }
    }
}
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
            print("데베에 없어서 삭제 못하는 데이터")
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
            await IRC.saveRepository()
        }
    }
}
 
