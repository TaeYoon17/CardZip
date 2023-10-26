//
//  CardVC+DS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/25.
//

import UIKit
import SnapKit
import Combine
extension CardVC{
    final class DataSource:UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>{
        typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID,CardItem.ID>
        var sectionModel: AnyModelStore<Section>!
        var cardsModel: AnyModelStore<CardItem>!
        var changedCardIDs = Set<CardItem.ID>()
        weak var vm: CardVM!
        var subscription = Set<AnyCancellable>()
        init(vm:CardVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<CardVC.Section.ID, CardItem.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            vm.passthroughUpdateCard.sink {[weak self] cardItem in
                guard let self else {return}
                cardsModel.insertModel(item: cardItem)
                changedCardIDs.insert(cardItem.id)
            }.store(in: &subscription)
            initModeldataSource()
        }
        func initModeldataSource(){
            // 여기를 vm에서 가져온다
            let cardItems:[CardItem] = vm.cardTables.map({ CardItem(table: $0) })
            // 검색해도 첫 아이템을 찾도록 대응
            self.vm.startCardNumber = cardItems.firstIndex {
                if let startItem = vm.startItem?.dbKey, let dbKey = $0.dbKey{
                    return startItem == dbKey
                }else {return false}
            }
            self.cardsModel = .init(cardItems)
            sectionModel = .init([Section(id: .main, subItems: cardItems.map{$0.id})])
            initDataSource()
            // 미리 첫 번째 아이템들만 캐싱한다.
            Task{
                cardItems.forEach { item in
                    guard let imagePath = item.imageID.first else {return }
                    Task.detached(operation: {
                        try await ImageService.shared.appendCache(albumID: imagePath)
                        try await ImageService.shared.appendCache(albumID:imagePath,size:.init(width: 720, height: 720))
                    })
                }
            }
        }
        func saveModel(){
            let cardItems = changedCardIDs.compactMap { cardsModel.fetchByID($0) }
            vm.saveRepository(cardItems: cardItems)
        }
    }
}
fileprivate extension CardVC.DataSource{
    func updateDataSource(itemID: CardItem.ID){
        var snapshot = Snapshot()
        snapshot.reloadItems([itemID])
        apply(snapshot,animatingDifferences: false)
    }
    func initDataSource(){
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let subItemIds = self.sectionModel.fetchByID(.main).subItems
        switch vm.studyType {
        case .random: snapshot.appendItems(subItemIds.shuffled(), toSection: .main)
        case .basic,.check: snapshot.appendItems(subItemIds,toSection: .main)
        }
        apply(snapshot,animatingDifferences: true)
    }
}
