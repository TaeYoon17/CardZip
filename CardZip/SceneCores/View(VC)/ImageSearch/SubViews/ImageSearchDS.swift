//
//  ImageSearchDS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import Combine
extension ImageSearchVC{
    final class ImageSearchDS: UICollectionViewDiffableDataSource<Section,ImageSearch.ID>{
        typealias Section = ImageSearchVC.Section
        private var itemModel: AnyModelStore<ImageSearch>!
        private var itemIDs: [ImageSearch.ID]
        weak var vm: ImageSearchVM!
        var subscription = Set<AnyCancellable>()
        init(vm: ImageSearchVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<ImageSearchVC.Section, ImageSearch.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            vm.$images.sink {[weak self] items in
                items.forEach { self?.itemModel.insertModel(item: $0) }
            }.store(in: &subscription)
        }
        
        func fetchItem(id: ImageSearch.ID)-> ImageSearch?{ self.itemModel?.fetchByID(id) }
    }
}

extension ImageSearchVC.ImageSearchDS{
    @MainActor func resetDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,ImageSearch.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemIDs,toSection: .main)
        apply(snapshot,animatingDifferences: true)
    }
    @MainActor func updateDataSource(id: ImageSearch.ID){
        var snapshot = snapshot()
        snapshot.reconfigureItems([id])
        apply(snapshot,animatingDifferences: false)
    }
}
