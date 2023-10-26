//
//  AddSet+DS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/26.
//

import UIKit
extension AddSetVC{
    final class DataSource:UICollectionViewDiffableDataSource<Section.ID,Item>{
        typealias Item = AddSetVC.Item
        typealias Section = AddSetVC.Section
        typealias SectionType = AddSetVC.SectionType
        weak var vm: AddSetVM!
        var itemModel : AnyModelStore<CardItem>!
        var headerModel : AnyModelStore<SetItem>!
        var sectionModel: AnyModelStore<Section>!
        init(vm: AddSetVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<AddSetVC.Section.ID, AddSetVC.Item>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            
        }
        func deleteItem(indexPath:IndexPath){
            guard let item = itemIdentifier(for: indexPath) else  { return}
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
        func saveData(){
            // 1. 헤더 타이틀을 추가하지 않은 경우 에러
            let snapshot = snapshot()
            guard let headerItem = snapshot.itemIdentifiers(inSection: .header).first,var setData = headerModel.fetchByID(headerItem.id),setData.title != "" else {
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
                vm.passthroughErrorMessage.send("There are cards with empty terms and descriptions.".localized)
                return
            }
            // 3. 이 카드 세트가 이미 데베에 존재하는 경우 (수정하는 경우)
            vm.saveRepository(setItem: setData, cardItems: items)
        }
    }
}
//MARK: -- Model CRUD
extension AddSetVC.DataSource{
    fileprivate func initModels(){
        switch vm.dataProcess{
        case .add:
            let cardItem = [CardItem()]
            let headerItem = [SetItem()]
            itemModel = .init(cardItem)
            headerModel = .init(headerItem)
            sectionModel = .init([
                Section(id: .header, subItems: headerItem.map{Item(id: $0.id, type: .header)})
                ,Section(id: .cards, subItems: cardItem.map{
                Item(id: $0.id, type: .cards)
            })])
            self.initDataSource()
        case .edit:
            if let setItem = vm.setItem{
                let cardItems = setItem.cardList
                let headerItem = [setItem]
                itemModel = .init(cardItems)
                headerModel = .init(headerItem)
                sectionModel = .init([
                    Section(id: .header, subItems: headerItem.map{Item(id: $0.id, type: .header)})
                    ,Section(id: .cards, subItems: cardItems.map{
                    Item(id: $0.id, type: .cards)
                })])
                self.initDataSource()
            }else{
//                    self.alertLackDatas(title: "Not found card set".localized) {[weak self] in
//                        self?.dismiss(animated: true)
//                    }
                vm.passthroughErrorMessage.send("Not found card set".localized)
                vm.passthroughCloseAction.send()
            }
        }
    }
}


//MARK: -- DataSource Apply Code
fileprivate extension AddSetVC.DataSource{
    @MainActor var getItemsCount:Int{
        let snapshot = snapshot()
        return snapshot.itemIdentifiers(inSection: .cards).count
    }
    
    @MainActor func reconfigureDataSource(item: Item){
        var snapshot = snapshot()
        snapshot.reconfigureItems([item])
        apply(snapshot,animatingDifferences: false)
    }
    @MainActor func configureSetImage(str:String){
        var snapshot = snapshot()
        guard let item: Item = snapshot.itemIdentifiers(inSection: .header).first,
              var cardSetItem = headerModel.fetchByID(item.id) else {return}
        cardSetItem.imagePath = str
        headerModel.insertModel(item: cardSetItem)
        snapshot.reconfigureItems([item])
        apply(snapshot,animatingDifferences: false)
    }
    
    @MainActor func deleteDataSource(deleteItem: Item){
        var snapshot = snapshot()
        snapshot.deleteItems([deleteItem])
        vm.nowItemsCount = getItemsCount
    }
    
    @MainActor func appendDataSource(){ // 데이터 소스만 추가, DB 저장 아님
        var snapshot = snapshot()
        let cardItem = CardItem()
        let item = Item(id: cardItem.id, type: .cards)
        var section = sectionModel.fetchByID(.cards)
        section?.subItems.append(item)
        itemModel.insertModel(item: cardItem)
        sectionModel.insertModel(item: section!)
        snapshot.appendItems([item], toSection: .cards)
        apply(snapshot,animatingDifferences: true)
        vm.nowItemsCount = getItemsCount
    }
    @MainActor func initDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.header,.cards])
        snapshot.appendItems(sectionModel.fetchByID(.cards).subItems, toSection: .cards)
        snapshot.appendItems(sectionModel.fetchByID(.header).subItems, toSection: .header)
        apply(snapshot,animatingDifferences: true)
        vm.nowItemsCount = getItemsCount
    }
}
