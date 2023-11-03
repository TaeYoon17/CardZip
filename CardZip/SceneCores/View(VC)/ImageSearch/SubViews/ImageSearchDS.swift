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
        private var itemModel: AnyModelStore<ImageSearch> = .init([])
        private var itemIDs: [ImageSearch.ID] = []
        weak var vm: ImageSearchVM!
        var subscription = Set<AnyCancellable>()
        init(vm: ImageSearchVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<ImageSearchVC.Section, ImageSearch.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            vm.$imagePathes.sink {[weak self] items in
                self?.appendImagePathes(items)
                self?.resetDataSource()
            }.store(in: &subscription)
            
            vm.updateItemPassthrough.sink { completion in
                print("여긴 아무 변화 없음")
            } receiveValue: {[weak self] imageSearch in
                guard let self else {return}
                itemModel.insertModel(item: imageSearch)
                updateDataSource(id: imageSearch.id)
            }.store(in: &subscription)
        }
        func appendImagePathes(_ pathes:[String]){
            let imgSearchItems = pathes.map{ImageSearch(imagePath: $0)}
            imgSearchItems.forEach {
                itemModel.insertModel(item: $0)
                if !itemIDs.contains($0.id){ itemIDs.append($0.id) }
            }
        }
        func fetchItem(id: ImageSearch.ID)-> ImageSearch?{ self.itemModel.fetchByID(id) }
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
