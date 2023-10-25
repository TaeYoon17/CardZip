//
//  MainDataSource.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import Foundation
import UIKit
import Combine
extension MainVC{
    final class MainDataSource:UICollectionViewDiffableDataSource<Section.ID,Item>{
        @DefaultsState(\.recentSet) var recentSetTableId
        @DefaultsState(\.likedSet) var likedSetTableId
        var sectionStore: AnyModelStore<Section>!
        var folderItemStore: AnyModelStore<FolderListItem>!
        var pinnedItemStore: AnyModelStore<PinnedItem>!
        weak var vm: MainVM?
        var subscription = Set<AnyCancellable>()
        init(vm: MainVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<MainVC.Section.ID, MainVC.Item>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            initStores()
            initDataSource()
            vm.$isExist.sink {[weak self] val in
                if val{
                    self?.updateDataSource()
                }else{
                    self?.initDataSource()
                }
            }.store(in: &subscription)
        }
        func initStores(){
            let folderItems = (2...50).map{FolderListItem(title: "Try do this!", setNumber: $0)}
            let pinnedItems:[PinnedItem] = [.init(type: .recent, setItem: SetItem.getByTableId(recentSetTableId)),
                                            .init(type: .heart, setItem: .getByTableId(likedSetTableId))]
            self.folderItemStore = .init(folderItems)
            self.pinnedItemStore = .init(pinnedItems)
            self.sectionStore = .init([.init(id: .pinned, itemsID: pinnedItems.map{Item(id: $0.id, type: .pinned)} ),
                                       .init(id: .setList, itemsID: []),
    //                                   .init(id: .folderList, itemsID: folderItems.map{Item(id: $0.id, type: .folderList)} )
            ])
        }
        func updatePins(){
            let pinnedItems:[PinnedItem] = sectionStore.fetchByID(.pinned).itemsID.compactMap {
                guard var pinnedItem = pinnedItemStore.fetchByID($0.id) else {return nil}
                switch pinnedItem.type{
                    case .heart: pinnedItem.setItem = .getByTableId(likedSetTableId)
                    case .recent: pinnedItem.setItem = SetItem.getByTableId(recentSetTableId)
                }
                return pinnedItem
            }
            pinnedItems.forEach({pinnedItemStore.insertModel(item: $0)})
            var snapshot = snapshot()
            snapshot.reconfigureItems(pinnedItems.map{Item(id: $0.id, type: .pinned)})
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor private func initDataSource(){
            var snapshot = Snapshot()
            snapshot.appendSections([.pinned,.setList])
            [Section.ID.pinned,.setList].forEach{
                if $0 == .folderList {return}
                snapshot.appendItems(sectionStore.fetchByID($0).itemsID, toSection: $0)
            }
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor private func updateDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            snapshot.appendSections([.pinned,.setList])
            [Section.ID.pinned,.setList].forEach{
                snapshot.appendItems(sectionStore.fetchByID($0).itemsID, toSection: $0)
            }
            apply(snapshot,animatingDifferences: true)
        }
    }
}
