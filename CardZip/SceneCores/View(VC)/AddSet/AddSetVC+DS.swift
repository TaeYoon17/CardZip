//
//  AddSet+DS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/26.
//

import UIKit
import Combine
extension AddSetVC{
    final class DataSource:UICollectionViewDiffableDataSource<Section.ID,Item>{
        typealias Item = AddSetVC.Item
        typealias Section = AddSetVC.Section
        typealias SectionType = AddSetVC.SectionType
        weak var vm: AddSetVM!
        var itemModel : AnyModelStore<CardItem>!
        var headerModel : AnyModelStore<SetItem>!
        var sectionModel: AnyModelStore<Section>!
        var subscription = Set<AnyCancellable>()
        init(vm: AddSetVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<AddSetVC.Section.ID, AddSetVC.Item>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            initModels()
            vm.updatedCardItem.sink {[weak self] (item,reloadDS) in
                self?.itemModel.insertModel(item: item)
                if reloadDS{ self?.reconfigureDataSource(cardItem: item) }
            }.store(in: &subscription)
            
            vm.updatedSetItem
                .receive(on: RunLoop.main)
                .sink { [weak self] (item,reloadDS) in
                    
                self?.headerModel.insertModel(item: item)
                if reloadDS {self?.reconfigureDataSource(setItem: item)}
            }.store(in: &subscription)
            
//            vm.photoService.passthroughIdentifiers
//                .sink {[weak self] (val,vc) in
//                guard let self,let str = val.first else {return}
//                guard vc is AddSetVC else {return}
//                guard let item: Item = snapshot().itemIdentifiers(inSection: .header).first,
//                      var cardSetItem = headerModel.fetchByID(item.id) else {return}
//                cardSetItem.imagePath = str
//                headerModel.insertModel(item: cardSetItem)
//                reconfigureDataSource(item: item)
//            }.store(in: &subscription)
        }
        func createItem(){
            let cardItem = CardItem()
            let item = Item(id: cardItem.id, type: .cards)
            var section = sectionModel.fetchByID(.cards)
            section?.subItems.append(item)
            itemModel.insertModel(item: cardItem)
            sectionModel.insertModel(item: section!)
            self.appendDataSource(item: item)
        }
    }
}
//MARK: -- INIT MODEL
extension AddSetVC.DataSource{
    fileprivate func initModels(){
        guard let setItem = vm.setItem else {return}
        itemModel = .init(setItem.cardList)
        headerModel = .init([setItem])
        sectionModel = .init([
            Section(id: .header, subItems: [Item(id: setItem.id, type: .header)])
            ,Section(id: .cards, subItems: setItem.cardList.map{
                Item(id: $0.id, type: .cards)
            })])
        self.initDataSource()
    }
}
//MARK: -- DELETE MODEL
extension AddSetVC.DataSource{
    func deleteItem(cardItem: CardItem){
        let item = Item(id: cardItem.id, type: .cards)
        deleteItem(item: item)
    }
    func deleteItem(indexPath:IndexPath){
        guard let item = itemIdentifier(for: indexPath) else { return}
        self.deleteItem(item:item)
    }
    func deleteItem(item: Item){
        if let data:CardItem = self.itemModel.fetchByID(item.id){
            vm.deleteTable(cardItem: data)
        }else{
            print("아이템 모델에도 없는 데이터")
        }
        var subItems = sectionModel.fetchByID(.cards).subItems
        subItems.removeAll(where: { item in item.id == item.id })
        sectionModel.insertModel(item: Section(id: .cards, subItems: subItems))
        self.itemModel.removeModel(item.id)
        deleteDataSource(deleteItem: item)
    }
}
//MARK: -- SAVE MODEL
extension AddSetVC.DataSource{
    func saveData(){
        // 1. 헤더 타이틀을 추가하지 않은 경우 에러
        let snapshot = snapshot()
        guard let headerItem = snapshot.itemIdentifiers(inSection: .header).first,let setData = headerModel.fetchByID(headerItem.id),setData.title != "" else {
            vm.passthroughErrorMessage.send("No set title".localized)
            return
        }
        let cardModels = snapshot.itemIdentifiers(inSection: .cards)
        let items:[CardItem] = cardModels.compactMap { itemModel.fetchByID($0.id) ?? nil }
        if items.contains(where: {
            let title = $0.title.replacingOccurrences(of: " ", with: "")
            let description = $0.definition.replacingOccurrences(of: " ", with: "")
            return title == "" || description == ""
        }){
            vm.passthroughErrorMessage
                .send("There are cards with empty terms and descriptions.".localized)
            return
        }
        // 3. 이 카드 세트가 이미 데베에 존재하는 경우 (수정하는 경우)
        vm.saveRepository(setItem: setData, cardItems: items)
    }
}


//MARK: -- DataSource Apply Code
fileprivate extension AddSetVC.DataSource{
    @MainActor var getItemsCount:Int{
        let snapshot = snapshot()
        return snapshot.itemIdentifiers(inSection: .cards).count
    }
    //MARK: -- RECONFIGURE DATASOURCE
    @MainActor func reconfigureDataSource(cardItem: CardItem){
        var snapshot = snapshot()
        guard let item = snapshot.itemIdentifiers(inSection: .cards).first(where: { $0.id == cardItem.id }) else {return}
        reconfigureDataSource(item: item)
    }
    @MainActor func reconfigureDataSource(setItem: SetItem){
        let snapshot = snapshot()
        guard let item = snapshot.itemIdentifiers(inSection: .header).first(where: { $0.id == setItem.id}) else {return}
        reconfigureDataSource(item: item)
    }
    @MainActor func reconfigureDataSource(item: Item){
        var snapshot = snapshot()
        snapshot.reconfigureItems([item])
        apply(snapshot,animatingDifferences: false)
    }
    //MARK: -- DELETE DATASOURCE
    @MainActor func deleteDataSource(deleteItem: Item){
        var snapshot = snapshot()
        snapshot.deleteItems([deleteItem])
        apply(snapshot,animatingDifferences: true)
        vm.nowItemsCount = getItemsCount
        snapshot.reloadSections([.cards])
        Task{
            await apply(snapshot,animatingDifferences: false)
        }
    }
    //MARK: -- APPEND DATASOURCE
    @MainActor func appendDataSource(item: Item,toSection: SectionType = .cards){ // 데이터 소스만 추가, DB 저장 아님
        var snapshot = snapshot()
        snapshot.appendItems([item], toSection: toSection)
        apply(snapshot,animatingDifferences: false)
        vm.nowItemsCount = getItemsCount
        snapshot.reloadSections([.cards])
        Task{
            await apply(snapshot,animatingDifferences: false)
        }
    }
    //MARK: -- INIT DATASOURCE
    @MainActor func initDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.header,.cards])
        snapshot.appendItems(sectionModel.fetchByID(.cards).subItems, toSection: .cards)
        snapshot.appendItems(sectionModel.fetchByID(.header).subItems, toSection: .header)
        apply(snapshot,animatingDifferences: true)
        vm.nowItemsCount = getItemsCount
    }
}
