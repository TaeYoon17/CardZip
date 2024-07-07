//
//  SetListDataSource.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import UIKit
import Combine

extension SetListVC{
    final class SetListDataSource:SwipableTableDiffableDataSource{
        @MainActor var imageDict:[String: UIImage] = [:]
        typealias Section = SetListVC.Section
        var sectionModel : AnyModelStore<Section>!
        var setModel: AnyModelStore<SetItem>!
        weak var vm: SetListVM!
        var subscription = Set<AnyCancellable>()
        init(vm: SetListVM,tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<SetListVC.Section.ID, SetItem.ID>.CellProvider) {
            super.init(tableView: tableView, cellProvider: cellProvider)
            self.vm = vm
            initItem()
            vm.$searchText.sink {[weak self] text in
                guard let self,let sectionItem = sectionModel?.fetchByID(.main) else {return}
                if text.isEmpty {
                    initDataSource()
                }else{
                    let setItemsID = sectionItem.subItems.filter { id in
                        guard let setItem = self.setModel.fetchByID(id) else {return false}
                        return setItem.title.contains(text)
                    }
                    applyItemsID(itemsID: setItemsID)
                }
            }.store(in: &subscription)
        }
        deinit{ print("SetListDataSource 사라짐!") }
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let identifierToDelete = itemIdentifier(for: indexPath) {
                    deleteSetItem(identifierToDelete)
                }
            }
        }
        func initItem(){
            Task{
                let items =  try await vm.getSetItems()
                setModel = .init(items)
                let itemIDs = items.map{$0.id}
                sectionModel = .init([Section(id: .main, subItems: itemIDs)])
                initDataSource()
                vm.isLoading = false
            }
        }
        func changeItem(before:SetItem.ID,after:SetItem?){
            if before == after?.id { return }
            var subItems = sectionModel.fetchByID(.main).subItems
            subItems.removeAll { id in id == before }
            setModel.removeModel(before)
            if let after{
                subItems.append(after.id)
                setModel.insertModel(item: after)
            }
            sectionModel.insertModel(item: Section(id: .main, subItems: subItems))
            changeDataSource(before: before, after: after?.id)
        }
        func deleteSetItem(_ id: SetItem.ID){
            guard let item:SetItem = setModel.fetchByID(id),let dbKey = item.dbKey else {return}
            Task{ await SetItem.removeAllIRC(item: item) }
            var subItems = sectionModel.fetchByID(.main).subItems
            subItems.removeAll(where: { $0 == id })
            setModel.removeModel(id)
            sectionModel.insertModel(item: .init(id: .main, subItems: subItems))
            guard let vm else {return}
            do{
                vm.repository?.delete(id: dbKey)
                if vm.recentDbKey == dbKey{ vm.recentDbKey = nil }
            }catch{
                print(error)
            }
            deleteDataSource(id: id)
        }
        
    }
}

fileprivate extension SetListVC.SetListDataSource{
    @MainActor func deleteDataSource(id: SetItem.ID){
        var snapshot = snapshot()
        snapshot.deleteItems([id])
        apply(snapshot,animatingDifferences: true)
    }
    @MainActor func changeDataSource(before: SetItem.ID,after: SetItem.ID?){
        var snapshot = snapshot()
        if let after{ snapshot.insertItems([after], afterItem: before) }
        snapshot.deleteItems([before])
        apply(snapshot,animatingDifferences: true)
    }
    @MainActor func reloadAllDataSource(){
        var snapshot = snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        apply(snapshot,animatingDifferences: true)
    }
    @MainActor func applyItemsID(itemsID: [SetItem.ID]){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,SetItem.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemsID)
        apply(snapshot,animatingDifferences:  true)
    }
    @MainActor func initDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,SetItem.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sectionModel.fetchByID(.main).subItems, toSection: .main)
        apply(snapshot,animatingDifferences: false)
    }
}

extension SetListVC{
    class SwipableTableDiffableDataSource: UITableViewDiffableDataSource<Section.ID,SetItem.ID>{
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    }
}
