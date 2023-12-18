//
//  AddSetVC+DS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/27.
//

import Foundation
import UIKit
import Combine
extension SetVC{
    final class DataSource:UICollectionViewDiffableDataSource<Section.ID,Item>{
        typealias Section = SetVC.Section
        typealias Item = SetVC.Item
        typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>
        var cardModel: AnyModelStore<CardItem>!
        var sectionModel: AnyModelStore<Section>!
        weak var vm: SetVM!
        var subscription = Set<AnyCancellable>()
        init(vm:SetVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SetVC.Section.ID, SetVC.Item>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            vm.$setItem
                .receive(on: RunLoop.main)
                .sink {[weak self] setItem in
                print("vm.$setItem.sink")
                self?.initCardModel(cardItems: setItem.cardList)
            }.store(in: &subscription)
            vm.$studyType
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .sink{[weak self] type in
                    guard let self else {return}
                    Task{ await self.searchAction(text: self.vm.searchText,type: type) }
                }.store(in: &subscription)
            vm.passthroughUpdateCard
//                .debounce(for: 0.2, scheduler: RunLoop.main)
                .receive(on: RunLoop.main)
                .sink { [weak self] cardItem in
//                print("-- \(cardItem)")
                self?.updateAction(cardItem: cardItem)
                self?.vm.updateCardTable(item: cardItem)
            }.store(in: &subscription)
            
            vm.$searchText.sink {[weak self] text in
                guard let self else {return}
                Task{
//                    print("Seaerch Action text: \(text)")
                    await self.searchAction(text: text)
                }
            }.store(in: &subscription)
        }
    }
}
extension SetVC.DataSource{
    func initCardModel(cardItems: [CardItem]){
        cardModel = .init(cardItems)
        sectionModel = .init([Section(id: .main,sumItem: cardItems.map{Item(id: $0.id, type: .main)})])
        Task{ await resetAction() }
    }
    func updateAction(cardItem: CardItem){
        self.cardModel.insertModel(item: cardItem)
//        Task{ await resetAction() }
        var snapshot = snapshot()
        if let item = snapshot.itemIdentifiers(inSection: .main).first(where: { $0.id == cardItem.id }){
            snapshot.reconfigureItems([item])
            Task{ await apply(snapshot,animatingDifferences: false) }
        }
    }
    func resetAction() async{
        do{
            let snapshott: Snapshot = try await resetSnapshot()
            await apply(snapshott,animatingDifferences: true)
        }catch{
            print("Hello world")
        }
    }
    private func resetSnapshot(type: StudyType? = nil) async throws -> Snapshot{
        let type = type ?? vm.studyType
        switch type {
        case .random,.basic:
            return try await self.resetAllSnapshot()
        case .check:
            return try await self.resetCheckedSnapshot()
        }
    }
    @MainActor func searchAction(text:String,type: StudyType? = nil) async {
        guard !text.isEmpty else {
            await resetAction()
            return
        }
        do{
            let snapshot = try await resetSnapshot(type: type)
            let filterItems = snapshot.itemIdentifiers(inSection: .main).filter ({ item in
                guard let card = self.cardModel?.fetchByID(item.id) else {return false}
                return card.title.contains(text) || card.definition.contains(text)
            })
            var newSnapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            newSnapshot.appendSections([.main])
            newSnapshot.appendItems(filterItems, toSection: .main)
            await apply(newSnapshot,animatingDifferences: true)
        }catch{
            print(error)
        }
    }
}
extension SetVC.DataSource{
    @MainActor func resetAllSnapshot() async throws -> Snapshot{
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.main])
        guard let items = sectionModel?.fetchByID(.main)?.sumItem else {
            throw DataSourceError.EmptySnapshot
        }
        snapshot.appendItems(items, toSection: .main)
        return snapshot
    }
    @MainActor func resetCheckedSnapshot() async throws -> Snapshot{
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.main])
        guard let items = sectionModel?.fetchByID(.main)?.sumItem.filter ({
            let card = self.cardModel?.fetchByID($0.id)
            return card?.isChecked ?? false
        }) else { throw DataSourceError.EmptySnapshot }
        snapshot.appendItems(items,toSection: .main)
        return snapshot
    }
}
