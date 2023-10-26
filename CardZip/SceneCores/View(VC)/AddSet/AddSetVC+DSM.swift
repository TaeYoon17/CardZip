//
//  AddSetVC+DataManage.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import Foundation
import UIKit
//MARK: -- DataSource Management
//extension AddSetVC{
//    @MainActor func reconfigureDataSource(item: Item){
//        var snapshot = dataSource.snapshot()
//        snapshot.reconfigureItems([item])
//        dataSource.apply(snapshot,animatingDifferences: false)
//    }
//    @MainActor func configureSetImage(str:String){
//        var snapshot = dataSource.snapshot()
//        guard let item: Item = snapshot.itemIdentifiers(inSection: .header).first,
//              var cardSetItem = headerModel.fetchByID(item.id) else {return}
//        cardSetItem.imagePath = str
//        headerModel.insertModel(item: cardSetItem)
//        snapshot.reconfigureItems([item])
//        dataSource.apply(snapshot,animatingDifferences: false)
//    }
//    @MainActor func deleteDataSource(indexPath:IndexPath){
//        guard let identifierToDelete = dataSource.itemIdentifier(for: indexPath) else  { return}
//        deleteDataSource(deleteItem: identifierToDelete)
//    }
//    @MainActor func deleteDataSource(deleteItem: Item){
//        if let data = self.itemModel.fetchByID(deleteItem.id){
//            do{
//                try repository?.cardRespository?.deleteTableBy(tableID: data.dbKey)
//                print("데베에 있어서 삭제하는 데이터")
//            }catch{
//                print("데베에 없어서 삭제 못하는 데이터")
//            }
//        }else{
//            print("아이템 모델에도 없는 데이터")
//        }=-
//        var subItems = sectionModel.fetchByID(.cards).subItems
//        subItems.removeAll(where: { item in item.id == deleteItem.id })
//        print(subItems)
//        sectionModel.insertModel(item: Section(id: .cards, subItems: subItems))
//        self.itemModel.removeModel(deleteItem.id)
//        var snapshot = dataSource.snapshot()
//        snapshot.deleteItems([deleteItem])
//        dataSource.apply(snapshot)
//        self.nowItemsCount = getItemsCount
//    }
//    @MainActor var getItemsCount:Int{
//        let snapshot = dataSource.snapshot()
//        return snapshot.itemIdentifiers(inSection: .cards).count
//    }
//    @MainActor func appendDataSource(){ // 데이터 소스만 추가, DB 저장 아님
//        var snapshot = dataSource.snapshot()
//        let cardItem = CardItem()
//        let item = Item(id: cardItem.id, type: .cards)
//        var section = sectionModel.fetchByID(.cards)
//        section?.subItems.append(item)
//        itemModel.insertModel(item: cardItem)
//        sectionModel.insertModel(item: section!)
//        snapshot.appendItems([item], toSection: .cards)
//        dataSource.apply(snapshot,animatingDifferences: true)
//        self.nowItemsCount = getItemsCount
//    }
//    @MainActor func initDataSource(){
//        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
//        snapshot.appendSections([.header,.cards])
//        snapshot.appendItems(sectionModel.fetchByID(.cards).subItems, toSection: .cards)
//        snapshot.appendItems(sectionModel.fetchByID(.header).subItems, toSection: .header)
//        dataSource.apply(snapshot,animatingDifferences: true)
//        self.nowItemsCount = getItemsCount
//    }
//}
//extension AddSetVC{
//    func saveRepository(){
//        // 1. 헤더 타이틀을 추가하지 않은 경우 에러
//        let snapshot = dataSource.snapshot()
//        guard let headerItem = snapshot.itemIdentifiers(inSection: .header).first,var setData = headerModel.fetchByID(headerItem.id),
//              setData.title != "" else {
//            alertLackDatas(title: "No set title".localized)
//            return
//        }
//        let cardModels = snapshot.itemIdentifiers(inSection: .cards)
//        let items:[CardItem] = cardModels.compactMap { itemModel.fetchByID($0.id) ?? nil }
//        if items.contains(where: {
//            let title = $0.title.replacingOccurrences(of: " ", with: "")
//            let description = $0.definition.replacingOccurrences(of: " ", with: "")
//            return title == "" || description == ""
//        }){
//            alertLackDatas(title: "There are cards with empty terms and descriptions.".localized)
//            return
//        }
//        // 3. 이 카드 세트가 이미 데베에 존재하는 경우 (수정하는 경우)
//        let cardSetTable:CardSetTable
//        if let dbKey = setData.dbKey,let setTable = repository?.getTableBy(tableID: dbKey){
//            cardSetTable = setTable// 데베에 존재함
//        }else{
//            cardSetTable = CardSetTable()// 데베에 존재하지 않음 (새로 추가함)
//        }
//        //        repository?.update(set: cardSetTable, setItem: setData)
//        //        repository?.headerUpdate(set: cardSetTable,setItem: setData)
//        let prevCardTables = Set(cardSetTable.cardList)
//        let cardRepository:CardRepository = repository!.cardRespository!
//        let results:[CardTable] = items.map {
//            let cardTable:CardTable
//            if let dbKey = $0.dbKey,let table = cardRepository.getTableBy(tableID:dbKey){
//                cardTable =  table
//            }else{
//                cardTable = CardTable()
//            }
//            cardRepository.update(card: cardTable, item: $0)
//            return cardTable
//        }
//        repository?.create(set: cardSetTable, setItem: setData)
//        prevCardTables.subtracting(results).forEach { cardRepository.delete(item: $0) } // 이전에 존재한 카드 테이블들을 삭제한다.
//        repository?.removeAllCards(set: cardSetTable)
//        repository?.replaceAllCards(set: cardSetTable, cards: results)
//
//        if vcType == .edit{
//            setData.cardList = items
//            self.passthroughSetItem.send(setData)
//        }
//        self.closeAction()
//    }
//}
