//
//  AddSetVC+DataManage.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import Foundation
import UIKit
//MARK: -- DataSource Management
extension AddSetVC{
    @MainActor func reconfigureDataSource(item: Item){
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([item])
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    @MainActor func configureSetImage(str:String){
        var snapshot = dataSource.snapshot()
        guard let item: Item = snapshot.itemIdentifiers(inSection: .header).first,
              var cardSetItem = headerModel.fetchByID(item.id) else {return}
        cardSetItem.imagePath = str
        headerModel.insertModel(item: cardSetItem)
        snapshot.reconfigureItems([item])
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    @MainActor func deleteDataSource(indexPath:IndexPath){
        guard let identifierToDelete = dataSource.itemIdentifier(for: indexPath) else  { return}
            if let data = self.itemModel.fetchByID(identifierToDelete.id){
                do{
                    try repository?.cardRespository?.deleteTableBy(tableID: data.dbKey)
                    print("데베에 있어서 삭제하는 데이터")
                }catch{
                    print("데베에 없어서 삭제 못하는 데이터")
                }
            }else{
                print("아이템 모델에도 없는 데이터")
            }
        var subItems = sectionModel.fetchByID(.cards).subItems
        subItems.removeAll(where: { item in item.id == identifierToDelete.id })
        print(subItems)
        sectionModel.insertModel(item: Section(id: .cards, subItems: subItems))
        self.itemModel.removeModel(identifierToDelete.id)
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([identifierToDelete])
        dataSource.apply(snapshot)
    }
    @MainActor func appendDataSource(){ // 데이터 소스만 추가, DB 저장 아님
        var snapshot = dataSource.snapshot()
        let cardItem = CardItem()
        let item = Item(id: cardItem.id, type: .cards)
        var section = sectionModel.fetchByID(.cards)
        section?.subItems.append(item)
        itemModel.insertModel(item: cardItem)
        sectionModel.insertModel(item: section!)
        snapshot.appendItems([item], toSection: .cards)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    @MainActor func initDataSource(){
        dataSource.apply({
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            snapshot.appendSections([.header,.cards])
            snapshot.appendItems(sectionModel.fetchByID(.cards).subItems, toSection: .cards)
            snapshot.appendItems(sectionModel.fetchByID(.header).subItems, toSection: .header)
            return snapshot
        }(),animatingDifferences: true)
    }
}
extension AddSetVC{
    func saveRepository(){
        // 1. 헤더 타이틀을 추가하지 않은 경우 에러
        let snapshot = dataSource.snapshot()
        guard let headerItem = snapshot.itemIdentifiers(inSection: .header).first,
              let setData = headerModel.fetchByID(headerItem.id),
              setData.title != "" else {
            alertLackDatas(title: "No set title")
            return
        }
        let cardModels = snapshot.itemIdentifiers(inSection: .cards)
        let items = cardModels.compactMap { itemModel.fetchByID($0.id) ?? nil }
//        let items: [CardItem] = sectionModel.fetchByID(.cards).subItems.compactMap { itemModel.fetchByID($0.id) ?? nil }
        // 2. 카드에 데이터가 채워지지 않은 경우 에러
        if items.isEmpty || items.contains(where: {
            let title = $0.title.replacingOccurrences(of: " ", with: "")
            let description = $0.description.replacingOccurrences(of: " ", with: "")
            return title == "" || description == ""
        }){
            alertLackDatas(title: "There are cards with empty terms and descriptions.")
            return
        }
        // 3. 이 카드 세트가 이미 데베에 존재하는 경우 (수정하는 경우)
        let cardSetTable:CardSetTable = if let dbKey = setData.dbKey,let setTable = repository?.getTableBy(tableID: dbKey){ // 데베에 존재함
            setTable
        }else{ // 데베에 존재하지 않음 (새로 추가함)
            CardSetTable()
        }
        repository?.update(set: cardSetTable, setItem: setData)
        let cardRepository:CardRepository = repository!.cardRespository!
        let results:[CardTable] = items.map {
                let cardTable = if let dbKey = $0.dbKey,let table = cardRepository.getTableBy(tableID:dbKey){ table }else{ CardTable() }
                cardRepository.update(card: cardTable, item: $0)
            return cardTable
        }
//            repository?.create(item: cardSetTable)
//            repository?.appendCard(set: cardSetTable, cards: results)
        repository?.create(item: cardSetTable)
        repository?.removeAllCard(set: cardSetTable)
        repository?.appendCard(set: cardSetTable, cards: results)
        if vcType == .edit{ self.passthroughSetItem.send(setData)
        }
    }
}
