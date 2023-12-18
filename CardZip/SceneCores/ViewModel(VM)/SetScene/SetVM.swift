//
//  SetVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/27.
//

import Foundation
import Combine
import RealmSwift

enum SetError:String,Error{
    case card_not_found = "Not found card set"
    case likeSetCardEmpty = "Cards Empty"
}
final class SetVM{
    @MainActor let setRepository = CardSetRepository()
    @MainActor let cardRepository = CardRepository()
    
    @DefaultsState(\.recentSet) var recentSetId
    @DefaultsState(\.likedSet) var likedSetId
    @Published var studyType:StudyType = .basic
    @Published var searchText:String = ""
    @Published var setItem: SetItem
    var passthroughError = PassthroughSubject<SetError,Never>()
    var passthroughEdited = PassthroughSubject<Void,Never>()
    var passthroughSuffle = PassthroughSubject<Void,Never>()
    var passthroughUpdateCard = PassthroughSubject<CardItem,Never>()
    
    init(setItem:SetItem){
        self.setItem = setItem
    }
    deinit{
        print("SetVM이 사라집니다!!")
    }
    @MainActor func initModel(){
        guard let dbKey = setItem.dbKey,
              let setTable = setRepository?.getTableBy(tableID: dbKey) else {
            passthroughError.send(.card_not_found)
            return
        }
        if dbKey != likedSetId{ // 일반적인 세트
            recentSetId = dbKey
            self.setItem = SetItem(table: setTable)
        }
        else{
            // MARK: -- 별표 세트
            if setTable.cardList.isEmpty{
                setItem.imagePath = nil
                passthroughError.send(.likeSetCardEmpty)
                return
            }else if let cardTable = setTable.cardList.where({ ($0.imagePathes).count > 1}).first{
                setItem.imagePath = cardTable.imagePathes.first
            }
            Task{
                self.setRepository?.updateHead(set:setTable,setItem:setItem)
                self.setItem = SetItem(table: setTable)
            }
        }
    }
    
    @MainActor func deleteSet(){
        guard let dbKey = self.setItem.dbKey else{
            print("Delete dbkey not found")
            return }
        do{
            self.setRepository?.deleteAllCards(id: dbKey)
            try self.setRepository?.deleteTableBy(tableID: dbKey)
        }catch{
            print("DBKey가 없음!!")
        }
        self.recentSetId = nil
        Task{ await SetItem.removeAllIRC(item: setItem) }
    }
    
    @MainActor func updateCardTable(item: CardItem){
        guard let dbKey = item.dbKey,let cardTable = cardRepository?.getTableBy(tableID: dbKey) else {return}
        if let likedSetId, likedSetId == setItem.dbKey, !item.isLike{ // 좋아요 세트 테이블인 경우엔 테이블에 없애주어야 한다.
            setRepository?.removeCards(setId: likedSetId, card: cardTable)
        }
        cardRepository?.updateExceptImage(card: cardTable, item: item)
    }
    
}
