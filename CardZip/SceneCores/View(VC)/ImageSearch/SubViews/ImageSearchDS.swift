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
        var prevSearch: String?
        init(vm: ImageSearchVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<ImageSearchVC.Section, ImageSearch.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.vm = vm
            vm.searchText
                .sink {[weak self] newSearch in // 검색어 초기화
                guard let self else {return}
                if prevSearch != nil, prevSearch == newSearch { return }
                resetItem()
                prevSearch = newSearch
            }.store(in: &subscription)
            
            vm.$imageResults.sink { [weak self] items in // 이미지 결과 추가하기
                self?.appendImageResults(items)
                Task{
                    self?.vm.loadingStatusPassthrough.send(true)
                    try await ImageService.shared.appendCache(links: items.map{$0.thumbnail},
                                                              size: .init(width: 360, height: 360))
                    self?.vm.loadingStatusPassthrough.send(false)
                    self?.resetDataSource()
                }
            }.store(in: &subscription)
            
            vm.updateItemPassthrough
                .receive(on: RunLoop.main)
                .sink {[weak self] imageSearch in
                guard let self else {return}
                itemModel.removeModel(imageSearch.id)
                itemModel.insertModel(item: imageSearch)
                updateDataSource(id: imageSearch.id)
            }.store(in: &subscription)
            
            vm.reloadItemsPassthrough
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .sink {[weak self] reloadItems in // 체크된 후 순서가 바뀌는 아이템
                guard let self else {return}
                print("이게 왜 불려?")
                reconfigureDataSources(ids: reloadItems.map{$0.id})
            }.store(in: &subscription)
        }
        func fetchItem(id: ImageSearch.ID)-> ImageSearch?{
            self.itemModel.fetchByID(id)
        }
    }
}
fileprivate extension ImageSearchVC.ImageSearchDS{
    func appendImageResults(_ imageSearches:[ImageSearch]){
        for imageSearch in imageSearches {
            if !itemModel.isExist(id: imageSearch.id){
                itemModel.insertEmptyModel(item: imageSearch)
                itemIDs.append(imageSearch.id)
            }
        }
    }
    func resetItem(){
        itemModel = .init([])
        itemIDs = []
    }
}
extension ImageSearchVC.ImageSearchDS{
    @MainActor func resetDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,ImageSearch.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemIDs,toSection: .main)
        Task{@MainActor in
            apply(snapshot,animatingDifferences: true)
        }
    }
    @MainActor func updateDataSource(id: ImageSearch.ID){
        var snapshot = self.snapshot()
        snapshot.reconfigureItems([id])
        Task{ @MainActor in
            apply(snapshot,animatingDifferences: false)
        }
    }
    @MainActor func reconfigureDataSources(ids: [ImageSearch.ID]){
        var snapshot = snapshot()
        snapshot.reconfigureItems(ids)
        Task{@MainActor in
            apply(snapshot,animatingDifferences: false)
        }
    }
}
